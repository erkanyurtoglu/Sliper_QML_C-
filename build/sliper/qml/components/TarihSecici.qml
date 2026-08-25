import QtQuick 6.7
import QtQuick.Controls 6.7
import sliper

Item {
    id: root
    width: 130
    height: 36

    readonly property var metinler: ({
        placeholderMetni: { tr: "gg.aa.yyyy", en: "dd.mm.yyyy" },
        temizleButon: { tr: "Temizle", en: "Clear" }
    })

    function txt(anahtar) {
        return Translations.turkish ? metinler[anahtar].tr : metinler[anahtar].en
    }

    // Kontrollü bileşen: seçili tarih dışarıdan (ör. gecmisSayfasi.baslangicTarihi)
    // bağlanır, kullanıcı bir gün seçtiğinde sadece tarihSecildi sinyali yayılır —
    // root.secilenTarih burada asla doğrudan atanmaz ki dışarıdaki binding kopmasın.
    property string secilenTarih: ""
    property string placeholderText: txt("placeholderMetni")
    property date gorunenAy: new Date()

    readonly property int hucreBoyutu: 28
    readonly property int hucreAraligi: 4
    readonly property int gridGenisligi: 7 * hucreBoyutu + 6 * hucreAraligi

    signal tarihSecildi(string tarihStr)

    function ikiHane(n) {
        return n < 10 ? "0" + n : "" + n
    }

    function tarihStr(d) {
        return ikiHane(d.getDate()) + "." + ikiHane(d.getMonth() + 1) + "." + d.getFullYear()
    }

    function gunSayisi(yil, ay) {
        return new Date(yil, ay + 1, 0).getDate()
    }

    // Takvim ızgarasını (önceki/sonraki aydan taşan günler dahil, Pazartesi başlangıçlı,
    // her zaman 6 hafta = 42 hücre) saf QtQuick ile hesaplar; Qt.labs.calendar modülüne
    // bağımlı değildir çünkü bu Qt kurulumunda mevcut değil.
    function ayGunleriniHesapla(ay) {
        var yil = ay.getFullYear()
        var ayIndeks = ay.getMonth()
        var ilkGun = new Date(yil, ayIndeks, 1)
        var haftaBaslangicKaymasi = (ilkGun.getDay() + 6) % 7 // Pazartesi = 0
        var baslangic = new Date(yil, ayIndeks, 1 - haftaBaslangicKaymasi)

        var gunler = []
        for (var i = 0; i < 42; i++) {
            gunler.push(new Date(baslangic.getFullYear(), baslangic.getMonth(), baslangic.getDate() + i))
        }
        return gunler
    }

    property var gunHucreleri: ayGunleriniHesapla(gorunenAy)

    readonly property var ayAdlari: [
        { tr: "Ocak", en: "January" }, { tr: "Şubat", en: "February" }, { tr: "Mart", en: "March" },
        { tr: "Nisan", en: "April" }, { tr: "Mayıs", en: "May" }, { tr: "Haziran", en: "June" },
        { tr: "Temmuz", en: "July" }, { tr: "Ağustos", en: "August" }, { tr: "Eylül", en: "September" },
        { tr: "Ekim", en: "October" }, { tr: "Kasım", en: "November" }, { tr: "Aralık", en: "December" }
    ]
    readonly property var haftaGunleri: [
        { tr: "Pt", en: "Mo" }, { tr: "Sa", en: "Tu" }, { tr: "Ça", en: "We" },
        { tr: "Pe", en: "Th" }, { tr: "Cu", en: "Fr" }, { tr: "Ct", en: "Sa" }, { tr: "Pz", en: "Su" }
    ]

    Rectangle {
        id: kutu
        anchors.fill: parent
        radius: 8
        color: "#12121a"
        border.color: (alan.containsMouse || takvimPopup.visible) ? "#3b82f6" : "#1e2a3f"
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Text {
            anchors.left: parent.left
            anchors.right: simgeMetni.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: root.secilenTarih.length > 0 ? root.secilenTarih : root.placeholderText
            color: root.secilenTarih.length > 0 ? "#dce8f5" : "#4b5563"
            font.family: "Segoe UI"
            font.pixelSize: 13
        }

        Text {
            id: simgeMetni
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "📅"
            font.pixelSize: 12
            color: "#6b7280"
        }

        MouseArea {
            id: alan
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.secilenTarih.length === 10) {
                    var parcalar = root.secilenTarih.split(".")
                    root.gorunenAy = new Date(parseInt(parcalar[2], 10), parseInt(parcalar[1], 10) - 1, 1)
                } else {
                    root.gorunenAy = new Date()
                }
                takvimPopup.open()
            }
        }
    }

    Popup {
        id: takvimPopup
        y: kutu.height + 6
        width: root.gridGenisligi + 28
        padding: 14
        modal: true
        focus: true
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
            spacing: 10

            Row {
                width: root.gridGenisligi
                height: 28

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: oncekiAlan.containsMouse ? "#1e2a3f" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "#9ca3af"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: oncekiAlan
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.gorunenAy = new Date(root.gorunenAy.getFullYear(), root.gorunenAy.getMonth() - 1, 1)
                    }
                }

                Text {
                    width: parent.width - 56
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: (Translations.turkish ? root.ayAdlari[root.gorunenAy.getMonth()].tr : root.ayAdlari[root.gorunenAy.getMonth()].en) + " " + root.gorunenAy.getFullYear()
                    color: "#dce8f5"
                    font.family: "Segoe UI"
                    font.pixelSize: 13
                    font.bold: true
                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: sonrakiAlan.containsMouse ? "#1e2a3f" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "#9ca3af"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: sonrakiAlan
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.gorunenAy = new Date(root.gorunenAy.getFullYear(), root.gorunenAy.getMonth() + 1, 1)
                    }
                }
            }

            Row {
                width: root.gridGenisligi
                spacing: root.hucreAraligi

                Repeater {
                    model: root.haftaGunleri

                    delegate: Text {
                        width: root.hucreBoyutu
                        horizontalAlignment: Text.AlignHCenter
                        text: Translations.turkish ? modelData.tr : modelData.en
                        color: "#6b7280"
                        font.family: "Segoe UI"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            Grid {
                width: root.gridGenisligi
                columns: 7
                rowSpacing: root.hucreAraligi
                columnSpacing: root.hucreAraligi

                Repeater {
                    model: root.gunHucreleri

                    delegate: Rectangle {
                        id: gunHucresi
                        width: root.hucreBoyutu
                        height: root.hucreBoyutu
                        radius: root.hucreBoyutu / 2
                        property bool buAyMi: modelData.getMonth() === root.gorunenAy.getMonth()
                        property bool seciliMi: root.secilenTarih === root.tarihStr(modelData)
                        property bool bugunMu: root.tarihStr(modelData) === root.tarihStr(new Date())
                        color: seciliMi ? "#3b82f6" : (gunAlani.containsMouse ? "#1e2a3f" : "transparent")
                        border.color: (bugunMu && !seciliMi) ? "#3b82f6" : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.getDate()
                            color: gunHucresi.buAyMi ? (gunHucresi.seciliMi ? "#dce8f5" : "#dce8f5") : "#374151"
                            font.family: "Segoe UI"
                            font.pixelSize: 12
                            font.bold: gunHucresi.seciliMi
                        }

                        MouseArea {
                            id: gunAlani
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.tarihSecildi(root.tarihStr(modelData))
                                takvimPopup.close()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: root.gridGenisligi
                height: 1
                color: "#1e2a3f"
            }

            Rectangle {
                width: root.gridGenisligi
                height: 30
                radius: 6
                color: temizleAlani.containsMouse ? "#1e2a3f" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: root.txt("temizleButon")
                    color: "#9ca3af"
                    font.family: "Segoe UI"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: temizleAlani
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.tarihSecildi("")
                        takvimPopup.close()
                    }
                }
            }
        }
    }
}
