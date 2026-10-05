"""
SLIPER ESP32 ham bağlantı testi.

Qt uygulamasını aradan çıkarır: doğrudan 192.168.4.1:8888'e bağlanıp ham TCP
akışını dinler. Böylece "veri gelmiyor" sorununun kaynağı kesin ayrılır:

  - Hiç bağlanamıyorsa          -> Wi-Fi / AP tarafı (yanlış ağ, sinyal, reset)
  - Bağlanıp hiç bayt gelmiyorsa -> ESP32'nin loop() fonksiyonu kilitlenmiş
                                    (sensör okuması asılı kalmış; bkz. I2C)
  - Veri gelip arada kesiliyorsa -> sinyal / besleme kaynaklı kopma
  - Veri düzgün akıyorsa         -> sorun PC/Qt tarafında

Kullanım (önce PC'yi SLIPER-ESP32 ağına bağla):
    python tools/esp32_baglanti_testi.py
    python tools/esp32_baglanti_testi.py --sure 60
"""

import argparse
import json
import socket
import subprocess
import sys
import time

ESP32_IP = "192.168.4.1"
ESP32_PORT = 8888


def bagli_oldugumuz_agi_yazdir():
    """Testin yanlış ağda çalıştırılması en sık yapılan hata; önce onu gösterir."""
    try:
        cikti = subprocess.run(
            ["netsh", "wlan", "show", "interfaces"],
            capture_output=True, text=True, timeout=10,
        ).stdout
    except Exception as hata:
        print(f"Wi-Fi durumu okunamadi: {hata}")
        return

    for satir in cikti.splitlines():
        temiz = satir.strip()
        if temiz.startswith(("SSID", "Signal", "Rssi", "State")) and "BSSID" not in temiz:
            print("  " + temiz)


def ana():
    ayristirici = argparse.ArgumentParser(description="SLIPER ESP32 ham baglanti testi")
    ayristirici.add_argument("--sure", type=int, default=20, help="dinleme suresi (saniye)")
    ayristirici.add_argument("--ip", default=ESP32_IP)
    ayristirici.add_argument("--port", type=int, default=ESP32_PORT)
    argumanlar = ayristirici.parse_args()

    print("=== Wi-Fi durumu ===")
    bagli_oldugumuz_agi_yazdir()

    print(f"\n=== TCP baglantisi: {argumanlar.ip}:{argumanlar.port} ===")
    soket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    soket.settimeout(5.0)
    baslangic = time.time()
    try:
        soket.connect((argumanlar.ip, argumanlar.port))
    except Exception as hata:
        print(f"BAGLANAMADI: {hata}")
        print("-> PC SLIPER-ESP32 agina bagli degil ya da ESP32 kapali/resetleniyor.")
        return 1
    print(f"Baglanti kuruldu ({(time.time() - baslangic) * 1000:.0f} ms).")

    # --- Akışı dinle: gelen baytlar, satırlar ve en uzun sessizlik aralığı ---
    print(f"\n=== {argumanlar.sure} saniye dinleniyor ===")
    soket.settimeout(1.0)
    tampon = b""
    toplam_bayt = 0
    satir_sayisi = 0
    bozuk_satir = 0
    ilk_satirlar = []
    son_veri_zamani = time.time()
    en_uzun_sessizlik = 0.0
    ilk_zaman_damgasi = None
    son_zaman_damgasi = None
    dinleme_basi = time.time()

    while time.time() - dinleme_basi < argumanlar.sure:
        try:
            parca = soket.recv(4096)
        except socket.timeout:
            sessizlik = time.time() - son_veri_zamani
            en_uzun_sessizlik = max(en_uzun_sessizlik, sessizlik)
            if sessizlik > 2.0:
                print(f"  [{time.time() - dinleme_basi:5.1f}s] {sessizlik:.1f} saniyedir veri yok")
            continue
        except Exception as hata:
            print(f"  Okuma hatasi: {hata}")
            break

        if not parca:
            print(f"  [{time.time() - dinleme_basi:5.1f}s] ESP32 baglantiyi kapatti.")
            break

        en_uzun_sessizlik = max(en_uzun_sessizlik, time.time() - son_veri_zamani)
        son_veri_zamani = time.time()
        toplam_bayt += len(parca)
        tampon += parca

        while b"\n" in tampon:
            satir, tampon = tampon.split(b"\n", 1)
            satir = satir.strip()
            if not satir:
                continue
            satir_sayisi += 1
            try:
                paket = json.loads(satir)
                zaman = paket.get("t")
                if zaman is not None:
                    if ilk_zaman_damgasi is None:
                        ilk_zaman_damgasi = zaman
                    son_zaman_damgasi = zaman
            except Exception:
                bozuk_satir += 1
            if len(ilk_satirlar) < 3:
                ilk_satirlar.append(satir.decode("utf-8", "replace"))

    soket.close()
    gecen_sure = time.time() - dinleme_basi

    # --- Özet ve yorum ---
    print("\n=== SONUC ===")
    print(f"Sure            : {gecen_sure:.1f} s")
    print(f"Gelen bayt      : {toplam_bayt}")
    print(f"Gelen satir     : {satir_sayisi}  ({satir_sayisi / gecen_sure:.1f} paket/s, beklenen ~50)")
    print(f"Bozuk satir     : {bozuk_satir}")
    print(f"En uzun sessizlik: {en_uzun_sessizlik:.1f} s")
    if ilk_zaman_damgasi is not None and son_zaman_damgasi is not None:
        print(f"ESP32 zamani    : {ilk_zaman_damgasi} -> {son_zaman_damgasi} ms")
        if son_zaman_damgasi < ilk_zaman_damgasi:
            print("  DIKKAT: zaman geri gitti -> ESP32 test sirasinda yeniden basladi (reset).")
    for satir in ilk_satirlar:
        print(f"Ornek paket     : {satir}")

    print("\n=== YORUM ===")
    if toplam_bayt == 0:
        print("TCP baglandi ama TEK BAYT gelmedi.")
        print("-> Wi-Fi ve TCP katmani ESP32'de ayri bir gorevde calisir; bu yuzden")
        print("   Arduino loop() tamamen kilitlenmis olsa bile baglanti kurulur.")
        print("   Sorun ESP32 firmware'inde: sensor okumasi (buyuk ihtimalle ADS1115")
        print("   veya MPU6050 I2C) donusumu bekleyen sonsuz dongude asili kalmis.")
        print("   Yapilacak: ESP32'nin gucunu kesip acin; duzelmezse I2C (SDA/SCL) ve")
        print("   ADS1115 kablolarini kontrol edin, ardindan guncel firmware'i yukleyin.")
    elif satir_sayisi / gecen_sure < 25:
        print("Veri geliyor ama hiz beklenenin cok altinda (~50 paket/s olmali).")
        print("-> Zayif Wi-Fi sinyali veya ESP32 loop'unda araliklar.")
    elif en_uzun_sessizlik > 1.5:
        print("Akis genel olarak saglikli ama araliklarla kesiliyor.")
        print("-> Sinyal zayifligi ya da ESP32 beslemesi (brownout) incelenmeli.")
    else:
        print("Veri akisi saglikli. Sorun bu durumda PC/Qt tarafindadir.")

    return 0


if __name__ == "__main__":
    sys.exit(ana())
