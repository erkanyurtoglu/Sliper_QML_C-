import QtQuick 6.7
import QtQuick.Controls 6.7
import "../components"

Rectangle {
    id: gecmisSayfasi
    color: "#0a0e17"

    signal testSecildi(int id)

    property var olcumListesi: []
    property string baslangicTarihi: ""
    property string bitisTarihi: ""

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

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Row {
            width: parent.width
            spacing: 12

            TextField {
                id: aramaKutusu
                width: parent.width - filtreKutusu.width - parent.spacing
                height: 40
                placeholderText: "Müşteri veya reçete ara..."
                placeholderTextColor: "#4b5563"
                color: "#ffffff"
                font.pixelSize: 13
                leftPadding: 34
                verticalAlignment: TextInput.AlignVCenter
                background: Rectangle {
                    color: "#0f1420"
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
                model: ["Tüm Testler", "Son 7 Gün", "Son 30 Gün"]

                background: Rectangle {
                    color: "#0f1420"
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
        }

        Row {
            width: parent.width
            spacing: 10

            Text {
                text: "Özel Tarih:"
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
                color: temizleMouse.containsMouse ? "#162033" : "#0f1420"
                border.color: "#1e2a3f"
                border.width: 1
                visible: gecmisSayfasi.baslangicTarihi.length > 0 || gecmisSayfasi.bitisTarihi.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: temizleMetni
                    anchors.centerIn: parent
                    text: "Temizle"
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

        ListView {
            width: parent.width
            height: parent.height - 96
            clip: true
            spacing: 10

            model: gecmisSayfasi.filtrelenmisListe

            delegate: Rectangle {
                id: gecmisKarti
                width: parent.width
                height: 76
                radius: 10
                color: "#0f1420"
                border.color: kartAlani.containsMouse ? "#3b82f6" : "#1e2a3f"
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                MouseArea {
                    id: kartAlani
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                Rectangle {
                    id: rozet
                    width: 44
                    height: 44
                    radius: 10
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 16
                    color: "#132335"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.musteri.charAt(0).toUpperCase()
                        color: "#3b82f6"
                        font.family: "Segoe UI"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                Column {
                    anchors.left: rozet.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 14
                    spacing: 4

                    Row {
                        spacing: 8

                        Text {
                            text: modelData.tarih
                            color: "#6b7280"
                            font.family: "Segoe UI"
                            font.pixelSize: 11
                        }

                        Rectangle {
                            width: strokeMetni.implicitWidth + 12
                            height: 16
                            radius: 8
                            color: "#2a2010"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: strokeMetni
                                anchors.centerIn: parent
                                text: modelData.strokeSayisi + " stroke"
                                color: "#e8a020"
                                font.family: "Segoe UI"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: "Müşteri: " + modelData.musteri + "  •  Reçete: " + modelData.recete
                        color: "#dce8f5"
                        font.family: "Segoe UI"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 16
                    spacing: 8

                    Rectangle {
                        id: silButonu
                        width: 34
                        height: 34
                        radius: 6
                        color: silMouse.containsMouse ? "#3f1d24" : "#1a1420"
                        border.color: silMouse.containsMouse ? "#ef4444" : "#2a2030"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "🗑"
                            font.pixelSize: 14
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

                    Button {
                        anchors.verticalCenter: parent.verticalCenter
                        height: 34
                        text: "Görüntüle"
                        font.pixelSize: 12

                        onClicked: testSecildi(modelData.id)

                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#4f8cf7" : "#3b82f6"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                            rightPadding: 8
                        }
                    }
                }
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
            color: "#0f1420"
            radius: 14
            border.color: "#1e2a3f"
            border.width: 1
        }

        contentItem: Column {
            width: silOnayPopup.availableWidth
            spacing: 16

            Text {
                text: "Kaydı Sil"
                color: "#ffffff"
                font.family: "Segoe UI"
                font.pixelSize: 17
                font.bold: true
            }

            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "'" + silOnayPopup.hedefMusteri + "' ölçümünü silmek istediğinize emin misiniz? Bu işlem geri alınamaz."
                color: "#9ca3af"
                font.family: "Segoe UI"
                font.pixelSize: 13
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "ŞİFRE"
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
                    placeholderText: "Şifrenizi girin"
                    placeholderTextColor: "#4b5563"
                    color: "#ffffff"
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: TextInput.AlignVCenter
                    background: Rectangle {
                        color: "#0a0e17"
                        radius: 6
                        border.color: sifreGirisAlani.activeFocus ? "#3b82f6" : "#1e2a3f"
                        border.width: 1
                    }
                    Keys.onReturnPressed: silOnaylaButonu.clicked()
                }

                Text {
                    id: hataMetni
                    text: "Şifre hatalı, tekrar deneyin."
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
                    text: "Sil"
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
                        color: "#ffffff"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    width: (parent.width - 10) / 2
                    height: 40
                    text: "İptal"
                    font.pixelSize: 13

                    onClicked: silOnayPopup.close()

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered ? "#162033" : "#0f1420"
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