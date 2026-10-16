"""Gecmis stroke kayitlarinda Pmax'i saklanan ham veriden yeniden turetir.

NEDEN: Pmax filtresinin penceresi ornek sayisiyla tanimliydi (PMAKS_PENCERE = 15)
ve "50 Hz'de 0.3 s" varsayimina dayaniyordu. Kayitli ham veri orneklerin ~4.5 Hz
geldigini gosteriyor; 15 ornek o hizda 3.3 saniyelik ortalama demekti, yani
stroke'un kendisinden uzundu. Basinc tepesi duz tabanla birlikte ortalanip
siliniyor, Pmax 30-70 mbar dusuk cikiyordu. Pencere SliperModel'de zaman tabanli
hale getirildi (PMAKS_PENCERE_S = 0.30); bu betik ayni duzeltmeyi gecmis
kayitlara uygular.

NE DEGISIR: yalnizca pMaks ve ondan turetilen basinc (p = Pmax - P0l).
Ham veri, P0l, P0r, debi, hiz ve konum ellenmez.

GERI ALMA: orijinal degerler pMaksOrijinal / basincOrijinal sutunlarinda saklanir,
ayrica calistirmadan once veritabaninin tam yedegi alinir. Betik tekrar
calistirilabilir; orijinal sutunlar bir kez doldurulur, uzerine yazilmaz.
"""

import json
import os
import shutil
import sqlite3
import sys
from datetime import datetime

PMAKS_PENCERE_S = 0.30
PMAKS_MIN_ORNEK = 3

VERITABANI_YOLU = os.path.join(
    os.environ.get("LOCALAPPDATA", ""), "SLIPER", "database", "sliper.db")


def filtreli_maksimum(zamanlar, basinclar, pencere_s=PMAKS_PENCERE_S):
    """SliperModel::filtreliMaksimum ile ayni: SURE ile tanimli merkezi hareketli
    ortalamalarin en buyugu, pencerede en az PMAKS_MIN_ORNEK ornek bulunmak sartiyla."""
    ornek_sayisi = min(len(zamanlar), len(basinclar))
    if ornek_sayisi == 0:
        return 0.0

    yari_pencere = pencere_s / 2.0
    en_buyuk = float("-inf")
    for merkez in range(ornek_sayisi):
        merkez_zamani = zamanlar[merkez]

        pencere_basi = merkez
        while pencere_basi > 0 and merkez_zamani - zamanlar[pencere_basi - 1] <= yari_pencere:
            pencere_basi -= 1
        pencere_sonu = merkez
        while (pencere_sonu < ornek_sayisi - 1
               and zamanlar[pencere_sonu + 1] - merkez_zamani <= yari_pencere):
            pencere_sonu += 1

        # Sure sarti az ornek biraktiysa pencere iki yana dengeli genisletilir
        while (pencere_sonu - pencere_basi + 1 < PMAKS_MIN_ORNEK
               and (pencere_basi > 0 or pencere_sonu < ornek_sayisi - 1)):
            sola_genislet = pencere_basi > 0 and (
                pencere_sonu == ornek_sayisi - 1
                or merkez_zamani - zamanlar[pencere_basi - 1]
                <= zamanlar[pencere_sonu + 1] - merkez_zamani)
            if sola_genislet:
                pencere_basi -= 1
            else:
                pencere_sonu += 1

        pencere = basinclar[pencere_basi:pencere_sonu + 1]
        en_buyuk = max(en_buyuk, sum(pencere) / len(pencere))
    return en_buyuk


def orijinal_sutunlari_ekle(imlec):
    mevcut_sutunlar = {satir[1] for satir in imlec.execute("PRAGMA table_info(Strokelar)")}
    for sutun in ("pMaksOrijinal", "basincOrijinal"):
        if sutun not in mevcut_sutunlar:
            imlec.execute(f"ALTER TABLE Strokelar ADD COLUMN {sutun} REAL")


def main():
    if not os.path.exists(VERITABANI_YOLU):
        sys.exit(f"Veritabani bulunamadi: {VERITABANI_YOLU}")

    damga = datetime.now().strftime("%Y%m%d_%H%M%S")
    yedek_yolu = f"{VERITABANI_YOLU}.yedek_{damga}"
    shutil.copy2(VERITABANI_YOLU, yedek_yolu)
    print(f"Yedek alindi: {yedek_yolu}\n")

    baglanti = sqlite3.connect(VERITABANI_YOLU)
    imlec = baglanti.cursor()
    orijinal_sutunlari_ekle(imlec)

    satirlar = imlec.execute(
        "SELECT id, olcumId, pMaks, p0l, basinc, gecerli, gecersizNedeni, hamVeri, "
        "pMaksOrijinal FROM Strokelar "
        "WHERE hamVeri IS NOT NULL AND hamVeri != '' ORDER BY id"
    ).fetchall()

    guncellenen = 0
    gecerliye_donen = 0
    toplam_kazanc = 0.0
    olcum_basina_kazanc = {}

    for (stroke_id, olcum_id, pmaks_eski, p0l, basinc_eski, gecerli,
         gecersiz_nedeni, ham, pmaks_orijinal) in satirlar:
        try:
            veri = json.loads(ham)
            zamanlar, basinclar = veri["t"], veri["p"]
            bitis_zamani = veri["tBitis"]
        except (ValueError, KeyError):
            print(f"  stroke {stroke_id}: ham veri okunamadi, atlandi")
            continue

        if not zamanlar or not basinclar:
            continue

        # Pmax yalnizca inis bolumunden hesaplanir (bitis sonrasi P0r penceresi haric)
        inis_sonu = next((i for i, t in enumerate(zamanlar) if t > bitis_zamani), len(zamanlar))
        inis_zamanlari = zamanlar[:inis_sonu]
        inis_basinclari = basinclar[:inis_sonu]
        if not inis_basinclari:
            continue

        pmaks_yeni = filtreli_maksimum(inis_zamanlari, inis_basinclari)
        basinc_yeni = pmaks_yeni - p0l

        # Orijinaller yalnizca ilk calistirmada yazilir
        if pmaks_orijinal is None:
            imlec.execute(
                "UPDATE Strokelar SET pMaksOrijinal = ?, basincOrijinal = ? WHERE id = ?",
                (pmaks_eski, basinc_eski, stroke_id))

        imlec.execute("UPDATE Strokelar SET pMaks = ?, basinc = ? WHERE id = ?",
                      (pmaks_yeni, basinc_yeni, stroke_id))

        # Pmax yukseldigi icin "basinc <= 0" diye gecersiz sayilan stroke'lar
        # artik gecerli olabilir (SliperModel::strokeGecersizNedeni)
        if gecersiz_nedeni == "basinc" and basinc_yeni > 0.0:
            imlec.execute(
                "UPDATE Strokelar SET gecerli = 1, gecersizNedeni = '' WHERE id = ?",
                (stroke_id,))
            gecerliye_donen += 1

        guncellenen += 1
        kazanc = pmaks_yeni - pmaks_eski
        toplam_kazanc += kazanc
        olcum_basina_kazanc.setdefault(olcum_id, []).append(kazanc)

    baglanti.commit()

    print(f"{guncellenen} stroke yeniden hesaplandi.")
    if gecerliye_donen:
        print(f"{gecerliye_donen} stroke 'basinc' gecersizliginden kurtuldu.")
    print(f"Ortalama Pmax kazanci: {toplam_kazanc / max(guncellenen, 1):+.1f} mbar\n")

    print("Olcum basina ortalama Pmax kazanci [mbar]:")
    for olcum_id in sorted(olcum_basina_kazanc):
        kazanclar = olcum_basina_kazanc[olcum_id]
        print(f"  {olcum_id:>4} : {sum(kazanclar) / len(kazanclar):+6.1f}  ({len(kazanclar)} stroke)")

    baglanti.close()


if __name__ == "__main__":
    main()
