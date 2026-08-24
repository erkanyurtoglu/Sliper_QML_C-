import QtQuick 6.7

Canvas {
    id: root
    width: 18
    height: 18
    // "olcum" | "sonuclar" | "gecmis" | "kalibrasyon" | "rehber"
    property string tur: "olcum"
    property color renk: "#9ca3af"
    property real kalinlik: 1.6

    onRenkChanged: requestPaint()
    onTurChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var s = Math.min(width, height) / 24
        ctx.save()
        ctx.scale(s, s)
        ctx.strokeStyle = renk
        ctx.fillStyle = renk
        ctx.lineWidth = kalinlik / s
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        switch (tur) {
        case "olcum": {
            // bar chart
            var bars = [ [5, 20, 10], [12, 20, 4], [19, 20, 13] ]
            for (var i = 0; i < bars.length; i++) {
                ctx.beginPath()
                ctx.moveTo(bars[i][0], bars[i][1])
                ctx.lineTo(bars[i][0], bars[i][2])
                ctx.stroke()
            }
            break
        }
        case "sonuclar": {
            // trending line with arrow
            ctx.beginPath()
            ctx.moveTo(3, 17)
            ctx.lineTo(9.5, 10.5)
            ctx.lineTo(13.5, 14.5)
            ctx.lineTo(21, 6)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(15, 6)
            ctx.lineTo(21, 6)
            ctx.lineTo(21, 12)
            ctx.stroke()
            break
        }
        case "gecmis": {
            // clock
            ctx.beginPath()
            ctx.arc(12, 12, 8.5, 0, Math.PI * 2)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(12, 7)
            ctx.lineTo(12, 12.5)
            ctx.lineTo(16, 14.5)
            ctx.stroke()
            break
        }
        case "kalibrasyon": {
            // gear
            var cx = 12, cy = 12, rIn = 5.5, rOut = 8.5, teeth = 8
            ctx.beginPath()
            for (var t = 0; t < teeth; t++) {
                var a = (t / teeth) * Math.PI * 2
                var ax = cx + Math.cos(a) * rOut
                var ay = cy + Math.sin(a) * rOut
                var bx = cx + Math.cos(a) * rIn
                var by = cy + Math.sin(a) * rIn
                ctx.moveTo(bx, by)
                ctx.lineTo(ax, ay)
            }
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(cx, cy, rIn, 0, Math.PI * 2)
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(cx, cy, 2.2, 0, Math.PI * 2)
            ctx.stroke()
            break
        }
        case "rehber": {
            // open book
            ctx.beginPath()
            ctx.moveTo(12, 6.5)
            ctx.bezierCurveTo(10.2, 5, 6.5, 4.5, 3.5, 5.2)
            ctx.lineTo(3.5, 17.5)
            ctx.bezierCurveTo(6.5, 16.8, 10.2, 17.3, 12, 18.8)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(12, 6.5)
            ctx.bezierCurveTo(13.8, 5, 17.5, 4.5, 20.5, 5.2)
            ctx.lineTo(20.5, 17.5)
            ctx.bezierCurveTo(17.5, 16.8, 13.8, 17.3, 12, 18.8)
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(12, 6.5)
            ctx.lineTo(12, 18.8)
            ctx.stroke()
            break
        }
        }

        ctx.restore()
    }
}
