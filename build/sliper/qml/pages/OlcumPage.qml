import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7
import sliper

Rectangle {
    color: "#0a0a0d"

    readonly property var metinler: ({
        testBilgileri: { tr: "TEST BİLGİLERİ", en: "TEST INFORMATION" },
        olcumYeri: { tr: "Ölçüm Yeri", en: "Place of Measure" },
        olcumYeriPlaceholder: { tr: "Laboratuvar / şantiye...", en: "Laboratory / site..." },
        musteri: { tr: "Müşteri", en: "Customer" },
        musteriPlaceholder: { tr: "Musteri adi girin...", en: "Enter customer name..." },
        betonRecetesi: { tr: "Beton Reçetesi", en: "Concrete Mix Design" },
        receteSeciniz: { tr: "Reçete Seçin...", en: "Select Mix Design..." },
        cimentoEtiket: { tr: "Çimento ", en: "Cement " },
        suCimentoEtiket: { tr: "  •  Su/Çimento ", en: "  •  Water/Cement " },
        eklenenAgirlik: { tr: "Eklenen Ağırlık (kg)", en: "Added Weight (kg)" },
        agirlikYok: { tr: "Ek ağırlık yok", en: "No added weight" },
        sonStroke: { tr: "SON STROKE", en: "LAST STROKE" },
        strokeYok: { tr: "Henüz stroke yok — boruyu üst konuma kaldırıp serbest bırakın", en: "No stroke yet — lift the pipe to the top position and release it" },
        sure: { tr: "Süre", en: "Duration" },
        gecerliStroke: { tr: "GEÇERLİ", en: "VALID" },
        hataliStroke: { tr: "HATALI STROKE", en: "WRONG STROKE" },
        nedenHiz: { tr: "hız ≤ 0", en: "speed ≤ 0" },
        nedenBasinc: { tr: "p ≤ 0", en: "p ≤ 0" },
        nedenOrnek: { tr: "yetersiz örnek", en: "too few samples" },
        geriButon: { tr: "−", en: "−" },
        sifirlaButon: { tr: "↺", en: "↺" },
        olcumuBaslatButon: { tr: "▶  Ölçümü Başlat", en: "▶  Start Measurement" },
        devamEtButon: { tr: "▶  Devam Et", en: "▶  Resume" },
        duraklatButon: { tr: "⏸  Duraklat", en: "⏸  Pause" },
        bitirButon: { tr: "⏹  Bitir", en: "⏹  Finish" },
        veriYok: { tr: "VERI YOK", en: "NO DATA" },
        duraklatildiDurum: { tr: "DURAKLATILDI", en: "PAUSED" },
        ustKonumBekleniyor: { tr: "ÜSTE TAKIN", en: "ATTACH AT TOP" },
        grafikDonduDurum: { tr: "STROKE BİTTİ", en: "STROKE FINISHED" },
        ustKonumIpucu: { tr: "Cihazı üst sabitleme noktasına takıp mili sensörün önüne çevirin — kayıt kendiliğinden başlar", en: "Attach the device to the top fixture and turn the rod in front of the sensor — recording starts automatically" },
        anlikDegerler: { tr: "ANLIK DEĞERLER", en: "CURRENT VALUES" },
        basincEtiket: { tr: "BASINÇ", en: "PRESSURE" },
        konumEtiket: { tr: "KONUM", en: "POSITION" },
        hizEtiket: { tr: "HIZ", en: "SPEED" },
        debiEtiket: { tr: "DEBİ", en: "FLOW RATE" },
        basincZaman: { tr: "Basınç - Zaman", en: "Pressure - Time" },
        konumZaman: { tr: "Konum - Zaman", en: "Position - Time" },
        hizZaman: { tr: "Hız - Zaman", en: "Speed - Time" },
        debiZaman: { tr: "Debi - Zaman", en: "Flow Rate - Time" },
        sesliDinleniyor: { tr: "🎙 Dinleniyor — \"Başlat / Durdur / Devam Et / Bitir / Ekle\"", en: "🎙 Listening — \"Start / Stop / Resume / Finish / Add\"" },
        sesliHazirlaniyor: { tr: "🎙 Sesli komut hazırlanıyor...", en: "🎙 Preparing voice commands..." },
        duyulanEtiket: { tr: "Duyulan: ", en: "Heard: " },
        bitirOnaySorusu: { tr: "Ölçümü bitirmek istediğinize emin misiniz?", en: "Are you sure you want to finish the measurement?" },
        kaydetVeBitir: { tr: "💾  Kaydet ve Bitir", en: "💾  Save and Finish" },
        testiSilVeBitir: { tr: "🗑  Testi Sil ve Bitir", en: "🗑  Delete Test and Finish" },
        vazgecTesteDevam: { tr: "Vazgeç, Teste Devam Et", en: "Cancel, Continue Testing" },
        uyariMusteriAdi: { tr: "Lütfen müşteri adını girin.", en: "Please enter the customer name." },
        uyariReceteSec: { tr: "Lütfen reçeteyi seçin veya yazın.", en: "Please select or type the mix design." },
        recetePlaceholder: { tr: "Seçin veya yazın (örn. C30/37, K-12)...", en: "Select or type (e.g. C30/37, M-12)..." },
        veriAkisiKesildi: { tr: "⚠ Veri akışı kesildi — cihazı ve Wi-Fi bağlantısını kontrol edin", en: "⚠ Data transfer interrupted — check the device and Wi-Fi connection" },
        uyariCihazBagliDegil: { tr: "Cihaz bağlı değil. Lütfen önce sol alttan SLIPER-ESP32'ye bağlanın.", en: "Device not connected. Please connect to SLIPER-ESP32 from the bottom left first." },
        uyariAktifOlcumYok: { tr: "Aktif bir ölçüm yok. Önce ölçümü başlatın.", en: "No active measurement. Please start a measurement first." }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }
    property real zamanSayaci: 0
    property int aktifOlcumId: -1
    property string uyariMesaji: ""
    property bool bitirIcinDuraklatildi: false

    // Anlık değer kutucukları (BASINÇ/KONUM/HIZ/DEBİ) sensörden gelen her
    // paketle değil, aşağıdaki Timer ile yavaşlatılmış hızda güncellenir;
    // aksi halde sayılar gözün takip edemeyeceği kadar hızlı değişip
    // görüntü kirliliğine yol açıyordu. Grafikler ham veriyi olduğu gibi alır.
    property real gosterilenBasinc: 0
    property real gosterilenKonum: 0
    property real gosterilenHiz: 0
    property real gosterilenDebi: 0
    property bool gosterilenVeriGecerli: false

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            gosterilenBasinc = sensorManager.basinc
            gosterilenKonum = sensorManager.konum
            gosterilenHiz = sensorManager.hiz
            gosterilenDebi = sensorManager.debi
            gosterilenVeriGecerli = sensorManager.veriGecerli
        }
    }

    property real baslangicZamaniS: -1
    // Duraklatma sirasinda cihazin saati akmaya devam eder; bu sure grafik
    // zaman ekseninden dusulur, aksi halde Devam Et sonrasi grafikte bos bir
    // bosluk olusur (stroke kaldigi yerden degil, duraklama kadar ileriden baslar).
    property real toplamDuraklamaSuresiS: 0
    property real duraklamaBaslangicZamanS: 0
    property var zamanGecmis: []
    property var basincGecmis: []
    property var konumGecmis: []
    property var hizGecmis: []
    property var debiGecmis: []

    // --- Otomatik kayıt (üst sabitleme noktası) --------------------------------
    // Cihaz üst sabitleme noktasında havada asılıyken mesafe sensörünün önünde
    // demir mil yoktur ve sensör çok uzağı (~400 mm) okur. Mil çevrilip sensörün
    // önüne geldiğinde kalibre edilen üst konum (~64 mm) okunur; gerçek stroke
    // ancak o andan sonra başlar. Bu yüzden "Ölçümü Başlat" grafiği hemen
    // akıtmaz, önce üst konumun görülmesini bekler.
    //   BEKLEMEDE -> (üst konum görüldü) -> KAYITTA -> (iniş durdu) -> DONDU
    //   DONDU -> (boru tekrar üst konuma alındı) -> KAYITTA (yeni stroke)
    property string kayitDurumu: "BEKLEMEDE"
    property bool inisBasladi: false
    property real kayitBaslangicKonumuMm: 0
    property real durgunlukBaslangicZamanS: -1

    // Üst referansa bu kadar yaklaşılması "üst konumda" sayılır. Değer
    // Calculator'dan okunur: grafik kaydı ile stroke hesabı aynı anda
    // kollanmalı, aksi halde grafik yeni stroke'a hazırlanırken Calculator
    // boruyu "üstte" saymaz ve iniş stroke olarak işlenmez.
    readonly property real ustYakalamaToleransiMm: calculator.ustYakalamaToleransiMm()
    // Grafiği erken dondurmamak için: boru bu kadar aşağı inmeden "iniş başladı" sayılmaz.
    readonly property real inisBaslamaYoluMm: 40
    // Bu hızın altı "duruyor", bu süre kadar sürerse iniş bitmiş kabul edilir.
    readonly property real durmaHiziMs: 0.02
    readonly property real durmaOnayiSuresiS: 0.2
    // Üst konumda serbest bırakılma beklenirken grafikte tutulan son süre.
    // Kısa tutulur: bekleme uzasa bile zaman ekseni şişmez ve iniş başladığında
    // stroke grafiğin büyük kısmını kaplar (öncesinde yalnızca taban çizgisi görünür).
    readonly property real beklemePenceresiS: 1.0

    // Orijinal ağırlık seti: 3 x ~1.6 kg ve 3 x ~4.8 kg. Eklenen her ağırlık
    // sırayla tutulur; "Geri" son ekleneni kaldırır. Her stroke, o anki toplam
    // ağırlıkla kaydedilir (kılavuz: her yük için en az 3 stroke).
    property var agirlikListesi: []
    property real strokeAgirligi: -1
    readonly property int agirlikAdedi: agirlikListesi.length
    readonly property real agirlikToplam: {
        var t = 0
        for (var i = 0; i < agirlikListesi.length; i++) t += agirlikListesi[i]
        return t
    }

    function agirlikEkle(kg) {
        var yeni = agirlikListesi.slice()
        yeni.push(kg)
        agirlikListesi = yeni
        agirlikEklendi()
    }

    function agirlikGeriAl() {
        var yeni = agirlikListesi.slice()
        yeni.pop()
        agirlikListesi = yeni
    }

    function agirlikOzeti() {
        if (agirlikListesi.length === 0) return txt("agirlikYok")
        var kucukAgirlikSayisi = 0, buyukAgirlikSayisi = 0   // 1.6 kg ve 4.8 kg'lık parçalar
        for (var i = 0; i < agirlikListesi.length; i++) {
            if (agirlikListesi[i] < 3) kucukAgirlikSayisi++; else buyukAgirlikSayisi++
        }
        var parcalar = []
        if (kucukAgirlikSayisi > 0) parcalar.push(kucukAgirlikSayisi + " x 1.6")
        if (buyukAgirlikSayisi > 0) parcalar.push(buyukAgirlikSayisi + " x 4.8")
        return parcalar.join(" + ") + " = " + agirlikToplam.toFixed(1) + " kg"
    }

    // TS EN 206 / TS 13515 normal beton dayanım sınıfları (C sınıfı) — çimento dozajı
    // ve azami su/çimento oranı, ilgili sınıfın minimum bağlayıcı gereksinimine göre.
    readonly property var receteListesi: [
        { sinifTr: "C16/20", sinifEn: "C16/20", cimentoTr: "min. 260 kg/m³", cimentoEn: "min. 260 kg/m³", suCimentoTr: "maks. 0.65", suCimentoEn: "max. 0.65", aciklamaTr: "Hafif yükte yalın/donatılı beton", aciklamaEn: "Plain/reinforced concrete for light loads" },
        { sinifTr: "C20/25", sinifEn: "C20/25", cimentoTr: "min. 280 kg/m³", cimentoEn: "min. 280 kg/m³", suCimentoTr: "maks. 0.60", suCimentoEn: "max. 0.60", aciklamaTr: "Standart betonarme", aciklamaEn: "Standard reinforced concrete" },
        { sinifTr: "C25/30", sinifEn: "C25/30", cimentoTr: "min. 300 kg/m³", cimentoEn: "min. 300 kg/m³", suCimentoTr: "maks. 0.55", suCimentoEn: "max. 0.55", aciklamaTr: "Standart betonarme (TS EN 206)", aciklamaEn: "Standard reinforced concrete (TS EN 206)" },
        { sinifTr: "C30/37", sinifEn: "C30/37", cimentoTr: "min. 320 kg/m³", cimentoEn: "min. 320 kg/m³", suCimentoTr: "maks. 0.50", suCimentoEn: "max. 0.50", aciklamaTr: "Standart betonarme", aciklamaEn: "Standard reinforced concrete" },
        { sinifTr: "C30/37 SCC", sinifEn: "C30/37 SCC", cimentoTr: "min. 380 kg/m³", cimentoEn: "min. 380 kg/m³", suCimentoTr: "maks. 0.45", suCimentoEn: "max. 0.45", aciklamaTr: "Kendiliğinden yerleşen beton (SF2)", aciklamaEn: "Self-compacting concrete (SF2)" },
        { sinifTr: "C35/45", sinifEn: "C35/45", cimentoTr: "min. 340 kg/m³", cimentoEn: "min. 340 kg/m³", suCimentoTr: "maks. 0.45", suCimentoEn: "max. 0.45", aciklamaTr: "Orta-yüksek dayanım", aciklamaEn: "Medium-high strength" },
        { sinifTr: "C40/50", sinifEn: "C40/50", cimentoTr: "min. 360 kg/m³", cimentoEn: "min. 360 kg/m³", suCimentoTr: "maks. 0.40", suCimentoEn: "max. 0.40", aciklamaTr: "Yüksek dayanım", aciklamaEn: "High strength" },
        { sinifTr: "C45/55", sinifEn: "C45/55", cimentoTr: "min. 380 kg/m³", cimentoEn: "min. 380 kg/m³", suCimentoTr: "maks. 0.38", suCimentoEn: "max. 0.38", aciklamaTr: "Yüksek dayanım", aciklamaEn: "High strength" },
        { sinifTr: "C50/60", sinifEn: "C50/60", cimentoTr: "min. 400 kg/m³", cimentoEn: "min. 400 kg/m³", suCimentoTr: "maks. 0.35", suCimentoEn: "max. 0.35", aciklamaTr: "Yüksek dayanım (TS EN 206 normal beton sınırı)", aciklamaEn: "High strength (TS EN 206 normal concrete limit)" }
    ]

    signal olcumTamamlandi(int id)
    signal agirlikEklendi()

    function resetMeasurementScreen() {
        aktifOlcumId = -1
        uyariMesaji = ""
        bitirIcinDuraklatildi = false
        musteriKutusu.text = ""
        receteKutusu.currentIndex = -1
        receteKutusu.editText = ""
        agirlikListesi = []
        calculator.sifirla()
        kayitDurumunaDon()
    }

    // Grafikleri temizler ve kaydı yeniden "üst konum bekleniyor" durumuna alır.
    function kayitDurumunaDon() {
        kayitDurumu = "BEKLEMEDE"
        inisBasladi = false
        durgunlukBaslangicZamanS = -1
        grafikleriSifirla()
    }

    function baslatOlcumu() {
        if (aktifOlcumId > 0) return

        if (musteriKutusu.text.trim().length === 0) {
            uyariMesaji = txt("uyariMusteriAdi")
            return
        }

        if (receteKutusu.editText.trim().length === 0) {
            uyariMesaji = txt("uyariReceteSec")
            return
        }

        // Sensor verisi (veriGecerli) degil, TCP baglantisi kontrol edilir:
        // sensorler takili olmasa bile (ornegin sadece Wi-Fi/TCP testi icin)
        // ESP32'ye baglanildiysa olcum baslatilabilsin.
        if (!wifiManager.baglandi) {
            console.warn("ESP32'ye baglanti yok, olcum baslatilmadi.")
            uyariMesaji = txt("uyariCihazBagliDegil")
            return
        }

        uyariMesaji = ""
        kayitDurumunaDon()

        calculator.sifirla()
        aktifOlcumId = database.olcumBaslat(
            musteriKutusu.text,
            receteKutusu.editText.trim(),
            agirlikToplam,
            yerKutusu.text,
            ""
        )
        console.log("Aktif olcum id:", aktifOlcumId)
    }

    function bitirTalebiGoster() {
        if (aktifOlcumId > 0) {
            if (!calculator.duraklatildi) {
                calculator.duraklat()
                bitirIcinDuraklatildi = true
            }
            bitirOnayPopup.open()
        } else {
            uyariMesaji = txt("uyariAktifOlcumYok")
        }
    }

    function grafikleriSifirla() {
        zamanSayaci = 0
        baslangicZamaniS = -1
        toplamDuraklamaSuresiS = 0
        zamanGecmis = []
        basincSerisi.clear()
        konumSerisi.clear()
        hizSerisi.clear()
        debiSerisi.clear()
        basincGecmis = []
        konumGecmis = []
        hizGecmis = []
        debiGecmis = []
        zamanEkseniniUygula(0)
        yEkseni.min = 0
        yEkseni.max = 10
        konumYEkseni.min = 0
        konumYEkseni.max = 600
        hizYEkseni.min = 0
        hizYEkseni.max = 1
        debiYEkseni.min = 0
        debiYEkseni.max = 50
    }

    // Zaman ekseni tek bir stroke'u kapsar: veri hangi aralıktaysa eksen de o
    // aralığa oturur, böylece eğri paneli boydan boya doldurur (sabit 0-60 s
    // ekseninde 1.5 saniyelik bir stroke iğne gibi görünüyordu).
    function zamanEkseniniUygula(sonZamanS) {
        var ilkZamanS = zamanGecmis.length > 0 ? zamanGecmis[0] : 0
        // Veri henüz çok kısayken eksen titremesin diye en az bu kadar genişlik tutulur.
        var genislik = Math.max(sonZamanS - ilkZamanS, 1.0)
        var bitis = ilkZamanS + genislik * 1.04
        var eksenler = [xEkseni, konumXEkseni, hizXEkseni, debiXEkseni]
        for (var i = 0; i < eksenler.length; i++) {
            eksenler[i].min = ilkZamanS
            eksenler[i].max = bitis
        }
    }

    // Y ekseni veriye oturtulur. sifirdanBasla: hız/debi gibi sıfırı anlamlı olan
    // büyüklüklerde taban 0'da kalır; basınç ve konum kendi bandına yaklaştırılır.
    function degerEkseniHesapla(dizi, sifirdanBasla, varsayilanTavan) {
        if (dizi.length === 0) return { min: 0, max: varsayilanTavan }
        var maxDeger = Math.max.apply(null, dizi)
        var minDeger = Math.min.apply(null, dizi)
        var kenarBoslugu = Math.max((maxDeger - minDeger) * 0.08, Math.abs(maxDeger) * 0.04, 0.5)
        var taban = sifirdanBasla ? Math.min(0, minDeger) : minDeger - kenarBoslugu
        return { min: taban, max: maxDeger + kenarBoslugu }
    }

    // Kalibrasyondaki üst/alt referansa göre yön: üst < alt ise konum, orijinal
    // SLIPER'daki gibi "sensörden uzaklık"tır (üstte küçük, altta büyük).
    function konumYonu() {
        return calculator.ustKonumMm >= calculator.altKonumMm ? 1 : -1
    }

    // Boru üst sabitleme noktasında mı? (demir mil sensörün önünde)
    function ustKonumda(konumMm) {
        var yukseklikMm = konumYonu() * konumMm
        return yukseklikMm > konumYonu() * calculator.ustKonumMm - ustYakalamaToleransiMm
    }

    // İniş başladığında: elde tutulan son saniyeler t = 0'dan başlayacak şekilde
    // yeniden çizilir, böylece her stroke'un grafiği 0'dan başlar.
    function zamanEkseniniSifirla() {
        if (zamanGecmis.length === 0) return
        var kaydirma = zamanGecmis[0]
        if (kaydirma <= 0) return

        basincSerisi.clear()
        konumSerisi.clear()
        hizSerisi.clear()
        debiSerisi.clear()
        for (var i = 0; i < zamanGecmis.length; i++) {
            zamanGecmis[i] -= kaydirma
            basincSerisi.append(zamanGecmis[i], basincGecmis[i])
            konumSerisi.append(zamanGecmis[i], konumGecmis[i])
            hizSerisi.append(zamanGecmis[i], hizGecmis[i])
            debiSerisi.append(zamanGecmis[i], debiGecmis[i])
        }
        // Sonraki örnekler de aynı eksende kalsın
        baslangicZamaniS += kaydirma
        zamanSayaci -= kaydirma
    }

    // Üst konum yakalandığında kaydı başlatır, iniş bittiğinde grafiği dondurur.
    function kayitDurumunuGuncelle() {
        var konumMm = sensorManager.konum
        var zamanS = sensorManager.zamanS

        // 1) Boru üst sabitleme noktasına alındı: yeni stroke için grafiği sıfırla.
        if (kayitDurumu !== "KAYITTA" && ustKonumda(konumMm)) {
            grafikleriSifirla()
            kayitDurumu = "KAYITTA"
            kayitBaslangicKonumuMm = konumMm
            inisBasladi = false
            durgunlukBaslangicZamanS = -1
            return
        }

        if (kayitDurumu !== "KAYITTA") return

        // 2) İniş gerçekten başladı mı? Üstteki küçük kıpırtılar "iniş bitti" sayılmasın.
        if (!inisBasladi) {
            var inilenYolMm = konumYonu() * (kayitBaslangicKonumuMm - konumMm)
            if (inilenYolMm > inisBaslamaYoluMm) {
                inisBasladi = true
                zamanEkseniniSifirla()
            }
            return
        }

        // 3) İniş durdu mu? Kısa doğrulama süresi, iniş sırasındaki tek örneklik
        //    gürültünün grafiği erken dondurmasını engeller.
        if (Math.abs(sensorManager.hiz) > durmaHiziMs) {
            durgunlukBaslangicZamanS = -1
            return
        }
        if (durgunlukBaslangicZamanS < 0) durgunlukBaslangicZamanS = zamanS
        if (zamanS - durgunlukBaslangicZamanS >= durmaOnayiSuresiS) kayitDurumu = "DONDU"
    }

    Connections {
        target: calculator
        function onDuraklatildiChanged() {
            if (calculator.duraklatildi) {
                duraklamaBaslangicZamanS = sensorManager.zamanS
            } else if (baslangicZamaniS >= 0) {
                toplamDuraklamaSuresiS += sensorManager.zamanS - duraklamaBaslangicZamanS
            }
        }
    }

    Connections {
        target: sensorManager
        function onVeriGuncellendi() {
            if (!sensorManager.veriGecerli || aktifOlcumId <= 0) return
            // Duraklatildiginda grafikler de donmali; aksi halde cihaz
            // hareket ettirilince egriler Calculator durmus olsa bile akmaya devam eder.
            if (calculator.duraklatildi) return

            // Stroke hesabı her örnekle beslenir: grafik donmuş olsa bile borunun
            // oturmasından sonraki P0r penceresi tamamlanmalı, aksi halde p bozulur.
            calculator.konumGuncelle(sensorManager.zamanS, sensorManager.konum, sensorManager.basinc)

            // Üst konum yakalandı mı / iniş bitti mi?
            kayitDurumunuGuncelle()
            if (kayitDurumu !== "KAYITTA") return

            // Zaman ekseni cihazin zaman damgasindan gelir (sabit 0.2 s adim varsayilmaz).
            if (baslangicZamaniS < 0) baslangicZamaniS = sensorManager.zamanS
            zamanSayaci = sensorManager.zamanS - baslangicZamaniS - toplamDuraklamaSuresiS

            basincSerisi.append(zamanSayaci, sensorManager.basinc)
            konumSerisi.append(zamanSayaci, sensorManager.konum)
            hizSerisi.append(zamanSayaci, sensorManager.hiz)
            debiSerisi.append(zamanSayaci, sensorManager.debi)

            zamanGecmis.push(zamanSayaci)
            basincGecmis.push(sensorManager.basinc)
            konumGecmis.push(sensorManager.konum)
            hizGecmis.push(sensorManager.hiz)
            debiGecmis.push(sensorManager.debi)

            // Boru üstte serbest bırakılmayı beklerken yalnızca son birkaç saniye
            // tutulur (bekleme uzasa bile eksen şişmesin); iniş başladıktan sonra
            // stroke'un tamamı korunur, 60 s yalnızca güvenlik sınırıdır.
            var tutulacakSureS = inisBasladi ? 60 : beklemePenceresiS
            while (zamanGecmis.length > 1 && zamanGecmis[0] < zamanSayaci - tutulacakSureS) {
                basincSerisi.remove(0)
                konumSerisi.remove(0)
                hizSerisi.remove(0)
                debiSerisi.remove(0)

                zamanGecmis.shift()
                basincGecmis.shift()
                konumGecmis.shift()
                hizGecmis.shift()
                debiGecmis.shift()
            }

            zamanEkseniniUygula(zamanSayaci)

            var basincAralik = degerEkseniHesapla(basincGecmis, false, 10)
            yEkseni.min = basincAralik.min
            yEkseni.max = basincAralik.max
            var konumAralik = degerEkseniHesapla(konumGecmis, false, 600)
            konumYEkseni.min = konumAralik.min
            konumYEkseni.max = konumAralik.max
            var hizAralik = degerEkseniHesapla(hizGecmis, true, 1)
            hizYEkseni.min = hizAralik.min
            hizYEkseni.max = hizAralik.max
            var debiAralik = degerEkseniHesapla(debiGecmis, true, 50)
            debiYEkseni.min = debiAralik.min
            debiYEkseni.max = debiAralik.max
        }
    }

    // Sesli komutlar: "Başlat / Durdur / Bitir". Bu sayfa arka planda
    // (StackLayout icinde) da yasadigi icin, komutlar sadece Ölçüm sayfasi
    // ekranda goruntulenirken (visible) uygulanir.
    Connections {
        target: voiceCommandManager

        function onBaslatKomutu() {
            if (!visible) return
            baslatOlcumu()
        }

        function onDurdurKomutu() {
            if (!visible || aktifOlcumId <= 0) return
            if (!calculator.duraklatildi) calculator.duraklat()
        }

        function onDevamKomutu() {
            if (!visible || aktifOlcumId <= 0) return
            if (calculator.duraklatildi) calculator.devamEt()
        }

        function onBitirKomutu() {
            if (!visible) return
            bitirTalebiGoster()
        }

        function onEkleKomutu() {
            if (!visible) return
            agirlikEkle(1.6)
        }
    }

    Row {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: testBilgileriPaneli
            width: 280
            height: parent.height
            color: "#12121a"

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                text: txt("testBilgileri")
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Column {
                id: formAlanlari
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                anchors.topMargin: 60
                spacing: 6

                Text {
                    text: txt("olcumYeri")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                TextField {
                    id: yerKutusu
                    width: parent.width
                    height: 34
                    placeholderText: txt("olcumYeriPlaceholder")
                    placeholderTextColor: "#4b5563"
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: yerKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }

                Text {
                    text: txt("musteri")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                TextField {
                    id: musteriKutusu
                    width: parent.width
                    height: 38
                    placeholderText: txt("musteriPlaceholder")
                    placeholderTextColor: "#4b5563"
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: musteriKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                }

                Text {
                    text: txt("betonRecetesi")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: receteKutusu
                    width: parent.width
                    height: 38
                    model: receteListesi
                    textRole: Translations.turkish ? "sinifTr" : "sinifEn"
                    // Orijinal SLIPER'daki "Formula" serbest metindir: hazır sınıf
                    // seçilebilir ya da firmanın kendi karışım kodu yazılabilir.
                    editable: true
                    currentIndex: -1

                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: receteKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }

                    contentItem: TextField {
                        text: receteKutusu.editText
                        placeholderText: txt("recetePlaceholder")
                        placeholderTextColor: "#4b5563"
                        color: "#dce8f5"
                        font.pixelSize: 13
                        leftPadding: 10
                        rightPadding: 30
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        background: null
                        onTextEdited: receteKutusu.editText = text
                    }

                    delegate: ItemDelegate {
                        id: receteDelege
                        width: receteKutusu.width
                        height: modelData.cimentoTr.length > 0 ? 52 : 36
                        highlighted: receteKutusu.highlightedIndex === index

                        background: Rectangle {
                            color: receteDelege.highlighted ? "#17263d" : "#0a0a0d"
                        }

                        contentItem: Column {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            spacing: 2

                            Text {
                                text: Translations.turkish ? modelData.sinifTr : modelData.sinifEn
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Text {
                                visible: modelData.cimentoTr.length > 0
                                text: Translations.turkish
                                    ? (txt("cimentoEtiket") + modelData.cimentoTr + txt("suCimentoEtiket") + modelData.suCimentoTr)
                                    : (txt("cimentoEtiket") + modelData.cimentoEn + txt("suCimentoEtiket") + modelData.suCimentoEn)
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                            }
                        }
                    }
                }

                Text {
                    text: txt("eklenenAgirlik")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                Column {
                    width: parent.width
                    spacing: 8

                    Row {
                        width: parent.width
                        spacing: 8

                        Button {
                            id: agirlikEkleButonu
                            width: (parent.width - 3 * parent.spacing) / 4
                            height: 38
                            text: "+1.6"
                            font.family: "Segoe UI"
                            font.pixelSize: 12

                            onClicked: agirlikEkle(1.6)

                            background: Rectangle {
                                radius: 6
                                color: agirlikEkleButonu.pressed ? "#1e3a8a" : (agirlikEkleButonu.hovered ? "#1e3a8a" : "#1d4ed8")
                                border.color: "#3b82f6"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: agirlikEkleButonu.text
                                color: "#dce8f5"
                                font: agirlikEkleButonu.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            id: agirlikEkle48Butonu
                            width: (parent.width - 3 * parent.spacing) / 4
                            height: 38
                            text: "+4.8"
                            font.family: "Segoe UI"
                            font.pixelSize: 12

                            onClicked: agirlikEkle(4.8)

                            background: Rectangle {
                                radius: 6
                                color: agirlikEkle48Butonu.pressed ? "#1e3a8a" : (agirlikEkle48Butonu.hovered ? "#1e3a8a" : "#1d4ed8")
                                border.color: "#3b82f6"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: agirlikEkle48Butonu.text
                                color: "#dce8f5"
                                font: agirlikEkle48Butonu.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            id: agirlikAzaltButonu
                            width: (parent.width - 3 * parent.spacing) / 4
                            height: 38
                            text: txt("geriButon")
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            enabled: agirlikAdedi > 0

                            onClicked: agirlikGeriAl()

                            background: Rectangle {
                                radius: 6
                                color: agirlikAzaltButonu.pressed ? "#78350f" : (agirlikAzaltButonu.hovered ? "#a16207" : "#92400e")
                                opacity: agirlikAzaltButonu.enabled ? 1.0 : 0.4
                                border.color: "#d97706"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: agirlikAzaltButonu.text
                                color: "#dce8f5"
                                opacity: agirlikAzaltButonu.enabled ? 1.0 : 0.6
                                font: agirlikAzaltButonu.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            id: sifirlaButonu
                            width: (parent.width - 3 * parent.spacing) / 4
                            height: 38
                            text: txt("sifirlaButon")
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            enabled: agirlikAdedi > 0

                            onClicked: agirlikListesi = []

                            background: Rectangle {
                                radius: 6
                                color: sifirlaButonu.pressed ? "#7f1d1d" : (sifirlaButonu.hovered ? "#b91c1c" : "#991b1b")
                                opacity: sifirlaButonu.enabled ? 1.0 : 0.4
                                border.color: "#dc2626"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: sifirlaButonu.text
                                color: "#dce8f5"
                                opacity: sifirlaButonu.enabled ? 1.0 : 0.6
                                font: sifirlaButonu.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: 6
                        color: "#0a0a0d"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: agirlikOzeti()
                            color: agirlikAdedi > 0 ? "#dce8f5" : "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }
                }

                Item { width: parent.width; height: 10 }

                Button {
                    id: baslatButonu
                    width: parent.width
                    height: 44
                    text: txt("olcumuBaslatButon")
                    font.family: "Segoe UI"
                    font.pixelSize: 14
                    font.bold: true
                    enabled: aktifOlcumId <= 0

                    onClicked: baslatOlcumu()

                    background: Rectangle {
                        radius: 8
                        color: !baslatButonu.enabled ? "#14532d" : (baslatButonu.pressed ? "#15803d" : (baslatButonu.hovered ? "#22c55e" : "#16a34a"))
                        opacity: baslatButonu.enabled ? 1.0 : 0.5
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: baslatButonu.text
                        color: "#dce8f5"
                        opacity: baslatButonu.enabled ? 1.0 : 0.6
                        font: baslatButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    width: parent.width
                    visible: uyariMesaji.length > 0
                    text: uyariMesaji
                    color: "#f87171"
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }

                Row {
                    width: parent.width
                    spacing: 10

                    Button {
                        id: duraklatButonu
                        width: (parent.width - parent.spacing) / 2
                        height: 40
                        text: calculator.duraklatildi ? txt("devamEtButon") : txt("duraklatButon")
                        font.family: "Segoe UI"
                        font.pixelSize: 13

                        onClicked: {
                            if (calculator.duraklatildi) {
                                calculator.devamEt()
                            } else {
                                calculator.duraklat()
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: duraklatButonu.pressed ? "#78350f" : (duraklatButonu.hovered ? "#a16207" : "#92400e")
                            border.color: "#d97706"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: duraklatButonu.text
                            color: "#dce8f5"
                            font: duraklatButonu.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: bitirButonu
                        width: (parent.width - parent.spacing) / 2
                        height: 40
                        text: txt("bitirButon")
                        font.family: "Segoe UI"
                        font.pixelSize: 13

                        onClicked: bitirTalebiGoster()

                        background: Rectangle {
                            radius: 8
                            color: bitirButonu.pressed ? "#7f1d1d" : (bitirButonu.hovered ? "#b91c1c" : "#991b1b")
                            border.color: "#dc2626"
                            border.width: 1
                        }

                        contentItem: Text {
                            text: bitirButonu.text
                            color: "#dce8f5"
                            font: bitirButonu.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Rectangle {
                id: durumKarti
                anchors.top: formAlanlari.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                height: 52
                radius: 10
                color: "#0a0a0d"
                border.color: "#1e2a3f"
                border.width: 1

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 14
                    spacing: 10

                    Rectangle {
                        id: trafikIsigi
                        width: 12
                        height: 12
                        radius: 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: {
                            if (!sensorManager.veriGecerli) return "#dc2626"
                            if (calculator.duraklatildi) return "#6b7280"
                            if (aktifOlcumId > 0 && kayitDurumu === "BEKLEMEDE") return "#3b82f6"
                            if (aktifOlcumId > 0 && kayitDurumu === "DONDU") return "#6b7280"
                            if (calculator.durum === "YUKARIDA") return "#16a34a"
                            if (calculator.durum === "INIYOR") return "#f59e0b"
                            return "#dc2626"
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 8
                            height: parent.height + 8
                            radius: width / 2
                            color: "transparent"
                            border.color: parent.color
                            border.width: 1
                            opacity: 0.35
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (!sensorManager.veriGecerli) return txt("veriYok")
                            if (calculator.duraklatildi) return txt("duraklatildiDurum")
                            if (aktifOlcumId > 0 && kayitDurumu === "BEKLEMEDE") return txt("ustKonumBekleniyor")
                            if (aktifOlcumId > 0 && kayitDurumu === "DONDU") return txt("grafikDonduDurum")
                            return calculator.durum
                        }
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 14
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "STROKE"
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: calculator.strokeSayisi
                        color: "#4f8cf7"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }

            Text {
                id: anlikDegerlerBaslik
                anchors.top: durumKarti.bottom
                anchors.left: parent.left
                anchors.topMargin: 24
                anchors.leftMargin: 20
                text: txt("anlikDegerler")
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Grid {
                anchors.top: anlikDegerlerBaslik.bottom
                anchors.left: parent.left
                anchors.topMargin: 12
                anchors.leftMargin: 20
                columns: 2
                spacing: 10

                Rectangle {
                    id: basincKarti
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0a0d"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#3b82f6" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: txt("basincEtiket")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: gosterilenVeriGecerli ? gosterilenBasinc.toFixed(1) : "--"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "mbar"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0a0d"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#9333ea" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: txt("konumEtiket")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: gosterilenVeriGecerli ? gosterilenKonum.toFixed(1) : "--"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "mm"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0a0d"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#f59e0b" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: txt("hizEtiket")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: gosterilenVeriGecerli ? gosterilenHiz.toFixed(2) : "--"
                            color: "#f59e0b"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "m/s"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }

                Rectangle {
                    width: 115
                    height: 90
                    radius: 10
                    color: "#0a0a0d"
                    border.color: "#1e2a3f"
                    border.width: 1
                    clip: true

                    Rectangle { width: 4; height: parent.height; color: "#16a34a" }

                    Column {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.rightMargin: 10
                        anchors.bottomMargin: 10
                        anchors.leftMargin: 16
                        spacing: 6

                        Text {
                            text: txt("debiEtiket")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                            font.letterSpacing: 1
                        }

                        Text {
                            text: gosterilenVeriGecerli ? gosterilenDebi.toFixed(1) : "--"
                            color: "#16a34a"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Text {
                            text: "m3/h"
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 10
                        }
                    }
                }
            }
        }

        Rectangle {
            id: panelAyraci
            width: 3
            height: parent.height
            color: "#060607"

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: "#403b82f6"
            }
        }

        Item {
            width: parent.width - testBilgileriPaneli.width - panelAyraci.width
            height: parent.height

            Rectangle {
                id: sonStrokeCubugu
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                height: 52
                radius: 10
                color: "#12121a"
                border.color: calculator.sonStroke.no === undefined ? "#1e2a3f"
                              : (calculator.sonStroke.gecerli ? "#166534" : "#7f1d1d")
                border.width: 1

                readonly property var s: calculator.sonStroke
                readonly property bool var_: s.no !== undefined

                function nedenMetni(kod) {
                    if (kod === "hiz") return txt("nedenHiz")
                    if (kod === "basinc") return txt("nedenBasinc")
                    if (kod === "ornek") return txt("nedenOrnek")
                    return ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: !sonStrokeCubugu.var_
                    // Ölçüm başlatıldıysa kullanıcıya kaydın neyi beklediği anlatılır.
                    text: (aktifOlcumId > 0 && kayitDurumu === "BEKLEMEDE") ? txt("ustKonumIpucu") : txt("strokeYok")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 22
                    visible: sonStrokeCubugu.var_

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: txt("sonStroke") + "  #" + (sonStrokeCubugu.var_ ? sonStrokeCubugu.s.no : "")
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Repeater {
                        model: sonStrokeCubugu.var_ ? [
                            { e: txt("sure"), d: sonStrokeCubugu.s.sure.toFixed(2) + " s" },
                            { e: "Pmax", d: sonStrokeCubugu.s.pMaks.toFixed(1) + " mbar" },
                            { e: "P0l", d: sonStrokeCubugu.s.p0l.toFixed(1) + " mbar" },
                            { e: "P0r", d: sonStrokeCubugu.s.p0r.toFixed(1) + " mbar" },
                            { e: "p", d: sonStrokeCubugu.s.basinc.toFixed(2) + " mbar" },
                            { e: "Q", d: sonStrokeCubugu.s.debi.toFixed(2) + " m³/h" },
                            { e: "v", d: sonStrokeCubugu.s.hiz.toFixed(3) + " m/s" }
                        ] : []

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text { text: modelData.e; color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 10 }
                            Text { text: modelData.d; color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 13; font.bold: true }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    visible: sonStrokeCubugu.var_
                    width: gecerlilikMetni.implicitWidth + 18
                    height: 24
                    radius: 12
                    color: sonStrokeCubugu.var_ && sonStrokeCubugu.s.gecerli ? "#123321" : "#2a1414"

                    Text {
                        id: gecerlilikMetni
                        anchors.centerIn: parent
                        text: !sonStrokeCubugu.var_ ? "" : (sonStrokeCubugu.s.gecerli ? txt("gecerliStroke")
                              : txt("hataliStroke") + " (" + sonStrokeCubugu.nedenMetni(sonStrokeCubugu.s.gecersizNedeni) + ")")
                        color: sonStrokeCubugu.var_ && sonStrokeCubugu.s.gecerli ? "#4ade80" : "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            Grid {
                anchors.top: sonStrokeCubugu.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                anchors.topMargin: 8
                columns: 2
                spacing: 8

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#12121a"
                    border.color: "#1b1b23"
                    border.width: 1

                    Item {
                        id: basincBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("basincZaman")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: basincBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 6
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true
                        margins.top: 4
                        margins.bottom: 4
                        margins.left: 4
                        margins.right: 12

                        ValueAxis {
                            id: xEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: yEkseni
                            min: 0
                            max: 1100
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: basincSerisi
                            axisX: xEkseni
                            axisY: yEkseni
                            color: "#3b82f6"
                            width: 3
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#12121a"
                    border.color: "#241a38"
                    border.width: 1

                    Item {
                        id: konumBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("konumZaman")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: konumBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 6
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true
                        margins.top: 4
                        margins.bottom: 4
                        margins.left: 4
                        margins.right: 12

                        ValueAxis {
                            id: konumXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: konumYEkseni
                            min: 0
                            max: 500
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: konumSerisi
                            axisX: konumXEkseni
                            axisY: konumYEkseni
                            color: "#9333ea"
                            width: 3
                        }

                        Connections {
                            target: calculator
                            // Stroke sonunda anlik degerler degil, Calculator'un tum stroke
                            // uzerinden hesapladigi p = Pmax - P0 ve Q = A*v kaydedilir.
                            // Stroke, borunun bırakıldığı andaki ağırlıkla kaydedilir
                            // (bitiş sonrası 2 s içinde ağırlık değiştirilse bile).
                            function onDurumChanged() {
                                if (calculator.durum === "INIYOR") strokeAgirligi = agirlikToplam
                            }
                            function onStrokeTamamlandi(stroke) {
                                if (aktifOlcumId > 0) {
                                    database.strokeKaydet(aktifOlcumId, stroke, strokeAgirligi >= 0 ? strokeAgirligi : agirlikToplam)
                                }
                                strokeAgirligi = -1
                            }
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#12121a"
                    border.color: "#1e2a3f"
                    border.width: 1

                    Item {
                        id: hizBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("hizZaman")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: hizBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 6
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true
                        margins.top: 4
                        margins.bottom: 4
                        margins.left: 4
                        margins.right: 12

                        ValueAxis {
                            id: hizXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: hizYEkseni
                            min: 0
                            max: 4
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: hizSerisi
                            axisX: hizXEkseni
                            axisY: hizYEkseni
                            color: "#f59e0b"
                            width: 3
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    radius: 10
                    color: "#12121a"
                    border.color: "#163321"
                    border.width: 1

                    Item {
                        id: debiBaslik
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("debiZaman")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: debiBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 6
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true
                        margins.top: 4
                        margins.bottom: 4
                        margins.left: 4
                        margins.right: 12

                        ValueAxis {
                            id: debiXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: debiYEkseni
                            min: 0
                            max: 180
                            gridLineColor: "#1a1a20"
                            labelsColor: "#6b7280"
                            labelsFont.pixelSize: 12
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: debiSerisi
                            axisX: debiXEkseni
                            axisY: debiYEkseni
                            color: "#16a34a"
                            width: 3
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: veriKesintiUyarisi
        visible: wifiManager.baglandi && !sensorManager.veriGecerli
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 12
        width: kesintiMetni.implicitWidth + 32
        height: 36
        radius: 8
        color: "#7f1d1d"
        border.color: "#dc2626"
        border.width: 1
        z: 20
        Text {
            id: kesintiMetni
            anchors.centerIn: parent
            text: txt("veriAkisiKesildi")
            color: "#fecaca"
            font.family: "Segoe UI"
            font.pixelSize: 13
            font.bold: true
        }
    }

    // Sesli komut geri bildirimi: eller kirliyken dokunmadan "Başlat /
    // Durdur / Bitir" denildiginde ne duyuldugunu gostererek kullaniciya
    // guven verir.
    Rectangle {
        id: sesliKomutRozeti
        visible: voiceCommandManager.etkin
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16
        width: sesliKomutIcerik.implicitWidth + 24
        height: sesliKomutIcerik.implicitHeight + 16
        radius: 10
        color: "#0a0a0d"
        border.color: voiceCommandManager.dinliyor ? "#16a34a" : "#1e2a3f"
        border.width: 1
        z: 10

        Column {
            id: sesliKomutIcerik
            anchors.centerIn: parent
            spacing: 4

            Row {
                spacing: 6
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: voiceCommandManager.dinliyor ? "#16a34a" : "#6b7280"
                }
                Text {
                    text: voiceCommandManager.dinliyor ? txt("sesliDinleniyor") : txt("sesliHazirlaniyor")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                }
            }

            Text {
                visible: voiceCommandManager.anlikMetin.length > 0
                text: txt("duyulanEtiket") + voiceCommandManager.anlikMetin
                color: "#4b5563"
                font.family: "Segoe UI"
                font.pixelSize: 10
                font.italic: true
            }
        }
    }

    Popup {
        id: bitirOnayPopup
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 340
        padding: 24
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#12121a"
            radius: 12
            border.color: "#1e2a3f"
            border.width: 1
        }

        Overlay.modal: Rectangle {
            color: "#a6000000"
        }

        contentItem: Column {
            spacing: 20

            Text {
                width: 292
                text: txt("bitirOnaySorusu")
                color: "#dce8f5"
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Column {
                width: 292
                spacing: 10

                Button {
                    id: kaydetBitirButonu
                    width: parent.width
                    height: 40
                    text: txt("kaydetVeBitir")
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: {
                        bitirOnayPopup.close()
                        var bitenId = aktifOlcumId
                        console.log("Olcum kaydedilip sonlandirildi, id:", bitenId)
                        resetMeasurementScreen()
                        olcumTamamlandi(bitenId)
                    }

                    background: Rectangle {
                        radius: 8
                        color: kaydetBitirButonu.pressed ? "#14532d" : (kaydetBitirButonu.hovered ? "#15803d" : "#16a34a")
                        border.color: "#22c55e"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: kaydetBitirButonu.text
                        color: "#dce8f5"
                        font: kaydetBitirButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: silBitirButonu
                    width: parent.width
                    height: 40
                    text: txt("testiSilVeBitir")
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: {
                        bitirOnayPopup.close()
                        var silinecekId = aktifOlcumId
                        var basarili = database.olcumSil(silinecekId)
                        console.log("Olcum silinip sonlandirildi, id:", silinecekId, "basarili:", basarili)
                        resetMeasurementScreen()
                    }

                    background: Rectangle {
                        radius: 8
                        color: silBitirButonu.pressed ? "#7f1d1d" : (silBitirButonu.hovered ? "#b91c1c" : "#991b1b")
                        border.color: "#dc2626"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: silBitirButonu.text
                        color: "#dce8f5"
                        font: silBitirButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    id: vazgecButonu
                    width: parent.width
                    height: 40
                    text: txt("vazgecTesteDevam")
                    font.family: "Segoe UI"
                    font.pixelSize: 13

                    onClicked: {
                        bitirOnayPopup.close()
                        if (bitirIcinDuraklatildi) {
                            calculator.devamEt()
                            bitirIcinDuraklatildi = false
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: vazgecButonu.pressed ? "#1e2a3f" : (vazgecButonu.hovered ? "#243349" : "#1a1a20")
                        border.color: "#2c3b52"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: vazgecButonu.text
                        color: "#dce8f5"
                        font: vazgecButonu.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}