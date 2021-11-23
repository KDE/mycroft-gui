import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: control
    property alias color: marqueeText.color
    property alias text: marqueeText.text
    property alias font: marqueeText.font
    property alias minimumPointSize: marqueeText.minimumPointSize
    property alias minimumPixelSize: marqueeText.minimumPixelSize
    property alias fontSizeMode: marqueeText.fontSizeMode
    property alias horizontalAlignment: marqueeText.horizontalAlignment
    property alias verticalAlignment: marqueeText.verticalAlignment
    property int speed: 1000
    property int delay: 1000
    property var marqueeWidth: width

    onWidthChanged: {
        marqueeWidth = width
        reset()
    }

    function reset() {
        if(marqueeAnimator.running) {
            marqueeAnimator.stop()
            marqueeText.width = control.marqueeWidth
            marqueeText.x = control.x
            coverText.width = marqueeText.width
            coverText.x = 0 - marqueeWidth
            marqueeAnimator.start()
        } else {
            marqueeAnimator.start()
        }
        marqueeText.enabled = false
        marqueeText.enabled = true
    }

    Text {
        id: marqueeText;
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        width: parent.width
        elide: Text.ElideRight
    }

    Text {
        id: coverText;
        horizontalAlignment: marqueeText.horizontalAlignment
        verticalAlignment: marqueeText.verticalAlignment
        height: marqueeText.height
        width: marqueeText.width
        elide: marqueeText.elide
        x: marqueeText.x - marqueeText.width
        font: marqueeText.font
        color: marqueeText.color
        text: marqueeText.text
        minimumPointSize: marqueeText.minimumPointSize
        minimumPixelSize: marqueeText.minimumPixelSize
        fontSizeMode: marqueeText.fontSizeMode
    }

    SequentialAnimation {
        id: marqueeAnimator
        loops: Animation.Infinite
        running: false

        PropertyAnimation {
            target: marqueeText
            property: "opacity"
            from: 1
            to: 1
            duration: control.delay
        }
        ParallelAnimation {
            PropertyAnimation {
                target: marqueeText
                property: "x"
                from: 0
                to: marqueeWidth
                duration: speed
            }
            PropertyAnimation {
                target: coverText
                property: "x"
                from: control.x - marqueeWidth
                to: marqueeText.x
                duration: speed
            }
        }
    }
}
