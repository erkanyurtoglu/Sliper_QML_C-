import QtQuick 6.7
import QtQuick.Controls 6.7
import QtQuick.Layouts 6.7
import "../components"
import sliper

Rectangle {
    color: "#0a0e17"

    readonly property var metinler: ({
        baslikSensorSec: { tr: "KALİBRASYON — Sensör Seçin", en: "CALIBRATION — Select Sensor" },
        egimSensoru: { tr: "Eğim Sensörü", en: "Incline Sensor" },
        egimAciklama: { tr: "Yatay hizalama kalibrasyonu", en: "Level alignment calibration" },
        kalibreEdildiOnEk: { tr: "✓ Kalibre Edildi: ", en: "✓ Calibrated: " },
        loadCellAdi: { tr: "Load Cell", en: "Load Cell" },
        loadCellAciklama: { tr: "Basınç sensörü kalibrasyonu", en: "Load pressure sensor calibration" },
        mesafeSensoru: { tr: "Mesafe Sensörü", en: "Distance Sensor" },
        mesafeAciklama: { tr: "Konum ölçümü kalibrasyonu", en: "Position measurement calibration" },
        geriButon: { tr: "← Geri", en: "← Back" },
        egimBaslik: { tr: "Eğim Sensörü Kalibrasyonu", en: "Incline Sensor Calibration" },
        loadCellBaslik: { tr: "Load Cell Kalibrasyonu", en: "Load Cell Calibration" },
        mesafeBaslik: { tr: "Mesafe Sensörü Kalibrasyonu", en: "Distance Sensor Calibration" },
        sonKalibrasyonOnEk: { tr: "Son kalibrasyon: ", en: "Last calibration: " },
        cihaziYerlestir: { tr: "Cihazı düz ve sabit bir yüzeye yerleştirin", en: "Place the device on a flat, stable surface" },
        cihazBagliDegilKalibrasyon: { tr: "Cihaz bağlı değil — kalibrasyon kaydedilemez", en: "Device not connected — calibration cannot be saved" },
        sifirlaButon: { tr: "Sıfırla (Zero)", en: "Zero (Reset)" },
        kalibrasyonKaydedildiMesaj: { tr: "✓ Kalibrasyon kaydedildi", en: "✓ Calibration saved" },
        kalibrasyonKaydedilemediMesaj: { tr: "✕ Kalibrasyon kaydedilemedi, tekrar deneyin", en: "✕ Calibration could not be saved, try again" },
        kayitliOnEk: { tr: "Kayıtlı: ", en: "Saved: " },
        noktaSonEk: { tr: " nokta", en: " points" },
        kayitliKalibrasyonBulundu: { tr: "Bu sensör için kayıtlı bir kalibrasyon bulundu", en: "A saved calibration was found for this sensor" },
        mevcutGoruntule: { tr: "Mevcut Kalibrasyonu Görüntüle", en: "View Current Calibration" },
        kayitliNoktalariIncele: { tr: "Kayıtlı noktaları incele", en: "Review saved points" },
        yenidenKalibreEt: { tr: "Yeniden Kalibre Et", en: "Recalibrate" },
        sifirdanYeniOlcum: { tr: "Sıfırdan yeni ölçüm al", en: "Take a fresh measurement" },
        kayitliNoktalarBaslik: { tr: "KAYITLI KALİBRASYON NOKTALARI", en: "SAVED CALIBRATION POINTS" },
        duzenleButon: { tr: "Düzenle", en: "Edit" },
        silinecekOnay: { tr: "Mevcut kalibrasyon silinecek, emin misiniz?", en: "The current calibration will be deleted, are you sure?" },
        vazgecButon: { tr: "Vazgeç", en: "Cancel" },
        evetYenidenBaslaButon: { tr: "Evet, Yeniden Başla", en: "Yes, Start Over" },
        kalibrasyonTamamlandiBaslik: { tr: "Kalibrasyon Tamamlandı", en: "Calibration Complete" },
        toplamOnEk: { tr: "Toplam ", en: "Total " },
        noktaGirildiSonEk: { tr: " nokta girildi. Bu kalibrasyonu kaydetmek istiyor musunuz?", en: " points entered. Do you want to save this calibration?" },
        noktalariKontrolEt: { tr: "Noktaları Kontrol Et", en: "Review Points" },
        kaydetVeBitir: { tr: "Kaydet ve Bitir", en: "Save and Finish" },
        kacNoktaSoru: { tr: "Kaç noktalı kalibrasyon yapmak istersiniz?", en: "How many calibration points would you like to use?" },
        dahaFazlaNokta: { tr: "Daha fazla nokta, daha hassas kalibrasyon sağlar", en: "More points provide a more precise calibration" },
        hamDegerOnEk: { tr: "Ham değer: ", en: "Raw value: " },
        hamDegerSifirUyari: { tr: "Cihaz bağlı değil — ham değer 0 olarak kaydedilecek", en: "Device not connected — raw value will be saved as 0" },
        degisiklikleriKaydet: { tr: "Değişiklikleri Kaydet", en: "Save Changes" },
        kaydedilenNoktalarBaslik: { tr: "KAYDEDİLEN NOKTALAR", en: "SAVED POINTS" },
        duzeltmekIcinTikla: { tr: "Düzeltmek için bir noktaya tıkla", en: "Click a point to correct it" },
        kalibrasyonuDuzenle: { tr: "Kalibrasyonu Düzenle", en: "Edit Calibration" },
        noktaOnEk: { tr: "Nokta ", en: "Point " },
        duzenleniyorSonEk: { tr: " düzenleniyor", en: " being edited" },
        duzenlemekIcinTikla: { tr: "Düzenlemek istediğiniz noktaya sağdaki listeden tıklayın", en: "Click the point you want to edit from the list on the right" },
        hedefAgirlikYonerge: { tr: "Hedef ağırlığı gir, sonra o ağırlığı load cell'e koy", en: "Enter the target weight, then place that weight on the load cell" },
        hedefMesafeYonerge: { tr: "Hedef mesafeyi gir, sonra boruyu o mesafeye getir", en: "Enter the target distance, then move the tube to that distance" },
        noktayiGuncelle: { tr: "Noktayı Güncelle", en: "Update Point" },
        kalibrasyonuTamamla: { tr: "Kalibrasyonu Tamamla", en: "Complete Calibration" },
        sonNoktayiKaydet: { tr: "Son Noktayı Kaydet", en: "Save Last Point" },
        buNoktayiKaydet: { tr: "Bu Noktayı Kaydet", en: "Save This Point" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    property int seciliSensor: -1
    property int loadCellAdimi: 0

    property bool egimKayitliVar: false
    property string egimSonTarih: ""
    property bool egimBildirimGoster: false
    property bool egimBildirimBasarili: true
    property string egimBildirimMesaj: ""

    property bool loadCellKayitliVar: false
    property string loadCellSonTarih: ""
    property int loadCellNoktaSayisi: 0
    property var loadCellNoktalari: []
    onLoadCellNoktalariChanged: loadCellAdimi = loadCellNoktalari.length
    property int loadCellToplamNokta: 10
    property bool loadCellSayiSecildi: false
    property int loadCellDuzenlemeIndex: -1

    property bool loadCellAraEkranGoster: false
    property bool loadCellGoruntuleModu: false
    property bool loadCellTamDuzenlemeModu: false
    property bool loadCellYenidenOnayGoster: false
    property bool loadCellTamamlandiOnayGoster: false

    property bool loadCellBildirimGoster: false
    property bool loadCellBildirimBasarili: true
    property string loadCellBildirimMesaj: ""

    property string mesafeSonTarih: ""

    property bool mesafeOlcumKayitliVar: false
    property int mesafeOlcumNoktaSayisi: 0
    property var mesafeNoktalari: []
    property int mesafeToplamNokta: 10
    property bool mesafeSayiSecildi: false
    property int mesafeDuzenlemeIndex: -1

    property bool mesafeAraEkranGoster: false
    property bool mesafeGoruntuleModu: false
    property bool mesafeTamDuzenlemeModu: false
    property bool mesafeYenidenOnayGoster: false
    property bool mesafeTamamlandiOnayGoster: false

    property bool mesafeBildirimGoster: false
    property bool mesafeBildirimBasarili: true
    property string mesafeBildirimMesaj: ""

    function loadCellSiraliKopya(dizi) {
        var kopya = dizi.slice()
        kopya.sort(function(a, b) { return a.hamDeger - b.hamDeger })
        return kopya
    }

    function loadCellKaydetVeBildir() {
        var sirali = loadCellSiraliKopya(loadCellNoktalari)
        var basarili = database.loadCellNoktalariKaydet(sirali)
        loadCellBildirimBasarili = basarili
        loadCellBildirimMesaj = basarili ? txt("kalibrasyonKaydedildiMesaj") : txt("kalibrasyonKaydedilemediMesaj")
        loadCellBildirimGoster = true
        loadCellBildirimTimer.restart()
    }

    Timer {
        id: loadCellBildirimTimer
        interval: loadCellBildirimBasarili ? 1800 : 2500
        repeat: false
        onTriggered: {
            loadCellBildirimGoster = false
            if (loadCellBildirimBasarili) {
                seciliSensor = -1
            }
        }
    }

    function mesafeSiraliKopya(dizi) {
        var kopya = dizi.slice()
        kopya.sort(function(a, b) { return a.hamDeger - b.hamDeger })
        return kopya
    }

    function mesafeKaydetVeBildir() {
        var sirali = mesafeSiraliKopya(mesafeNoktalari)
        var basarili = database.mesafeNoktalariKaydet(sirali)
        if (basarili) {
            wifiManager.kalibrasyonYenidenYukle()
        }
        mesafeBildirimBasarili = basarili
        mesafeBildirimMesaj = basarili ? txt("kalibrasyonKaydedildiMesaj") : txt("kalibrasyonKaydedilemediMesaj")
        mesafeBildirimGoster = true
        mesafeBildirimTimer.restart()
    }

    Timer {
        id: mesafeBildirimTimer
        interval: mesafeBildirimBasarili ? 1800 : 2500
        repeat: false
        onTriggered: {
            mesafeBildirimGoster = false
            if (mesafeBildirimBasarili) {
                seciliSensor = -1
            }
        }
    }

    function egimSifirlaVeBildir() {
        var biasX = sensorManager.hamAccelX
        var biasY = sensorManager.hamAccelY
        var basarili = database.egimKalibrasyonuKaydet(biasX, biasY, 0.0, 1.0, 1.0, 1.0)
        if (basarili) {
            wifiManager.kalibrasyonYenidenYukle()
        }
        egimBildirimBasarili = basarili
        egimBildirimMesaj = basarili ? txt("kalibrasyonKaydedildiMesaj") : txt("kalibrasyonKaydedilemediMesaj")
        egimBildirimGoster = true
        egimBildirimTimer.restart()
    }

    Timer {
        id: egimBildirimTimer
        interval: egimBildirimBasarili ? 1800 : 2500
        repeat: false
        onTriggered: {
            egimBildirimGoster = false
            if (egimBildirimBasarili) {
                seciliSensor = -1
            }
        }
    }

    // Sensör kartlarının "Kalibre Edildi" rozeti ve tarihi kalıcı depodan (SQLite)
    // okunur; sadece o an kalibrasyon yapılınca değil, sayfa her açıldığında yeniden
    // yüklenmeli ki uygulama yeniden başlatıldığında da rozet doğru görünsün.
    function kalibrasyonDurumunuYukle() {
        var egimKal = database.egimKalibrasyonuGetir()
        egimKayitliVar = egimKal.mevcut
        egimSonTarih = egimKal.mevcut ? egimKal.tarih : ""

        var lcNoktalar = database.loadCellNoktalariGetir()
        loadCellKayitliVar = lcNoktalar.length > 0
        loadCellNoktaSayisi = lcNoktalar.length
        loadCellSonTarih = loadCellKayitliVar ? database.kalibrasyonTarihiGetir("loadcell") : ""

        var mNoktalar = database.mesafeNoktalariGetir()
        mesafeOlcumKayitliVar = mNoktalar.length > 0
        mesafeOlcumNoktaSayisi = mNoktalar.length
        mesafeSonTarih = mesafeOlcumKayitliVar ? database.kalibrasyonTarihiGetir("mesafe_olcum") : ""
    }

    Component.onCompleted: kalibrasyonDurumunuYukle()

    onVisibleChanged: {
        if (visible) {
            kalibrasyonDurumunuYukle()
        }
    }

    onSeciliSensorChanged: {
        if (seciliSensor === 0) {
            var egimKal = database.egimKalibrasyonuGetir()
            egimKayitliVar = egimKal.mevcut
            egimSonTarih = egimKal.mevcut ? egimKal.tarih : ""
            egimBildirimGoster = false
        } else if (seciliSensor === 1) {
            var noktalar = database.loadCellNoktalariGetir()
            loadCellKayitliVar = noktalar.length > 0
            loadCellNoktaSayisi = noktalar.length
            loadCellSonTarih = loadCellKayitliVar ? database.kalibrasyonTarihiGetir("loadcell") : ""
            loadCellNoktalari = []
            loadCellSayiSecildi = false
            loadCellDuzenlemeIndex = -1
            loadCellTamDuzenlemeModu = false
            loadCellGoruntuleModu = false
            loadCellYenidenOnayGoster = false
            loadCellTamamlandiOnayGoster = false
            loadCellBildirimGoster = false
            loadCellAraEkranGoster = loadCellKayitliVar
        } else if (seciliSensor === 2) {
            var mNoktalar = database.mesafeNoktalariGetir()
            mesafeOlcumKayitliVar = mNoktalar.length > 0
            mesafeOlcumNoktaSayisi = mNoktalar.length
            mesafeSonTarih = mesafeOlcumKayitliVar ? database.kalibrasyonTarihiGetir("mesafe_olcum") : ""
            mesafeNoktalari = []
            mesafeSayiSecildi = false
            mesafeDuzenlemeIndex = -1
            mesafeTamDuzenlemeModu = false
            mesafeGoruntuleModu = false
            mesafeYenidenOnayGoster = false
            mesafeTamamlandiOnayGoster = false
            mesafeBildirimGoster = false
            mesafeAraEkranGoster = mesafeOlcumKayitliVar
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: seciliSensor === -1 ? 0 : 1

        Item {
            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                text: txt("baslikSensorSec")
                color: "#6b7280"
                font.family: "Segoe UI"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 1
            }

            Row {
                anchors.centerIn: parent
                spacing: 24

                Rectangle {
                    id: egimKarti
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: egimKarti.hovered ? "#14b8a6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/egim_sensor.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("egimSensoru"); color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("egimAciklama"); color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: egimKayitliVar
                            width: kaliMetni1.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni1
                                anchors.centerIn: parent
                                text: txt("kalibreEdildiOnEk") + egimSonTarih
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: egimKarti.hovered = true
                        onExited: egimKarti.hovered = false
                        onClicked: seciliSensor = 0
                    }
                }

                Rectangle {
                    id: loadCellKarti
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: loadCellKarti.hovered ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/loadcell.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("loadCellAdi"); color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("loadCellAciklama"); color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: loadCellKayitliVar
                            width: kaliMetni2.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni2
                                anchors.centerIn: parent
                                text: txt("kalibreEdildiOnEk") + loadCellSonTarih
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: loadCellKarti.hovered = true
                        onExited: loadCellKarti.hovered = false
                        onClicked: seciliSensor = 1
                    }
                }

                Rectangle {
                    id: mesafeKarti
                    width: 350
                    height: 450
                    radius: 12
                    color: "#0f1420"
                    border.color: mesafeKarti.hovered ? "#9333ea" : "#1e2a3f"
                    border.width: 1
                    property bool hovered: false
                    scale: hovered ? 1.03 : 1.0
                    Behavior on border.color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 14

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 210
                            height: 150

                            Image {
                                anchors.centerIn: parent
                                width: parent.width
                                height: parent.height
                                source: "../assets/mesafe_sensor.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("mesafeSensoru"); color: "#dce8f5"; font.family: "Segoe UI"; font.pixelSize: 24; font.bold: true }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: txt("mesafeAciklama"); color: "#6b7280"; font.family: "Segoe UI"; font.pixelSize: 14 }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: mesafeOlcumKayitliVar
                            width: kaliMetni3.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: "#123321"

                            Text {
                                id: kaliMetni3
                                anchors.centerIn: parent
                                text: txt("kalibreEdildiOnEk") + mesafeSonTarih
                                color: "#4ade80"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: mesafeKarti.hovered = true
                        onExited: mesafeKarti.hovered = false
                        onClicked: seciliSensor = 2
                    }
                }
            }
        }

        Item {
            Row {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 20
                spacing: 12

                Button {
                    text: txt("geriButon")
                    font.pixelSize: 13

                    background: Rectangle {
                        radius: 6
                        color: parent.hovered ? "#1e2a3f" : "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#dce8f5"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                        rightPadding: 10
                    }

                    onClicked: seciliSensor = -1
                }

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: {
                        if (seciliSensor === 0) return "#14b8a6"
                        if (seciliSensor === 1) return "#3b82f6"
                        if (seciliSensor === 2) return "#9333ea"
                        return "#6b7280"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (seciliSensor === 0) return txt("egimBaslik")
                        if (seciliSensor === 1) return txt("loadCellBaslik")
                        if (seciliSensor === 2) return txt("mesafeBaslik")
                        return ""
                    }
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: 360

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: egimKayitliVar
                        width: egimSonKaliMetni.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: egimSonKaliMetni
                            anchors.centerIn: parent
                            text: txt("sonKalibrasyonOnEk") + egimSonTarih
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: txt("cihaziYerlestir")
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 14
                    }

                    SuTerazisi {
                        anchors.horizontalCenter: parent.horizontalCenter
                        egimX: sensorManager.egimX
                        egimY: sensorManager.egimY
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        height: 72
                        radius: 12
                        color: "#0f2e2a"
                        border.color: "#14b8a6"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "X: " + sensorManager.egimX.toFixed(1) + "°   Y: " + sensorManager.egimY.toFixed(1) + "°"
                            color: "#2dd4bf"
                            font.family: "Segoe UI"
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: !wifiManager.baglandi
                        text: txt("cihazBagliDegilKalibrasyon")
                        color: "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                    }

                    Button {
                        width: parent.width
                        height: 44
                        text: txt("sifirlaButon")
                        font.pixelSize: 14
                        font.bold: true
                        enabled: wifiManager.baglandi

                        onClicked: egimSifirlaVeBildir()

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ? (parent.hovered ? "#2dd4bf" : "#14b8a6") : "#1e2a3f"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    id: egimBildirimKutusu
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 12
                    z: 100
                    width: egimBildirimMetni.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: egimBildirimBasarili ? "#123321" : "#3a1414"
                    opacity: egimBildirimGoster ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Text {
                        id: egimBildirimMetni
                        anchors.centerIn: parent
                        text: egimBildirimMesaj
                        color: egimBildirimBasarili ? "#4ade80" : "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 1

                Column {
                    anchors.centerIn: parent
                    spacing: 24
                    width: 420
                    visible: loadCellAraEkranGoster

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: araEkranBadge.implicitWidth + 20
                        height: 26
                        radius: 13
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Text {
                            id: araEkranBadge
                            anchors.centerIn: parent
                            text: txt("kayitliOnEk") + loadCellNoktaSayisi + txt("noktaSonEk")
                            color: "#6b7280"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: txt("kayitliKalibrasyonBulundu")
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20

                        Rectangle {
                            id: goruntuleKarti
                            width: 190
                            height: 180
                            radius: 14
                            color: "#0f1420"
                            border.color: goruntuleKarti.hovered ? "#3b82f6" : "#1e2a3f"
                            border.width: 1
                            property bool hovered: false
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 28

                                Canvas {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 32
                                    height: 32
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        ctx.lineWidth = 1.8
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"
                                        ctx.strokeStyle = "#3b82f6"

                                        ctx.beginPath()
                                        ctx.moveTo(3, 16)
                                        ctx.bezierCurveTo(7.5, 8.5, 12.5, 6.8, 16, 6.8)
                                        ctx.bezierCurveTo(19.5, 6.8, 24.5, 8.5, 29, 16)
                                        ctx.bezierCurveTo(24.5, 23.5, 19.5, 25.2, 16, 25.2)
                                        ctx.bezierCurveTo(12.5, 25.2, 7.5, 23.5, 3, 16)
                                        ctx.stroke()

                                        ctx.beginPath()
                                        ctx.arc(16, 16, 4.4, 0, Math.PI * 2, false)
                                        ctx.stroke()
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("mevcutGoruntule")
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("kayitliNoktalariIncele")
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: goruntuleKarti.hovered = true
                                onExited: goruntuleKarti.hovered = false
                                onClicked: {
                                    loadCellNoktalari = database.loadCellNoktalariGetir()
                                    loadCellAraEkranGoster = false
                                    loadCellGoruntuleModu = true
                                    loadCellDuzenlemeIndex = -1
                                }
                            }
                        }

                        Rectangle {
                            id: yenidenKarti
                            width: 190
                            height: 180
                            radius: 14
                            color: "#0f1420"
                            border.color: yenidenKarti.hovered ? "#9ca3af" : "#1e2a3f"
                            border.width: 1
                            property bool hovered: false
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                width: parent.width - 28

                                Canvas {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 32
                                    height: 32
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        ctx.strokeStyle = "#9ca3af"
                                        ctx.fillStyle = "#9ca3af"
                                        ctx.lineWidth = 3.4
                                        ctx.lineCap = "butt"

                                        function yayOku(startDeg, endDeg) {
                                            var s = startDeg * Math.PI / 180
                                            var e = endDeg * Math.PI / 180
                                            var cx = 16, cy = 16, r = 10.5

                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r, s, e, false)
                                            ctx.stroke()

                                            var ex = cx + r * Math.cos(e)
                                            var ey = cy + r * Math.sin(e)
                                            var tx = -Math.sin(e)
                                            var ty = Math.cos(e)
                                            var px = -ty
                                            var py = tx
                                            var geri = 6.2
                                            var yaricap = 3.6
                                            var bx = ex - tx * geri
                                            var by = ey - ty * geri

                                            ctx.beginPath()
                                            ctx.moveTo(ex, ey)
                                            ctx.lineTo(bx + px * yaricap, by + py * yaricap)
                                            ctx.lineTo(bx - px * yaricap, by - py * yaricap)
                                            ctx.closePath()
                                            ctx.fill()
                                        }

                                        yayOku(195, 345)
                                        yayOku(15, 165)
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("yenidenKalibreEt")
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("sifirdanYeniOlcum")
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: yenidenKarti.hovered = true
                                onExited: yenidenKarti.hovered = false
                                onClicked: loadCellYenidenOnayGoster = true
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    width: 340
                    visible: loadCellGoruntuleModu

                    Text {
                        text: txt("kayitliNoktalarBaslik")
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Rectangle {
                        width: parent.width
                        height: 320
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 16
                            clip: true
                            spacing: 8

                            model: loadCellNoktalari

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                radius: 8
                                color: "#0a0e17"
                                border.color: "#1e2a3f"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#182644"
                                        border.color: "#3b82f6"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: "#3b82f6"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            text: modelData.hedefKg.toFixed(2) + " kg"
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Text {
                                            text: "ADC: " + modelData.hamDeger.toFixed(0)
                                            color: "#6b7280"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 10
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        width: parent.width
                        height: 46
                        text: txt("duzenleButon")
                        font.pixelSize: 14
                        font.bold: true

                        onClicked: {
                            loadCellToplamNokta = loadCellNoktalari.length
                            loadCellGoruntuleModu = false
                            loadCellTamDuzenlemeModu = true
                            loadCellSayiSecildi = true
                            loadCellDuzenlemeIndex = -1
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#000000b3"
                    visible: loadCellYenidenOnayGoster
                    z: 200

                    MouseArea { anchors.fill: parent }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 360
                        height: 200
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 18
                            width: parent.width - 40

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                text: txt("silinecekOnay")
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 12

                                Button {
                                    width: 150
                                    height: 42
                                    text: txt("vazgecButon")

                                    onClicked: loadCellYenidenOnayGoster = false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#1e2a3f" : "transparent"
                                        border.color: "#1e2a3f"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#9ca3af"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: 150
                                    height: 42
                                    text: txt("evetYenidenBaslaButon")
                                    font.bold: true

                                    onClicked: {
                                        loadCellYenidenOnayGoster = false
                                        loadCellAraEkranGoster = false
                                        loadCellGoruntuleModu = false
                                        loadCellTamDuzenlemeModu = false
                                        loadCellNoktalari = []
                                        loadCellSayiSecildi = false
                                        loadCellDuzenlemeIndex = -1
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#b91c1c" : "#991b1b"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#000000b3"
                    visible: loadCellTamamlandiOnayGoster
                    z: 200

                    MouseArea { anchors.fill: parent }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 380
                        height: 220
                        radius: 14
                        color: "#0f1420"
                        border.color: "#16a34a"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 18
                            width: parent.width - 40

                            Column {
                                width: parent.width
                                spacing: 6

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: txt("kalibrasyonTamamlandiBaslik")
                                    color: "#4ade80"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 17
                                    font.bold: true
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("toplamOnEk") + loadCellToplamNokta + txt("noktaGirildiSonEk")
                                    color: "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                }
                            }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 12

                                Button {
                                    width: 150
                                    height: 42
                                    text: txt("noktalariKontrolEt")

                                    onClicked: loadCellTamamlandiOnayGoster = false

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#1e2a3f" : "transparent"
                                        border.color: "#1e2a3f"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#9ca3af"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: 150
                                    height: 42
                                    text: txt("kaydetVeBitir")
                                    font.bold: true

                                    onClicked: {
                                        loadCellTamamlandiOnayGoster = false
                                        loadCellKaydetVeBildir()
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#22c55e" : "#16a34a"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: loadCellBildirimKutusu
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 12
                    z: 100
                    width: loadCellBildirimMetni.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: loadCellBildirimBasarili ? "#123321" : "#3a1414"
                    opacity: loadCellBildirimGoster ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Text {
                        id: loadCellBildirimMetni
                        anchors.centerIn: parent
                        text: loadCellBildirimMesaj
                        color: loadCellBildirimBasarili ? "#4ade80" : "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 24
                    width: 360
                    visible: !loadCellSayiSecildi && !loadCellAraEkranGoster && !loadCellGoruntuleModu

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: txt("kacNoktaSoru")
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: txt("dahaFazlaNokta")
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                    }

                    Grid {
                        anchors.horizontalCenter: parent.horizontalCenter
                        columns: 4
                        spacing: 12

                        Repeater {
                            model: [4, 6, 8, 10]

                            Rectangle {
                                id: secKarti
                                width: 72
                                height: 72
                                radius: 12
                                color: secKarti.hovered ? "#182644" : "#0f1420"
                                border.color: "#3b82f6"
                                border.width: 1
                                property bool hovered: false
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 26
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: secKarti.hovered = true
                                    onExited: secKarti.hovered = false
                                    onClicked: {
                                        loadCellToplamNokta = modelData
                                        loadCellNoktalari = []
                                        loadCellDuzenlemeIndex = -1
                                        loadCellSayiSecildi = true
                                    }
                                }
                            }
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 24
                    visible: loadCellSayiSecildi

                    Rectangle {
                        width: 340
                        height: 500
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 16
                            width: parent.width - 40

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: loadCellKayitliVar && !loadCellTamDuzenlemeModu
                                width: sonKaliMetni2.implicitWidth + 20
                                height: 24
                                radius: 12
                                color: "#0a0e17"
                                border.color: "#1e2a3f"
                                border.width: 1

                                Text {
                                    id: sonKaliMetni2
                                    anchors.centerIn: parent
                                    text: txt("kayitliOnEk") + loadCellNoktaSayisi + txt("noktaSonEk")
                                    color: "#6b7280"
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: loadCellTamDuzenlemeModu
                                      ? txt("kalibrasyonuDuzenle")
                                      : txt("noktaOnEk") + (loadCellNoktalari.length + 1) + " / " + loadCellToplamNokta
                                color: "#3b82f6"
                                font.family: "Segoe UI"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#1e2a3f"

                                Rectangle {
                                    width: parent.width * (loadCellNoktalari.length / loadCellToplamNokta)
                                    height: parent.height
                                    radius: 3
                                    color: "#3b82f6"
                                    Behavior on width { NumberAnimation { duration: 150 } }
                                }
                            }

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                text: loadCellDuzenlemeIndex >= 0
                                      ? txt("noktaOnEk") + (loadCellDuzenlemeIndex + 1) + txt("duzenleniyorSonEk")
                                      : (loadCellTamDuzenlemeModu
                                         ? txt("duzenlemekIcinTikla")
                                         : txt("hedefAgirlikYonerge"))
                                color: loadCellDuzenlemeIndex >= 0 ? "#3b82f6" : "#9ca3af"
                                font.family: "Segoe UI"
                                font.bold: loadCellDuzenlemeIndex >= 0
                                font.pixelSize: 13
                            }

                            TextField {
                                id: hedefKgKutusu
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 180
                                height: 44
                                placeholderText: "kg"
                                placeholderTextColor: "#4b5563"
                                color: "#ffffff"
                                font.pixelSize: 16
                                horizontalAlignment: TextInput.AlignHCenter
                                validator: DoubleValidator { bottom: 0; top: 500; decimals: 2 }
                                background: Rectangle {
                                    color: "#0a0e17"
                                    radius: 10
                                    border.color: hedefKgKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                                    border.width: 1
                                }
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                height: 64
                                radius: 12
                                color: "#132335"
                                border.color: wifiManager.baglandi ? "#3b82f6" : "#dc2626"
                                border.width: 1
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: txt("hamDegerOnEk") + sensorManager.hamAgirlik.toFixed(0)
                                    color: wifiManager.baglandi ? "#3b82f6" : "#f87171"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 20
                                    font.bold: true
                                }
                            }

                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                visible: !wifiManager.baglandi
                                text: txt("hamDegerSifirUyari")
                                color: "#f87171"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                            }

                            Button {
                                id: noktaKaydetButonu
                                width: parent.width
                                height: 46
                                property bool tumNoktalarGirildi: !loadCellTamDuzenlemeModu && loadCellDuzenlemeIndex < 0 && loadCellNoktalari.length >= loadCellToplamNokta
                                text: loadCellDuzenlemeIndex >= 0
                                      ? txt("noktayiGuncelle")
                                      : (tumNoktalarGirildi
                                         ? txt("kalibrasyonuTamamla")
                                         : (loadCellNoktalari.length >= loadCellToplamNokta - 1 ? txt("sonNoktayiKaydet") : txt("buNoktayiKaydet")))
                                font.pixelSize: 14
                                font.bold: true
                                enabled: tumNoktalarGirildi || (hedefKgKutusu.text.length > 0 && (loadCellDuzenlemeIndex >= 0 || loadCellNoktalari.length < loadCellToplamNokta))

                                onClicked: {
                                    if (tumNoktalarGirildi) {
                                        loadCellTamamlandiOnayGoster = true
                                        return
                                    }

                                    var yeniNokta = { hedefKg: parseFloat(hedefKgKutusu.text), hamDeger: sensorManager.hamAgirlik }

                                    if (loadCellDuzenlemeIndex >= 0) {
                                        // Var olan bir noktayı yerinde güncelliyoruz, diğer noktalar etkilenmiyor
                                        var guncelDizi = loadCellNoktalari.slice()
                                        guncelDizi[loadCellDuzenlemeIndex] = yeniNokta
                                        loadCellNoktalari = guncelDizi
                                        loadCellDuzenlemeIndex = -1
                                        hedefKgKutusu.text = ""
                                        return
                                    }

                                    var yeniDizi = loadCellNoktalari.slice()
                                    yeniDizi.push(yeniNokta)
                                    loadCellNoktalari = yeniDizi
                                    hedefKgKutusu.text = ""

                                    if (loadCellNoktalari.length >= loadCellToplamNokta) {
                                        loadCellTamamlandiOnayGoster = true
                                    }
                                }

                                background: Rectangle {
                                    radius: 10
                                    color: parent.enabled ? (parent.hovered ? "#4f8cf7" : "#3b82f6") : "#1e2a3f"
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                width: parent.width
                                height: 46
                                visible: loadCellTamDuzenlemeModu
                                text: txt("degisiklikleriKaydet")
                                font.pixelSize: 14
                                font.bold: true

                                onClicked: loadCellKaydetVeBildir()

                                background: Rectangle {
                                    radius: 10
                                    color: parent.hovered ? "#22c55e" : "#16a34a"
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                width: parent.width
                                height: 38
                                visible: loadCellDuzenlemeIndex >= 0
                                text: txt("vazgecButon")
                                font.pixelSize: 13

                                onClicked: {
                                    loadCellDuzenlemeIndex = -1
                                    hedefKgKutusu.text = ""
                                }

                                background: Rectangle {
                                    radius: 8
                                    color: parent.hovered ? "#1e2a3f" : "transparent"
                                    border.color: "#1e2a3f"
                                    border.width: 1
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "#9ca3af"
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 300
                        height: 500
                        radius: 14
                        color: "#0f1420"
                        border.color: "#1e2a3f"
                        border.width: 1

                        Column {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20
                            spacing: 4

                            Text {
                                text: txt("kaydedilenNoktalarBaslik")
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                text: txt("duzeltmekIcinTikla")
                                color: "#4b5563"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                            }
                        }

                        ListView {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 16
                            anchors.topMargin: 60
                            clip: true
                            spacing: 8

                            model: loadCellNoktalari

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 48
                                radius: 8
                                color: satirAlani.containsMouse ? "#182644" : "#0a0e17"
                                border.color: index === loadCellDuzenlemeIndex ? "#3b82f6" : "#1e2a3f"
                                border.width: index === loadCellDuzenlemeIndex ? 2 : 1
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#182644"
                                        border.color: "#3b82f6"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: index + 1
                                            color: "#3b82f6"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1

                                        Text {
                                            text: modelData.hedefKg.toFixed(2) + " kg"
                                            color: "#dce8f5"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Text {
                                            text: "ADC: " + modelData.hamDeger.toFixed(0)
                                            color: "#6b7280"
                                            font.family: "Segoe UI"
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.rightMargin: 12
                                    text: "✎"
                                    color: "#6b7280"
                                    font.pixelSize: 13
                                    visible: satirAlani.containsMouse
                                }

                                MouseArea {
                                    id: satirAlani
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        hedefKgKutusu.text = modelData.hedefKg.toString()
                                        loadCellDuzenlemeIndex = index
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70
                visible: seciliSensor === 2

                // =========================================================
                // OLCUM KALIBRASYONU — cok nokta (load cell birebir kopyasi)
                // =========================================================
                Item {
                    anchors.fill: parent

                    Column {
                        anchors.centerIn: parent
                        spacing: 24
                        width: 420
                        visible: mesafeAraEkranGoster

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: mesafeAraEkranBadge.implicitWidth + 20
                            height: 26
                            radius: 13
                            color: "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1

                            Text {
                                id: mesafeAraEkranBadge
                                anchors.centerIn: parent
                                text: txt("kayitliOnEk") + mesafeOlcumNoktaSayisi + txt("noktaSonEk")
                                color: "#6b7280"
                                font.pixelSize: 11
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: txt("kayitliKalibrasyonBulundu")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20

                            Rectangle {
                                id: mesafeGoruntuleKarti
                                width: 190
                                height: 180
                                radius: 14
                                color: "#0f1420"
                                border.color: mesafeGoruntuleKarti.hovered ? "#9333ea" : "#1e2a3f"
                                border.width: 1
                                property bool hovered: false
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 12
                                    width: parent.width - 28

                                    Canvas {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 32
                                        height: 32
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            ctx.lineWidth = 1.8
                                            ctx.lineCap = "round"
                                            ctx.lineJoin = "round"
                                            ctx.strokeStyle = "#9333ea"

                                            ctx.beginPath()
                                            ctx.moveTo(3, 16)
                                            ctx.bezierCurveTo(7.5, 8.5, 12.5, 6.8, 16, 6.8)
                                            ctx.bezierCurveTo(19.5, 6.8, 24.5, 8.5, 29, 16)
                                            ctx.bezierCurveTo(24.5, 23.5, 19.5, 25.2, 16, 25.2)
                                            ctx.bezierCurveTo(12.5, 25.2, 7.5, 23.5, 3, 16)
                                            ctx.stroke()

                                            ctx.beginPath()
                                            ctx.arc(16, 16, 4.4, 0, Math.PI * 2, false)
                                            ctx.stroke()
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: txt("mevcutGoruntule")
                                        color: "#dce8f5"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: txt("kayitliNoktalariIncele")
                                        color: "#6b7280"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 11
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: mesafeGoruntuleKarti.hovered = true
                                    onExited: mesafeGoruntuleKarti.hovered = false
                                    onClicked: {
                                        mesafeNoktalari = database.mesafeNoktalariGetir()
                                        mesafeAraEkranGoster = false
                                        mesafeGoruntuleModu = true
                                        mesafeDuzenlemeIndex = -1
                                    }
                                }
                            }

                            Rectangle {
                                id: mesafeYenidenKarti
                                width: 190
                                height: 180
                                radius: 14
                                color: "#0f1420"
                                border.color: mesafeYenidenKarti.hovered ? "#9ca3af" : "#1e2a3f"
                                border.width: 1
                                property bool hovered: false
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 12
                                    width: parent.width - 28

                                    Canvas {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 32
                                        height: 32
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.clearRect(0, 0, width, height)
                                            ctx.strokeStyle = "#9ca3af"
                                            ctx.fillStyle = "#9ca3af"
                                            ctx.lineWidth = 3.4
                                            ctx.lineCap = "butt"

                                            function yayOku(startDeg, endDeg) {
                                                var s = startDeg * Math.PI / 180
                                                var e = endDeg * Math.PI / 180
                                                var cx = 16, cy = 16, r = 10.5

                                                ctx.beginPath()
                                                ctx.arc(cx, cy, r, s, e, false)
                                                ctx.stroke()

                                                var ex = cx + r * Math.cos(e)
                                                var ey = cy + r * Math.sin(e)
                                                var tx = -Math.sin(e)
                                                var ty = Math.cos(e)
                                                var px = -ty
                                                var py = tx
                                                var geri = 6.2
                                                var yaricap = 3.6
                                                var bx = ex - tx * geri
                                                var by = ey - ty * geri

                                                ctx.beginPath()
                                                ctx.moveTo(ex, ey)
                                                ctx.lineTo(bx + px * yaricap, by + py * yaricap)
                                                ctx.lineTo(bx - px * yaricap, by - py * yaricap)
                                                ctx.closePath()
                                                ctx.fill()
                                            }

                                            yayOku(195, 345)
                                            yayOku(15, 165)
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: txt("yenidenKalibreEt")
                                        color: "#dce8f5"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: txt("sifirdanYeniOlcum")
                                        color: "#6b7280"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 11
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: mesafeYenidenKarti.hovered = true
                                    onExited: mesafeYenidenKarti.hovered = false
                                    onClicked: mesafeYenidenOnayGoster = true
                                }
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 16
                        width: 340
                        visible: mesafeGoruntuleModu

                        Text {
                            text: txt("kayitliNoktalarBaslik")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            width: parent.width
                            height: 320
                            radius: 14
                            color: "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1

                            ListView {
                                anchors.fill: parent
                                anchors.margins: 16
                                clip: true
                                spacing: 8

                                model: mesafeNoktalari

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 48
                                    radius: 8
                                    color: "#0a0e17"
                                    border.color: "#1e2a3f"
                                    border.width: 1

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 8

                                        Rectangle {
                                            width: 22
                                            height: 22
                                            radius: 11
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: "#241a38"
                                            border.color: "#9333ea"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: index + 1
                                                color: "#c084fc"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1

                                            Text {
                                                text: (modelData.hedefMm / 10).toFixed(1) + " cm"
                                                color: "#dce8f5"
                                                font.family: "Segoe UI"
                                                font.pixelSize: 13
                                                font.bold: true
                                            }

                                            Text {
                                                text: "ADC: " + modelData.hamDeger.toFixed(0)
                                                color: "#6b7280"
                                                font.family: "Segoe UI"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            width: parent.width
                            height: 46
                            text: txt("duzenleButon")
                            font.pixelSize: 14
                            font.bold: true

                            onClicked: {
                                mesafeToplamNokta = mesafeNoktalari.length
                                mesafeGoruntuleModu = false
                                mesafeTamDuzenlemeModu = true
                                mesafeSayiSecildi = true
                                mesafeDuzenlemeIndex = -1
                            }

                            background: Rectangle {
                                radius: 8
                                color: parent.hovered ? "#a855f7" : "#9333ea"
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#000000b3"
                        visible: mesafeYenidenOnayGoster
                        z: 200

                        MouseArea { anchors.fill: parent }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 360
                            height: 200
                            radius: 14
                            color: "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 18
                                width: parent.width - 40

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: txt("silinecekOnay")
                                    color: "#dce8f5"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 12

                                    Button {
                                        width: 150
                                        height: 42
                                        text: txt("vazgecButon")

                                        onClicked: mesafeYenidenOnayGoster = false

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.hovered ? "#1e2a3f" : "transparent"
                                            border.color: "#1e2a3f"
                                            border.width: 1
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#9ca3af"
                                            font: parent.font
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Button {
                                        width: 150
                                        height: 42
                                        text: txt("evetYenidenBaslaButon")
                                        font.bold: true

                                        onClicked: {
                                            mesafeYenidenOnayGoster = false
                                            mesafeAraEkranGoster = false
                                            mesafeGoruntuleModu = false
                                            mesafeTamDuzenlemeModu = false
                                            mesafeNoktalari = []
                                            mesafeSayiSecildi = false
                                            mesafeDuzenlemeIndex = -1
                                        }

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.hovered ? "#b91c1c" : "#991b1b"
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#ffffff"
                                            font: parent.font
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#000000b3"
                        visible: mesafeTamamlandiOnayGoster
                        z: 200

                        MouseArea { anchors.fill: parent }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 380
                            height: 220
                            radius: 14
                            color: "#0f1420"
                            border.color: "#16a34a"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 18
                                width: parent.width - 40

                                Column {
                                    width: parent.width
                                    spacing: 6

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        text: txt("kalibrasyonTamamlandiBaslik")
                                        color: "#4ade80"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 17
                                        font.bold: true
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: txt("toplamOnEk") + mesafeToplamNokta + txt("noktaGirildiSonEk")
                                        color: "#9ca3af"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 13
                                    }
                                }

                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 12

                                    Button {
                                        width: 150
                                        height: 42
                                        text: txt("noktalariKontrolEt")

                                        onClicked: mesafeTamamlandiOnayGoster = false

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.hovered ? "#1e2a3f" : "transparent"
                                            border.color: "#1e2a3f"
                                            border.width: 1
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#9ca3af"
                                            font: parent.font
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Button {
                                        width: 150
                                        height: 42
                                        text: txt("kaydetVeBitir")
                                        font.bold: true

                                        onClicked: {
                                            mesafeTamamlandiOnayGoster = false
                                            mesafeKaydetVeBildir()
                                        }

                                        background: Rectangle {
                                            radius: 8
                                            color: parent.hovered ? "#22c55e" : "#16a34a"
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }

                                        contentItem: Text {
                                            text: parent.text
                                            color: "#ffffff"
                                            font: parent.font
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 24
                        width: 360
                        visible: !mesafeSayiSecildi && !mesafeAraEkranGoster && !mesafeGoruntuleModu

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: txt("kacNoktaSoru")
                            color: "#dce8f5"
                            font.family: "Segoe UI"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: txt("dahaFazlaNokta")
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                        }

                        Grid {
                            anchors.horizontalCenter: parent.horizontalCenter
                            columns: 4
                            spacing: 12

                            Repeater {
                                model: [4, 6, 8, 10]

                                Rectangle {
                                    id: mesafeSecKarti
                                    width: 72
                                    height: 72
                                    radius: 12
                                    color: mesafeSecKarti.hovered ? "#241a38" : "#0f1420"
                                    border.color: "#9333ea"
                                    border.width: 1
                                    property bool hovered: false
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: "#dce8f5"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 26
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: mesafeSecKarti.hovered = true
                                        onExited: mesafeSecKarti.hovered = false
                                        onClicked: {
                                            mesafeToplamNokta = modelData
                                            mesafeNoktalari = []
                                            mesafeDuzenlemeIndex = -1
                                            mesafeSayiSecildi = true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 24
                        visible: mesafeSayiSecildi

                        Rectangle {
                            width: 340
                            height: 500
                            radius: 14
                            color: "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 16
                                width: parent.width - 40

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    visible: mesafeOlcumKayitliVar && !mesafeTamDuzenlemeModu
                                    width: mesafeSonKaliMetni.implicitWidth + 20
                                    height: 24
                                    radius: 12
                                    color: "#0a0e17"
                                    border.color: "#1e2a3f"
                                    border.width: 1

                                    Text {
                                        id: mesafeSonKaliMetni
                                        anchors.centerIn: parent
                                        text: txt("kayitliOnEk") + mesafeOlcumNoktaSayisi + txt("noktaSonEk")
                                        color: "#6b7280"
                                        font.pixelSize: 11
                                    }
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: mesafeTamDuzenlemeModu
                                          ? txt("kalibrasyonuDuzenle")
                                          : txt("noktaOnEk") + (mesafeNoktalari.length + 1) + " / " + mesafeToplamNokta
                                    color: "#9333ea"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 6
                                    radius: 3
                                    color: "#1e2a3f"

                                    Rectangle {
                                        width: parent.width * (mesafeNoktalari.length / mesafeToplamNokta)
                                        height: parent.height
                                        radius: 3
                                        color: "#9333ea"
                                        Behavior on width { NumberAnimation { duration: 150 } }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: mesafeDuzenlemeIndex >= 0
                                          ? txt("noktaOnEk") + (mesafeDuzenlemeIndex + 1) + txt("duzenleniyorSonEk")
                                          : (mesafeTamDuzenlemeModu
                                             ? txt("duzenlemekIcinTikla")
                                             : txt("hedefMesafeYonerge"))
                                    color: mesafeDuzenlemeIndex >= 0 ? "#9333ea" : "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.bold: mesafeDuzenlemeIndex >= 0
                                    font.pixelSize: 13
                                }

                                TextField {
                                    id: hedefCmKutusu
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 180
                                    height: 44
                                    placeholderText: "cm"
                                    placeholderTextColor: "#4b5563"
                                    color: "#ffffff"
                                    font.pixelSize: 16
                                    horizontalAlignment: TextInput.AlignHCenter
                                    validator: DoubleValidator { bottom: 0; top: 300; decimals: 1 }
                                    background: Rectangle {
                                        color: "#0a0e17"
                                        radius: 10
                                        border.color: hedefCmKutusu.activeFocus ? "#9333ea" : "#1e2a3f"
                                        border.width: 1
                                    }
                                }

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width
                                    height: 64
                                    radius: 12
                                    color: "#132335"
                                    border.color: wifiManager.baglandi ? "#9333ea" : "#dc2626"
                                    border.width: 1
                                    Behavior on border.color { ColorAnimation { duration: 120 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: txt("hamDegerOnEk") + sensorManager.hamMesafe.toFixed(0)
                                        color: wifiManager.baglandi ? "#c084fc" : "#f87171"
                                        font.family: "Segoe UI"
                                        font.pixelSize: 20
                                        font.bold: true
                                    }
                                }

                                Text {
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    visible: !wifiManager.baglandi
                                    text: txt("hamDegerSifirUyari")
                                    color: "#f87171"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                }

                                Button {
                                    id: mesafeNoktaKaydetButonu
                                    width: parent.width
                                    height: 46
                                    property bool tumNoktalarGirildi: !mesafeTamDuzenlemeModu && mesafeDuzenlemeIndex < 0 && mesafeNoktalari.length >= mesafeToplamNokta
                                    text: mesafeDuzenlemeIndex >= 0
                                          ? txt("noktayiGuncelle")
                                          : (tumNoktalarGirildi
                                             ? txt("kalibrasyonuTamamla")
                                             : (mesafeNoktalari.length >= mesafeToplamNokta - 1 ? txt("sonNoktayiKaydet") : txt("buNoktayiKaydet")))
                                    font.pixelSize: 14
                                    font.bold: true
                                    enabled: tumNoktalarGirildi || (hedefCmKutusu.text.length > 0 && (mesafeDuzenlemeIndex >= 0 || mesafeNoktalari.length < mesafeToplamNokta))

                                    onClicked: {
                                        if (tumNoktalarGirildi) {
                                            mesafeTamamlandiOnayGoster = true
                                            return
                                        }

                                        var yeniNokta = { hedefMm: parseFloat(hedefCmKutusu.text) * 10, hamDeger: sensorManager.hamMesafe }

                                        if (mesafeDuzenlemeIndex >= 0) {
                                            // Var olan bir noktayı yerinde güncelliyoruz, diğer noktalar etkilenmiyor
                                            var guncelDizi = mesafeNoktalari.slice()
                                            guncelDizi[mesafeDuzenlemeIndex] = yeniNokta
                                            mesafeNoktalari = guncelDizi
                                            mesafeDuzenlemeIndex = -1
                                            hedefCmKutusu.text = ""
                                            return
                                        }

                                        var yeniDizi = mesafeNoktalari.slice()
                                        yeniDizi.push(yeniNokta)
                                        mesafeNoktalari = yeniDizi
                                        hedefCmKutusu.text = ""

                                        if (mesafeNoktalari.length >= mesafeToplamNokta) {
                                            mesafeTamamlandiOnayGoster = true
                                        }
                                    }

                                    background: Rectangle {
                                        radius: 10
                                        color: parent.enabled ? (parent.hovered ? "#a855f7" : "#9333ea") : "#1e2a3f"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: parent.width
                                    height: 46
                                    visible: mesafeTamDuzenlemeModu
                                    text: txt("degisiklikleriKaydet")
                                    font.pixelSize: 14
                                    font.bold: true

                                    onClicked: mesafeKaydetVeBildir()

                                    background: Rectangle {
                                        radius: 10
                                        color: parent.hovered ? "#22c55e" : "#16a34a"
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    width: parent.width
                                    height: 38
                                    visible: mesafeDuzenlemeIndex >= 0
                                    text: txt("vazgecButon")
                                    font.pixelSize: 13

                                    onClicked: {
                                        mesafeDuzenlemeIndex = -1
                                        hedefCmKutusu.text = ""
                                    }

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.hovered ? "#1e2a3f" : "transparent"
                                        border.color: "#1e2a3f"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: "#9ca3af"
                                        font: parent.font
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 300
                            height: 500
                            radius: 14
                            color: "#0f1420"
                            border.color: "#1e2a3f"
                            border.width: 1

                            Column {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 20
                                spacing: 4

                                Text {
                                    text: txt("kaydedilenNoktalarBaslik")
                                    color: "#6b7280"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    text: txt("duzeltmekIcinTikla")
                                    color: "#4b5563"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 10
                                }
                            }

                            ListView {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 16
                                anchors.topMargin: 60
                                clip: true
                                spacing: 8

                                model: mesafeNoktalari

                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 48
                                    radius: 8
                                    color: mesafeSatirAlani.containsMouse ? "#241a38" : "#0a0e17"
                                    border.color: index === mesafeDuzenlemeIndex ? "#9333ea" : "#1e2a3f"
                                    border.width: index === mesafeDuzenlemeIndex ? 2 : 1
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 8

                                        Rectangle {
                                            width: 22
                                            height: 22
                                            radius: 11
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: "#241a38"
                                            border.color: "#9333ea"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: index + 1
                                                color: "#c084fc"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1

                                            Text {
                                                text: (modelData.hedefMm / 10).toFixed(1) + " cm"
                                                color: "#dce8f5"
                                                font.family: "Segoe UI"
                                                font.pixelSize: 13
                                                font.bold: true
                                            }

                                            Text {
                                                text: "ADC: " + modelData.hamDeger.toFixed(0)
                                                color: "#6b7280"
                                                font.family: "Segoe UI"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.rightMargin: 12
                                        text: "✎"
                                        color: "#6b7280"
                                        font.pixelSize: 13
                                        visible: mesafeSatirAlani.containsMouse
                                    }

                                    MouseArea {
                                        id: mesafeSatirAlani
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            hedefCmKutusu.text = (modelData.hedefMm / 10).toString()
                                            mesafeDuzenlemeIndex = index
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: mesafeBildirimKutusu
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 12
                    z: 100
                    width: mesafeBildirimMetni.implicitWidth + 24
                    height: 32
                    radius: 16
                    color: mesafeBildirimBasarili ? "#123321" : "#3a1414"
                    opacity: mesafeBildirimGoster ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Text {
                        id: mesafeBildirimMetni
                        anchors.centerIn: parent
                        text: mesafeBildirimMesaj
                        color: mesafeBildirimBasarili ? "#4ade80" : "#f87171"
                        font.family: "Segoe UI"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }
}