/*
 * Copyright 2019 by Aditya Mehra <aix.m@outlook.com>
 * Copyright 2019 by Marco Martin <mart@kde.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.3
import QtMultimedia 5.9
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft
import QtQuick.Templates 2.12 as T

Item {
    id: root

    property var source
    property string status: "stop"
    property int switchWidth: Kirigami.Units.gridUnit * 22
    property alias thumbnail: albumimg.source
    property alias title: songtitle.text
    property bool progressBar: true
    property bool thumbnailVisible: true
    property bool titleVisible: true
    property var nextAction
    property var previousAction
    readonly property bool horizontal: width > switchWidth
    readonly property var audioService: Mycroft.MediaService

    //Mediaplayer Related Properties To Be Set By Probe MediaPlayer
    property var currentState: audioService.playbackState
    property var playerDuration: 0
    property var playerPosition: 0

    //Spectrum Related Properties
    property var spectrum: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property var soundModelLength: audioService.spectrum.length
    property color spectrumColorNormal: Qt.rgba(33/255, 148/255, 190/255, 0.7)
    property color spectrumColorMid: spectrumColorNormal
    property color spectrumColorPeak: Qt.rgba(33/255, 190/255, 166/255, 0.7)
    property real spectrumScale: 1
    property bool spectrumVisible: true
    readonly property real spectrumHeight: (rep.parent.height / normalize(spectrumScale))

    onEnabledChanged: syncStatusTimer.restart()
    onSourceChanged: {
        syncStatusTimer.restart()
        if (!root.title) {
            fetchMetaTitleFromFile()
        }
        play()
    }
    Component.onCompleted: syncStatusTimer.restart()

    // Sometimes can't be restarted reliably immediately, put it in a timer
    onActiveFocusChanged: {
        if(activeFocus){
            playButton.forceActiveFocus();
        }
    }

    Component.onDestruction: stop()

    function formatedDuration(millis){
        var minutes = Math.floor(millis / 60000);
        var seconds = ((millis % 60000) / 1000).toFixed(0);
        return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
    }

    function formatedPosition(millis){
        var minutes = Math.floor(millis / 60000);
        var seconds = ((millis % 60000) / 1000).toFixed(0);
        return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
    }

    function normalize(e){
        switch(e){case.1:return 10;case.2:return 9;case.3:return 8;
        case.4:return 7;case.5:return 6;case.6:return 5;case.7:return 4;case.8:return 3;                                                                                                                   case.9:return 2;case 1:return 1; default: return 1}
    }

    function fetchMetaTitleFromFile() {
        var playerMeta = audioService.getPlayerMeta()
        var title = playerMeta.Title
        if(title !== "" || title !== " ") {
            songtitle.text = root.playerMeta.Title
        }
    }

    Connections {
        target: Mycroft.MediaService

        onDurationChanged: {
            playerDuration = dur
            seekableslider.to = playerDuration
        }
        onPositionChanged: {
            playerPosition = pos
        }

        onMediaStatusChanged: {
            if (status == MediaPlayer.EndOfMedia) {
                pause()
            }
        }
    }

    Timer {
        id: sampler
        running: true
        interval: 100
        repeat: true
        onTriggered: {
            spectrum = audioService.spectrum
        }
    }
    
    Timer {
        id: syncStatusTimer
        interval: 0
        onTriggered: {
            if (enabled && status == "play") {
                play();
            } else if (status == "stop") {
                stop();
            } else {
                pause();
            }
        }
    }

    function play(){
        audioService.playURL(source)
    }

    function pause(){
        audioService.playerPause()
    }

    function stop(){
        audioService.playerStop()
    }

    function resume(){
        audioService.playerContinue()
    }

    function seek(val){
        audioService.playerSeek(val)
    }

    GridLayout {
        anchors {
            top: root.horizontal ? undefined : parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: Mycroft.Units.gridUnit * 2
            leftMargin: Mycroft.Units.gridUnit * 2
            rightMargin: Mycroft.Units.gridUnit * 2
        }
        columns: root.horizontal ? 2 : 1
        height: implicitHeight

        Image {
            id: albumimg
            fillMode: Image.PreserveAspectCrop
            visible: root.thumbnailVisible ? 1 : 0
            enabled: root.thumbnailVisible ? 1 : 0
            Layout.preferredWidth: root.horizontal ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 5
            Layout.preferredHeight: root.horizontal ? Kirigami.Units.gridUnit * 10 : Kirigami.Units.gridUnit * 5
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                id: songtitle
                text: title
                level: root.horizontal ? 1 : 3
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.capitalization: Font.Capitalize
                visible: root.titleVisible ? 1 : 0
                enabled: root.titleVisible ? 1 : 0
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: root.horizontal ? Qt.AlignLeft : Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                Controls.RoundButton {
                    id: previousButton
                    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.minimumHeight: width
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                    Layout.maximumHeight: width
                    focus: false
                    icon.name: "media-seek-backward"
                    KeyNavigation.right: playButton
                    KeyNavigation.down: seekableslider
                    onClicked: {
                        triggerGuiEvent(previousAction, {})
                    }

                    background: Rectangle {
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        radius: width
                        color: previousButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }

                Controls.RoundButton {
                    id: playButton
                    Layout.minimumWidth: Kirigami.Units.iconSizes.medium
                    Layout.minimumHeight: width
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 4
                    Layout.maximumHeight: width
                    focus: false
                    icon.name: root.currentState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                    KeyNavigation.left: previousButton
                    KeyNavigation.right: nextButton
                    KeyNavigation.down: seekableslider
                    onClicked: {
                        root.currentState === MediaPlayer.PlayingState ? root.pause() : root.currentState === MediaPlayer.PausedState ? root.resume() : root.play()
                    }

                    background: Rectangle {
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        radius: width
                        color: playButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }

                Controls.RoundButton {
                    id: nextButton
                    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.minimumHeight: width
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: Kirigami.Units.gridUnit * 3
                    Layout.maximumHeight: width
                    focus: false
                    icon.name: "media-seek-forward"
                    KeyNavigation.left: playButton
                    KeyNavigation.down: seekableslider
                    onClicked: {
                        triggerGuiEvent(nextAction, {})
                    }

                    background: Rectangle {
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        radius: width
                        color: nextButton.activeFocus ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    }

                    Keys.onReturnPressed: {
                        clicked()
                    }
                }
            }

            Rectangle {
                id: spectrumAreaCentered
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                color: "transparent"

                Row {
                    id: repRows
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    visible: spectrumVisible
                    enabled: spectrumVisible
                    z: -5

                    Repeater {
                        id: rep
                        model: root.soundModelLength - 1

                        delegate: Rectangle {
                            width: (spectrumAreaCentered.width - (repRows.spacing * root.soundModelLength)) / root.soundModelLength
                            radius: 3
                            opacity: root.currentState === MediaPlayer.PlayingState ? 1 : 0
                            height: 15 + root.spectrum[modelData] * root.spectrumHeight
                            anchors.bottom: parent.bottom

                            gradient: Gradient {
                                GradientStop {position: 0.05; color: height > root.spectrumHeight / 1.25 ? spectrumColorPeak : spectrumColorNormal}
                                GradientStop {position: 0.25; color: spectrumColorMid}
                                GradientStop {position: 0.50; color: spectrumColorNormal}
                                GradientStop {position: 0.85; color: spectrumColorMid}
                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.Linear
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation{
                                    duration: 1500 + root.spectrum[modelData] * parent.height
                                    easing.type: Easing.Linear
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
                visible: root.progressBar ? 1 : 0
                enabled: root.progressBar ? 1 : 0

                T.Slider {
                    id: seekableslider
                    //to: root.playerDuration
                    Layout.fillWidth: true
                    Layout.preferredHeight: Mycroft.Units.gridUnit
                    property bool sync: false
                    value: root.playerPosition

                    handle: Item {
                        x: seekableslider.visualPosition * (parent.width - (Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing))
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height + Mycroft.Units.gridUnit

                        Rectangle {
                            id: hand
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing
                            implicitHeight: parent.height
                            color: seekableslider.activeFocus ?"#21bea6" : Qt.rgba(0.2, 0.2, 0.2, 1)
                            border.color: "#21bea6"
                        }
                    }

                    background: Rectangle {
                        color: Qt.rgba(55/255, 214/255, 250/255, 0.6)

                        Rectangle {
                            width: seekableslider.visualPosition * parent.width
                            height: parent.height
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#21bea6" }
                                GradientStop { position: 1.0; color: "#2194be" }
                            }
                        }
                    }

                    onPressedChanged: {
                        root.seek(value)
                        resume()
                    }

                    Keys.onLeftPressed: {
                        var l = 0
                        l = seekableslider.position - 0.05
                        root.seek(seekableslider.valueAt(l));
                    }
                    
                    Keys.onRightPressed: {
                        var l = 0
                        l = seekableslider.position + 0.05
                        root.seek(seekableslider.valueAt(l));
                    }
                }

                Controls.Label {
                    id: positionLabel
                    text: formatedPosition(root.playerPosition) + " / " + formatedDuration(root.playerDuration)
                }
            }
        }
    }
}

