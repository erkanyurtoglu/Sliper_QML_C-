"""
SLIPER ESP32 seri port dinleyici.

Kartın açılış mesajlarını ve saniyelik durum özetini okur. Özellikle şu iki
satır aranır:

  "Yeniden baslatma sebebi: ..."  -> kart beklenmedik şekilde yeniden
                                     başlıyorsa sebebi (watchdog / brownout)
  "[12s] istemci=1 gonderilen=600 ..." -> loop() çalışıyor; bu satır durursa
                                     döngü kilitlenmiş demektir

Kullanım:
    python tools/esp32_seri_dinle.py            # 20 saniye dinler
    python tools/esp32_seri_dinle.py --sure 60 --port COM14
"""

import argparse
import sys
import time

try:
    import serial  # pyserial
except ImportError:
    print("pyserial kurulu degil. Kurmak icin: python -m pip install pyserial")
    sys.exit(1)


def ana():
    ayristirici = argparse.ArgumentParser(description="SLIPER ESP32 seri port dinleyici")
    ayristirici.add_argument("--port", default="COM14")
    ayristirici.add_argument("--sure", type=int, default=20, help="dinleme suresi (saniye)")
    ayristirici.add_argument("--hiz", type=int, default=115200)
    argumanlar = ayristirici.parse_args()

    try:
        baglanti = serial.Serial(argumanlar.port, argumanlar.hiz, timeout=1)
    except Exception as hata:
        print(f"{argumanlar.port} acilamadi: {hata}")
        print("-> Arduino IDE'nin seri monitoru acik olabilir; kapatip tekrar deneyin.")
        return 1

    print(f"{argumanlar.port} dinleniyor ({argumanlar.sure} s). Kartin resetlenmesi icin bekleniyor...\n")

    baslangic = time.time()
    son_satir_zamani = time.time()
    en_uzun_sessizlik = 0.0
    satir_sayisi = 0

    try:
        while time.time() - baslangic < argumanlar.sure:
            ham = baglanti.readline()
            if not ham:
                en_uzun_sessizlik = max(en_uzun_sessizlik, time.time() - son_satir_zamani)
                continue
            son_satir_zamani = time.time()
            satir_sayisi += 1
            satir = ham.decode("utf-8", "replace").rstrip()
            print(f"[{time.time() - baslangic:6.2f}s] {satir}")
    except KeyboardInterrupt:
        pass
    finally:
        baglanti.close()

    print(f"\n--- {satir_sayisi} satir okundu, en uzun sessizlik {en_uzun_sessizlik:.1f} s ---")
    if satir_sayisi == 0:
        print("Hic cikti yok -> kart calismiyor ya da USB CDC kapali yuklenmis olabilir.")
    elif en_uzun_sessizlik > 3:
        print("Durum satiri uzun sure durmus -> loop() kilitleniyor.")
    return 0


if __name__ == "__main__":
    sys.exit(ana())
