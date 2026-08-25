import QtQuick 6.7
import QtQuick.Controls 6.7
import QtCharts 6.7
import sliper

Rectangle {
    color: "#0a0a0d"

    readonly property var metinler: ({
        testBilgileri: { tr: "TEST BİLGİLERİ", en: "TEST INFORMATION" },
        musteri: { tr: "Müşteri", en: "Customer" },
        musteriPlaceholder: { tr: "Musteri adi girin...", en: "Enter customer name..." },
        betonRecetesi: { tr: "Beton Reçetesi", en: "Concrete Mix Design" },
        receteSeciniz: { tr: "Reçete Seçin...", en: "Select Mix Design..." },
        cimentoEtiket: { tr: "Çimento ", en: "Cement " },
        suCimentoEtiket: { tr: "  •  Su/Çimento ", en: "  •  Water/Cement " },
        eklenenAgirlik: { tr: "Eklenen Ağırlık (kg)", en: "Added Weight (kg)" },
        geriButon: { tr: "− Geri", en: "− Undo" },
        sifirlaButon: { tr: "↺ Sıfırla", en: "↺ Reset" },
        olcumuBaslatButon: { tr: "▶  Ölçümü Başlat", en: "▶  Start Measurement" },
        devamEtButon: { tr: "▶  Devam Et", en: "▶  Resume" },
        duraklatButon: { tr: "⏸  Duraklat", en: "⏸  Pause" },
        bitirButon: { tr: "⏹  Bitir", en: "⏹  Finish" },
        veriYok: { tr: "VERI YOK", en: "NO DATA" },
        duraklatildiDurum: { tr: "DURAKLATILDI", en: "PAUSED" },
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
        uyariReceteSec: { tr: "Lütfen bir beton reçetesi seçin.", en: "Please select a concrete mix design." },
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

    property var basincGecmis: []
    property var konumGecmis: []
    property var hizGecmis: []
    property var debiGecmis: []

    readonly property real agirlikBirim: 1.6
    property int agirlikAdedi: 0
    readonly property real agirlikToplam: agirlikAdedi * agirlikBirim

    // TS EN 206 / TS 13515 normal beton dayanım sınıfları (C sınıfı) — çimento dozajı
    // ve azami su/çimento oranı, ilgili sınıfın minimum bağlayıcı gereksinimine göre.
    readonly property var receteListesi: [
        { sinifTr: "Reçete Seçin...", sinifEn: "Select Mix Design...", cimentoTr: "", cimentoEn: "", suCimentoTr: "", suCimentoEn: "", aciklamaTr: "", aciklamaEn: "" },
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
        receteKutusu.currentIndex = 0
        agirlikAdedi = 0
        calculator.sifirla()
        grafikleriSifirla()
    }

    function baslatOlcumu() {
        if (aktifOlcumId > 0) return

        if (musteriKutusu.text.trim().length === 0) {
            uyariMesaji = txt("uyariMusteriAdi")
            return
        }

        if (receteKutusu.currentIndex <= 0) {
            uyariMesaji = txt("uyariReceteSec")
            return
        }

        if (!sensorManager.veriGecerli) {
            console.warn("Gercek sensor verisi yok, olcum baslatilmadi.")
            uyariMesaji = txt("uyariCihazBagliDegil")
            return
        }

        uyariMesaji = ""
        grafikleriSifirla()

        calculator.sifirla()
        aktifOlcumId = database.olcumBaslat(
            musteriKutusu.text,
            receteKutusu.currentText,
            agirlikToplam
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
        basincSerisi.clear()
        konumSerisi.clear()
        hizSerisi.clear()
        debiSerisi.clear()
        basincGecmis = []
        konumGecmis = []
        hizGecmis = []
        debiGecmis = []
        xEkseni.min = 0
        xEkseni.max = 60
        yEkseni.min = 0
        yEkseni.max = 1100
        konumXEkseni.min = 0
        konumXEkseni.max = 60
        konumYEkseni.max = 500
        hizXEkseni.min = 0
        hizXEkseni.max = 60
        hizYEkseni.max = 4
        debiXEkseni.min = 0
        debiXEkseni.max = 60
        debiYEkseni.max = 180
    }

    function eksenTavaniHesapla(dizi, tavan, taban) {
        if (dizi.length === 0) return taban
        var maxDeger = Math.max.apply(null, dizi)
        var hedef = maxDeger * 1.25
        if (hedef < taban) hedef = taban
        if (hedef > tavan) hedef = tavan
        return hedef
    }

    // Basınç (mbar) atmosferik seviyede sabit bir taban etrafında dalgalanır,
    // bu yüzden sabit tavanlı ölçekleme yerine veriye göre kayan min/max kullanılır.
    function basincEkseniHesapla(dizi) {
        if (dizi.length === 0) return { min: 0, max: 1100 }
        var maxDeger = Math.max.apply(null, dizi)
        var minDeger = Math.min.apply(null, dizi)
        var pad = Math.max((maxDeger - minDeger) * 0.2, maxDeger * 0.02, 5)
        return { min: Math.max(0, minDeger - pad), max: maxDeger + pad }
    }

    Connections {
        target: sensorManager
        function onVeriGuncellendi() {
            if (!sensorManager.veriGecerli || aktifOlcumId <= 0 || calculator.duraklatildi) return

            zamanSayaci += 0.2

            basincSerisi.append(zamanSayaci, sensorManager.basinc)
            konumSerisi.append(zamanSayaci, sensorManager.konum)
            hizSerisi.append(zamanSayaci, sensorManager.hiz)
            debiSerisi.append(zamanSayaci, sensorManager.debi)

            basincGecmis.push(sensorManager.basinc)
            konumGecmis.push(sensorManager.konum)
            hizGecmis.push(sensorManager.hiz)
            debiGecmis.push(sensorManager.debi)

            if (zamanSayaci > 60) {
                basincSerisi.remove(0)
                konumSerisi.remove(0)
                hizSerisi.remove(0)
                debiSerisi.remove(0)

                basincGecmis.shift()
                konumGecmis.shift()
                hizGecmis.shift()
                debiGecmis.shift()

                xEkseni.min = zamanSayaci - 60
                xEkseni.max = zamanSayaci
                konumXEkseni.min = zamanSayaci - 60
                konumXEkseni.max = zamanSayaci
                hizXEkseni.min = zamanSayaci - 60
                hizXEkseni.max = zamanSayaci
                debiXEkseni.min = zamanSayaci - 60
                debiXEkseni.max = zamanSayaci
            }

            var basincAralik = basincEkseniHesapla(basincGecmis)
            yEkseni.min = basincAralik.min
            yEkseni.max = basincAralik.max
            konumYEkseni.max = eksenTavaniHesapla(konumGecmis, 500, 50)
            hizYEkseni.max = eksenTavaniHesapla(hizGecmis, 4, 0.5)
            debiYEkseni.max = eksenTavaniHesapla(debiGecmis, 180, 10)

            calculator.konumGuncelle(sensorManager.konum, sensorManager.hiz)
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
            agirlikAdedi += 1
            agirlikEklendi()
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

                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: receteKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: receteKutusu.displayText
                        color: "#9ca3af"
                        font.pixelSize: 13
                        leftPadding: 10
                        verticalAlignment: Text.AlignVCenter
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
                            width: (parent.width - 2 * parent.spacing) / 3
                            height: 38
                            text: "+ 1.6"
                            font.family: "Segoe UI"
                            font.pixelSize: 12

                            onClicked: {
                                agirlikAdedi += 1
                                agirlikEklendi()
                            }

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
                            id: agirlikAzaltButonu
                            width: (parent.width - 2 * parent.spacing) / 3
                            height: 38
                            text: txt("geriButon")
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            enabled: agirlikAdedi > 0

                            onClicked: agirlikAdedi -= 1

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
                            width: (parent.width - 2 * parent.spacing) / 3
                            height: 38
                            text: txt("sifirlaButon")
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            enabled: agirlikAdedi > 0

                            onClicked: agirlikAdedi = 0

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
                            text: agirlikAdedi + " x " + agirlikBirim.toFixed(1) + " = " + agirlikToplam.toFixed(1) + " kg"
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
                            text: sensorManager.veriGecerli ? sensorManager.basinc.toFixed(1) : "--"
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
                            text: sensorManager.veriGecerli ? sensorManager.konum.toFixed(1) : "--"
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
                            text: sensorManager.veriGecerli ? sensorManager.hiz.toFixed(1) : "--"
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
                            text: sensorManager.veriGecerli ? sensorManager.debi.toFixed(1) : "--"
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

            Grid {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                spacing: 16

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
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: basincNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#3b82f6"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: basincNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("basincZaman")
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.basinc.toFixed(1) + " mbar" : "-- mbar"
                            color: "#3b82f6"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: basincBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: xEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: yEkseni
                            min: 0
                            max: 1100
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: basincSerisi
                            axisX: xEkseni
                            axisY: yEkseni
                            color: "#3b82f6"
                            width: 2
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
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: konumNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#9333ea"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: konumNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("konumZaman")
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.konum.toFixed(1) + " mm" : "-- mm"
                            color: "#9333ea"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: konumBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: konumXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: konumYEkseni
                            min: 0
                            max: 500
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: konumSerisi
                            axisX: konumXEkseni
                            axisY: konumYEkseni
                            color: "#9333ea"
                            width: 2
                        }

                        Connections {
                            target: calculator
                            function onStrokeSayisiChanged() {
                                if (aktifOlcumId > 0 && sensorManager.veriGecerli) {
                                    // gecerli parametresi artik Calculator'un hiz>0 kontrolunden geliyor
                                    // (orijinal SLIPER'daki "invalid stroke" mantigi), sabit "true" degil.
                                    database.strokeKaydet(aktifOlcumId, sensorManager.basinc, sensorManager.konum, sensorManager.debi, calculator.sonStrokeGecerli)
                                }
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
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: hizNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#f59e0b"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: hizNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("hizZaman")
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.hiz.toFixed(1) + " m/s" : "-- m/s"
                            color: "#f59e0b"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: hizBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: hizXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: hizYEkseni
                            min: 0
                            max: 4
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: hizSerisi
                            axisX: hizXEkseni
                            axisY: hizYEkseni
                            color: "#f59e0b"
                            width: 2
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
                        anchors.margins: 14
                        height: 20

                        Rectangle {
                            id: debiNoktasi
                            width: 8
                            height: 8
                            radius: 4
                            color: "#16a34a"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.left: debiNoktasi.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: txt("debiZaman")
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: sensorManager.veriGecerli ? sensorManager.debi.toFixed(1) + " m3/h" : "-- m3/h"
                            color: "#16a34a"
                            font.family: "Segoe UI"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    ChartView {
                        anchors.top: debiBaslik.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 4
                        anchors.bottomMargin: 4
                        backgroundColor: "transparent"
                        legend.visible: false
                        antialiasing: true

                        ValueAxis {
                            id: debiXEkseni
                            min: 0
                            max: 60
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        ValueAxis {
                            id: debiYEkseni
                            min: 0
                            max: 180
                            gridLineColor: "#1a1a20"
                            labelsColor: "#4b5563"
                            labelsFont.pixelSize: 9
                            lineVisible: false
                            minorGridVisible: false
                        }

                        LineSeries {
                            id: debiSerisi
                            axisX: debiXEkseni
                            axisY: debiYEkseni
                            color: "#16a34a"
                            width: 2
                        }
                    }
                }
            }
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