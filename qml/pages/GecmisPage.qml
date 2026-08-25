import QtQuick 6.7
import QtQuick.Controls 6.7
import "../components"
import sliper

Rectangle {
    id: gecmisSayfasi
    color: "#0a0a0d"

    signal testSecildi(int id)

    property var olcumListesi: []
    property string baslangicTarihi: ""
    property string bitisTarihi: ""

    readonly property var filtreAnahtarlari: ["tumTestler", "son7Gun", "son30Gun"]

    readonly property var metinler: ({
        aramaPlaceholder: { tr: "Müşteri veya reçete ara...", en: "Search by customer or recipe..." },
        tumTestler: { tr: "Tüm Testler", en: "All Tests" },
        son7Gun: { tr: "Son 7 Gün", en: "Last 7 Days" },
        son30Gun: { tr: "Son 30 Gün", en: "Last 30 Days" },
        ozelTarih: { tr: "Özel Tarih:", en: "Custom Date:" },
        temizle: { tr: "Temizle", en: "Clear" },
        musteriEtiket: { tr: "Müşteri: ", en: "Customer: " },
        receteEtiket: { tr: "  •  Reçete: ", en: "  •  Recipe: " },
        goruntule: { tr: "Görüntüle", en: "View" },
        kayitSilBaslik: { tr: "Kaydı Sil", en: "Delete Record" },
        kayitSilOnSoru: { tr: "'", en: "Are you sure you want to delete the measurement for '" },
        kayitSilSonSoru: { tr: "' ölçümünü silmek istediğinize emin misiniz? Bu işlem geri alınamaz.", en: "'? This action cannot be undone." },
        sifreEtiket: { tr: "ŞİFRE", en: "PASSWORD" },
        sifrenizGirin: { tr: "Şifrenizi girin", en: "Enter your password" },
        sifreHatali: { tr: "Şifre hatalı, tekrar deneyin.", en: "Incorrect password, please try again." },
        sil: { tr: "Sil", en: "Delete" },
        iptal: { tr: "İptal", en: "Cancel" },
        gelismisAyarlarBaslik: { tr: "Gelişmiş Ayarlar", en: "Advanced Settings" },
        onayla: { tr: "Onayla", en: "Confirm" },
        veriTabaniDisaAktar: { tr: "Veritabanını Dışa Aktar", en: "Export Database" },
        disaAktarildi: { tr: "✓ Dışa aktarıldı: ", en: "✓ Exported: " },
        disaAktarilamadi: { tr: "✕ Dışa aktarılamadı", en: "✕ Export failed" },
        icaAktarYoluEtiket: { tr: "İÇE AKTARILACAK .DB DOSYA YOLU", en: ".DB FILE PATH TO IMPORT" },
        icaAktarPlaceholder: { tr: "ör. C:/Users/.../SliperRaporlari/sliper_yedek_....db", en: "e.g. C:/Users/.../SliperRaporlari/sliper_yedek_....db" },
        veriTabaniIcaAktar: { tr: "Veritabanını İçe Aktar", en: "Import Database" },
        icaAktarildi: { tr: "✓ İçe aktarıldı, uygulamayı yeniden başlatmanız önerilir.", en: "✓ Imported, it is recommended to restart the application." },
        icaAktarilamadi: { tr: "✕ İçe aktarılamadı, dosya yolunu kontrol edin.", en: "✕ Import failed, please check the file path." },
        tumVeriyiSil: { tr: "Tüm Verileri Sil", en: "Delete All Data" },
        kapat: { tr: "Kapat", en: "Close" },
        tumVeriyiSilMesaj: { tr: "Tüm ölçüm ve stroke verileri kalıcı olarak silinecek. Sensör kalibrasyonları etkilenmez. Bu işlem GERİ ALINAMAZ, emin misiniz?", en: "All measurement and stroke data will be permanently deleted. Sensor calibrations will not be affected. This action CANNOT BE UNDONE, are you sure?" },
        evetHepsiniSil: { tr: "Evet, Hepsini Sil", en: "Yes, Delete All" },
        tumVerilerSilindi: { tr: "✓ Tüm veriler silindi.", en: "✓ All data deleted." }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    function listeyiYenile() {
        olcumListesi = database.tumOlcumleriGetir()
    }

    onVisibleChanged: {
        if (visible) {
            listeyiYenile()
        }
    }

    Component.onCompleted: listeyiYenile()

    function tarihiAyristir(tarihStr) {
        if (!tarihStr) return null
        var tarihKismi = tarihStr.split(" ")[0].split(".")
        if (tarihKismi.length !== 3) return null
        var gun = parseInt(tarihKismi[0], 10)
        var ay = parseInt(tarihKismi[1], 10)
        var yil = parseInt(tarihKismi[2], 10)
        if (isNaN(gun) || isNaN(ay) || isNaN(yil)) return null
        return new Date(yil, ay - 1, gun)
    }

    function gecerliOzelTarih(metin) {
        if (!metin || metin.length !== 10) return null
        return tarihiAyristir(metin)
    }

    function filtrelenmisListeyiHesapla() {
        var sonuc = []
        var aramaMetni = aramaKutusu.text.toLowerCase()
        var ozelBaslangic = gecerliOzelTarih(gecmisSayfasi.baslangicTarihi)
        var ozelBitis = gecerliOzelTarih(gecmisSayfasi.bitisTarihi)
        var simdi = new Date()

        for (var i = 0; i < olcumListesi.length; i++) {
            var kayit = olcumListesi[i]
            var tarihObj = tarihiAyristir(kayit.tarih)

            if (aramaMetni.length > 0) {
                var musteriEslesir = kayit.musteri.toLowerCase().indexOf(aramaMetni) !== -1
                var receteEslesir = kayit.recete.toLowerCase().indexOf(aramaMetni) !== -1
                if (!musteriEslesir && !receteEslesir) continue
            }

            if (ozelBaslangic || ozelBitis) {
                if (ozelBaslangic && tarihObj && tarihObj < ozelBaslangic) continue
                if (ozelBitis && tarihObj) {
                    var bitisSonu = new Date(ozelBitis.getFullYear(), ozelBitis.getMonth(), ozelBitis.getDate(), 23, 59, 59)
                    if (tarihObj > bitisSonu) continue
                }
            } else if (tarihObj) {
                if (filtreKutusu.currentIndex === 1) {
                    var esik7 = new Date(simdi.getTime() - 7 * 24 * 60 * 60 * 1000)
                    if (tarihObj < esik7) continue
                } else if (filtreKutusu.currentIndex === 2) {
                    var esik30 = new Date(simdi.getTime() - 30 * 24 * 60 * 60 * 1000)
                    if (tarihObj < esik30) continue
                }
            }

            sonuc.push(kayit)
        }

        return sonuc
    }

    property var filtrelenmisListe: filtrelenmisListeyiHesapla()

    readonly property var metinlerBaslik: ({
        gecmisBaslik: { tr: "Geçmiş Kayıtlar", en: "History Records" },
        gecmisAltBaslik: { tr: "Tamamlanan reoloji testlerinin arşivi", en: "Archive of completed rheology tests" },
        toplamKayit: { tr: "Toplam Kayıt", en: "Total Records" },
        sonucBulunamadi: { tr: "Eşleşen kayıt bulunamadı", en: "No matching records found" },
        sonucBulunamadiAlt: { tr: "Arama veya filtre koşullarını değiştirmeyi deneyin", en: "Try adjusting your search or filter criteria" }
    })

    function txt2(anahtar) {
        return Translations.turkish ? metinlerBaslik[anahtar].tr : metinlerBaslik[anahtar].en
    }

    Item {
        anchors.fill: parent
        anchors.margins: 28

        Column {
            id: ustBolum
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

        Row {
            width: parent.width

            Column {
                width: parent.width - 150
                spacing: 3

                Text {
                    text: txt2("gecmisBaslik")
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 0.3
                }

                Text {
                    text: txt2("gecmisAltBaslik")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                width: 150
                height: 48
                radius: 8
                color: "#12121a"
                border.color: "#1e2a3f"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gecmisSayfasi.olcumListesi.length
                        color: "#3b82f6"
                        font.family: "Segoe UI"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: txt2("toplamKayit")
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 9
                        font.letterSpacing: 0.5
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#1e2a3f"
        }

        Row {
            width: parent.width
            spacing: 12

            TextField {
                id: aramaKutusu
                width: parent.width - filtreKutusu.width - gelismisAyarlarButonu.width - parent.spacing * 2
                height: 40
                placeholderText: txt("aramaPlaceholder")
                placeholderTextColor: "#4b5563"
                color: "#dce8f5"
                font.pixelSize: 13
                leftPadding: 34
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: "#12121a"
                    radius: 8
                    border.color: aramaKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "🔍"
                    color: "#4b5563"
                    font.pixelSize: 13
                }
            }

            ComboBox {
                id: filtreKutusu
                width: 160
                height: 40
                model: filtreAnahtarlari.map(function(anahtar) { return txt(anahtar) })

                background: Rectangle {
                    color: "#12121a"
                    radius: 8
                    border.color: filtreKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                    border.width: 1
                }

                contentItem: Text {
                    text: filtreKutusu.displayText
                    color: "#9ca3af"
                    font.pixelSize: 13
                    leftPadding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: gelismisAyarlarButonu
                width: 44
                height: 40
                text: "⚙️"
                font.pixelSize: 15

                onClicked: {
                    gelismisAyarlarPopup.pinDogrulandi = false
                    pinKutusu.text = ""
                    gelismisAyarlarBildirim.text = ""
                    gelismisAyarlarPopup.open()
                }

                background: Rectangle {
                    radius: 8
                    color: parent.hovered ? "#191921" : "#12121a"
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

        Row {
            width: parent.width
            spacing: 10

            Text {
                text: txt("ozelTarih")
                color: "#9ca3af"
                font.family: "Segoe UI"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            TarihSecici {
                id: baslangicSecici
                anchors.verticalCenter: parent.verticalCenter
                secilenTarih: gecmisSayfasi.baslangicTarihi
                onTarihSecildi: function(t) { gecmisSayfasi.baslangicTarihi = t }
            }

            Text {
                text: "—"
                color: "#4b5563"
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }

            TarihSecici {
                id: bitisSecici
                anchors.verticalCenter: parent.verticalCenter
                secilenTarih: gecmisSayfasi.bitisTarihi
                onTarihSecildi: function(t) { gecmisSayfasi.bitisTarihi = t }
            }

            Rectangle {
                width: temizleMetni.implicitWidth + 20
                height: 36
                radius: 8
                color: temizleMouse.containsMouse ? "#191921" : "#12121a"
                border.color: "#1e2a3f"
                border.width: 1
                visible: gecmisSayfasi.baslangicTarihi.length > 0 || gecmisSayfasi.bitisTarihi.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: temizleMetni
                    anchors.centerIn: parent
                    text: txt("temizle")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: temizleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        gecmisSayfasi.baslangicTarihi = ""
                        gecmisSayfasi.bitisTarihi = ""
                    }
                }
            }
        }

        } // ustBolum

        Rectangle {
            id: sonucPaneli
            anchors.top: ustBolum.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            radius: 12
            color: "#12121a"
            border.color: "#1e2a3f"
            border.width: 1
            visible: gecmisSayfasi.filtrelenmisListe.length > 0
            clip: true

            Row {
                id: tabloBasligi
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 18
                height: 20

                Text { width: 56; text: "#"; color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 10; font.letterSpacing: 1; font.bold: true }
                Text { width: parent.width - 56 - 150 - 68 - 152; text: Translations.turkish ? "MÜŞTERİ / REÇETE" : "CUSTOMER / RECIPE"; color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 10; font.letterSpacing: 1; font.bold: true }
                Text { width: 150; text: Translations.turkish ? "TARİH" : "DATE"; color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 10; font.letterSpacing: 1; font.bold: true }
                Text { width: 68; text: Translations.turkish ? "STROKE" : "STROKE"; color: "#4b5563"; font.family: "Segoe UI"; font.pixelSize: 10; font.letterSpacing: 1; font.bold: true }
                Text { width: 152; horizontalAlignment: Text.AlignRight; text: ""; color: "#4b5563"; font.pixelSize: 10 }
            }

            Rectangle {
                anchors.top: tabloBasligi.bottom
                anchors.topMargin: 12
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                height: 1
                color: "#1e2a3f"
            }

            ListView {
                anchors.top: tabloBasligi.bottom
                anchors.topMargin: 13
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4
                clip: true
                spacing: 0

                model: gecmisSayfasi.filtrelenmisListe

                delegate: Rectangle {
                    id: gecmisKarti
                    width: parent ? parent.width : 0
                    height: 58
                    color: kartAlani.containsMouse ? "#16161e" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    MouseArea {
                        id: kartAlani
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        height: 1
                        color: "#1e1e18"
                        visible: index !== gecmisSayfasi.filtrelenmisListe.length - 1
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14

                        Text {
                            width: 56
                            anchors.verticalCenter: parent.verticalCenter
                            text: (index + 1).toString().padStart(2, "0")
                            color: "#4b5563"
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                        }

                        Column {
                            width: parent.width - 56 - 150 - 68 - 152
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                text: modelData.musteri
                                color: "#dce8f5"
                                font.family: "Segoe UI"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.recete
                                color: "#6b7280"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        Text {
                            width: 150
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.tarih
                            color: "#9ca3af"
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                        }

                        Rectangle {
                            width: 68
                            height: 22
                            radius: 5
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#12121a"
                            border.color: "#1e2a3f"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.strokeSayisi
                                color: "#4f8cf7"
                                font.family: "Segoe UI"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Row {
                            width: 152
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            layoutDirection: Qt.RightToLeft

                            Rectangle {
                                id: silButonu
                                width: 30
                                height: 30
                                radius: 6
                                color: silMouse.containsMouse ? "#3f1d24" : "transparent"
                                border.color: silMouse.containsMouse ? "#ef4444" : "#1e2a3f"
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "🗑"
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: silMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        silOnayPopup.hedefId = modelData.id
                                        silOnayPopup.hedefMusteri = modelData.musteri
                                        silOnayPopup.open()
                                    }
                                }
                            }

                            Rectangle {
                                id: goruntuleButonu
                                width: 84
                                height: 30
                                radius: 6
                                color: goruntuleMouse.containsMouse ? "#191921" : "transparent"
                                border.color: goruntuleMouse.containsMouse ? "#3b82f6" : "#1e2a3f"
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: txt("goruntule")
                                    color: goruntuleMouse.containsMouse ? "#dce8f5" : "#9ca3af"
                                    font.family: "Segoe UI"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    id: goruntuleMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: testSecildi(modelData.id)
                                }
                            }
                        }
                    }
                }
            }
        }

        Column {
            anchors.top: ustBolum.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: gecmisSayfasi.filtrelenmisListe.length === 0
            spacing: 8

            Item { width: 1; height: parent.height / 2 - 40 }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "🔍"
                font.pixelSize: 28
                opacity: 0.4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: txt2("sonucBulunamadi")
                color: "#9ca3af"
                font.family: "Segoe UI"
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: txt2("sonucBulunamadiAlt")
                color: "#4b5563"
                font.family: "Segoe UI"
                font.pixelSize: 12
            }
        }
    }

    Popup {
        id: silOnayPopup
        anchors.centerIn: parent
        width: 380
        padding: 24
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        property int hedefId: -1
        property string hedefMusteri: ""

        onOpened: {
            sifreGirisAlani.text = ""
            hataMetni.visible = false
            sifreGirisAlani.forceActiveFocus()
        }

        background: Rectangle {
            color: "#12121a"
            radius: 14
            border.color: "#1e2a3f"
            border.width: 1
        }

        contentItem: Column {
            width: silOnayPopup.availableWidth
            spacing: 16

            Text {
                text: txt("kayitSilBaslik")
                color: "#dce8f5"
                font.family: "Segoe UI"
                font.pixelSize: 17
                font.bold: true
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: txt("kayitSilOnSoru") + silOnayPopup.hedefMusteri + txt("kayitSilSonSoru")
                color: "#9ca3af"
                font.family: "Segoe UI"
                font.pixelSize: 13
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: txt("sifreEtiket")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                TextField {
                    id: sifreGirisAlani
                    width: parent.width
                    height: 40
                    echoMode: TextInput.Password
                    placeholderText: txt("sifrenizGirin")
                    placeholderTextColor: "#4b5563"
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: sifreGirisAlani.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                    Keys.onReturnPressed: silOnaylaButonu.clicked()
                }

                Text {
                    id: hataMetni
                    text: txt("sifreHatali")
                    color: "#ef4444"
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                    visible: false
                }
            }

            Row {
                width: parent.width
                spacing: 10
                layoutDirection: Qt.RightToLeft

                Button {
                    id: silOnaylaButonu
                    width: (parent.width - 10) / 2
                    height: 40
                    text: txt("sil")
                    font.pixelSize: 13
                    font.bold: true

                    onClicked: {
                        if (backend.sifreDogrula(sifreGirisAlani.text)) {
                            database.olcumSil(silOnayPopup.hedefId)
                            gecmisSayfasi.listeyiYenile()
                            silOnayPopup.close()
                        } else {
                            hataMetni.visible = true
                            sifreGirisAlani.text = ""
                            sifreGirisAlani.forceActiveFocus()
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? "#b91c1c" : (parent.hovered ? "#ef4444" : "#dc2626")
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#dce8f5"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    width: (parent.width - 10) / 2
                    height: 40
                    text: txt("iptal")
                    font.pixelSize: 13

                    onClicked: silOnayPopup.close()

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#191921" : "#12121a"
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
    }

    // Orijinal SLIPER'daki "Expert Settings > Database Export / Import / Delete"
    // özelliklerine karşılık gelir (bkz. slipermanV13.pdf bölüm 6). Şifre
    // doğrulaması, uygulamada zaten var olan giriş şifresini (backend.sifreDogrula)
    // kullanır; orijinal cihazdaki ayrı "2603" servis şifresi yerine bu tercih
    // edildi çünkü uygulamada zaten tek bir şifre akışı var.
    Popup {
        id: gelismisAyarlarPopup
        anchors.centerIn: parent
        width: 420
        padding: 24
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        property bool pinDogrulandi: false

        background: Rectangle {
            color: "#12121a"
            radius: 14
            border.color: "#1e2a3f"
            border.width: 1
        }

        contentItem: Column {
            width: gelismisAyarlarPopup.availableWidth
            spacing: 16

            Text {
                text: txt("gelismisAyarlarBaslik")
                color: "#dce8f5"
                font.family: "Segoe UI"
                font.pixelSize: 17
                font.bold: true
            }

            Column {
                width: parent.width
                spacing: 6
                visible: !gelismisAyarlarPopup.pinDogrulandi

                Text {
                    text: txt("sifreEtiket")
                    color: "#6b7280"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    font.letterSpacing: 1
                }

                TextField {
                    id: pinKutusu
                    width: parent.width
                    height: 40
                    echoMode: TextInput.Password
                    placeholderText: txt("sifrenizGirin")
                    placeholderTextColor: "#4b5563"
                    color: "#dce8f5"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0a0d"
                        radius: 6
                        border.color: pinKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                    Keys.onReturnPressed: pinDogrulaButonu.clicked()
                }

                Text {
                    id: pinHataMetni
                    text: txt("sifreHatali")
                    color: "#ef4444"
                    font.family: "Segoe UI"
                    font.pixelSize: 11
                    visible: false
                }

                Button {
                    id: pinDogrulaButonu
                    width: parent.width
                    height: 40
                    text: txt("onayla")
                    font.pixelSize: 13
                    font.bold: true

                    onClicked: {
                        if (backend.sifreDogrula(pinKutusu.text)) {
                            gelismisAyarlarPopup.pinDogrulandi = true
                            pinHataMetni.visible = false
                        } else {
                            pinHataMetni.visible = true
                            pinKutusu.text = ""
                            pinKutusu.forceActiveFocus()
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#dce8f5"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 10
                visible: gelismisAyarlarPopup.pinDogrulandi

                Button {
                    width: parent.width
                    height: 40
                    text: txt("veriTabaniDisaAktar")
                    font.pixelSize: 13

                    onClicked: {
                        var yol = database.veriTabaniDisaAktar()
                        gelismisAyarlarBildirim.text = yol.length > 0
                            ? txt("disaAktarildi") + yol
                            : txt("disaAktarilamadi")
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#191921" : "#12121a"
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
                    }
                }

                Column {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: txt("icaAktarYoluEtiket")
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }

                    TextField {
                        id: icaAktarYoluKutusu
                        width: parent.width
                        height: 40
                        placeholderText: txt("icaAktarPlaceholder")
                        placeholderTextColor: "#4b5563"
                        color: "#dce8f5"
                        font.pixelSize: 12
                        leftPadding: 12
                        verticalAlignment: TextInput.AlignVCenter
                        background: Rectangle {
                            color: "#0a0a0d"
                            radius: 6
                            border.color: icaAktarYoluKutusu.activeFocus ? "#3b82f6" : "#1e2a3f"
                            border.width: 1
                        }
                    }
                }

                Button {
                    width: parent.width
                    height: 40
                    text: txt("veriTabaniIcaAktar")
                    font.pixelSize: 13

                    onClicked: {
                        var basarili = database.veriTabaniIcaAktar(icaAktarYoluKutusu.text)
                        gelismisAyarlarBildirim.text = basarili
                            ? txt("icaAktarildi")
                            : txt("icaAktarilamadi")
                        if (basarili) {
                            gecmisSayfasi.listeyiYenile()
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#191921" : "#12121a"
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
                    }
                }

                Button {
                    width: parent.width
                    height: 40
                    text: txt("tumVeriyiSil")
                    font.pixelSize: 13
                    font.bold: true

                    onClicked: tumVeriyiSilOnayPopup.open()

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? "#b91c1c" : (parent.hovered ? "#ef4444" : "#dc2626")
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#dce8f5"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: gelismisAyarlarBildirim
                    width: parent.width
                    text: ""
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 10
                    wrapMode: Text.WrapAnywhere
                }

                Button {
                    width: parent.width
                    height: 36
                    text: txt("kapat")
                    font.pixelSize: 12

                    onClicked: gelismisAyarlarPopup.close()

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#191921" : "transparent"
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
    }

    // "Tüm Verileri Sil" için çift onay (orijinal cihazdaki "Confirm if you
    // are really sure" uyarısına karşılık gelir).
    Popup {
        id: tumVeriyiSilOnayPopup
        anchors.centerIn: parent
        width: 380
        padding: 24
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#12121a"
            radius: 14
            border.color: "#dc2626"
            border.width: 1
        }

        contentItem: Column {
            width: tumVeriyiSilOnayPopup.availableWidth
            spacing: 16

            Text {
                text: txt("tumVeriyiSil")
                color: "#dce8f5"
                font.family: "Segoe UI"
                font.pixelSize: 17
                font.bold: true
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: txt("tumVeriyiSilMesaj")
                color: "#9ca3af"
                font.family: "Segoe UI"
                font.pixelSize: 13
            }

            Row {
                width: parent.width
                spacing: 10
                layoutDirection: Qt.RightToLeft

                Button {
                    width: (parent.width - 10) / 2
                    height: 40
                    text: txt("evetHepsiniSil")
                    font.pixelSize: 13
                    font.bold: true

                    onClicked: {
                        database.tumVeriyiSil()
                        gecmisSayfasi.listeyiYenile()
                        tumVeriyiSilOnayPopup.close()
                        gelismisAyarlarBildirim.text = txt("tumVerilerSilindi")
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? "#b91c1c" : (parent.hovered ? "#ef4444" : "#dc2626")
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#dce8f5"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    width: (parent.width - 10) / 2
                    height: 40
                    text: txt("iptal")
                    font.pixelSize: 13

                    onClicked: tumVeriyiSilOnayPopup.close()

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#191921" : "#12121a"
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
    }
}
