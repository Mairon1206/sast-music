import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI
import "./component"

ApplicationWindow {
    id: window
    visible: true
    width: 1400
    height: 850
    minimumWidth: 1050
    minimumHeight: 720
    title: "SAST Music"

    readonly property color activeColor: "#335eea"
    readonly property color backgroundColor: Qt.rgba(209 / 255, 209 / 255,
                                                     214 / 255, 0.28)
    readonly property string homePageUrl: "qrc:///ui/page/T_home.qml"
    readonly property string explorePageUrl: "qrc:///ui/page/T_explore.qml"
    readonly property string libraryPageUrl: "qrc:///ui/page/T_library.qml"
    property string topPageUrl
    property var undoStack: []
    property var redoStack: []

    StackView {
        id: stackView
        anchors.fill: parent

        function isPageInStack(pageName) {
            for (var i = 0; i < stackView.depth; ++i) {
                if (stackView.get(i).objectName === pageName) {
                    return true
                }
            }
            return false
        }

        // This function pops pages until the target page is on top
        function popToTargetPage(targetPageName) {
            while (stackView.depth > 1
                   && stackView.currentItem.objectName !== targetPageName) {
                stackView.pop()
            }
        }

        // This function pushes a new page or pops to an existing instance of the page
        function pushOrPopToPage(pageUrl, pageName) {
            if (isPageInStack(pageName)) {
                popToTargetPage(pageName)
            } else {
                stackView.push(pageUrl, {
                                   "objectName": pageName
                               })
            }
            topPageUrl = pageUrl
        }

        function pushPage(url) {
            pushOrPopToPage(url, url2Name(url))
            undoStack.push(url)
        }

        function popPage() {
            if (undoStack.length >= 2) {
                redoStack.push(undoStack[undoStack.length - 1])
                undoStack.pop()
                topPageUrl = undoStack[undoStack.length - 1]
                stackView.pushOrPopToPage(topPageUrl, url2Name(topPageUrl))
            }
        }

        function redoPage() {
            if (redoStack.length >= 1) {
                topPageUrl = redoStack[redoStack.length - 1]
                redoStack.pop()
                stackView.pushOrPopToPage(topPageUrl, url2Name(topPageUrl))
            }
        }

        function url2Name(url) {
            if (url === homePageUrl)
                return "home"
            if (url === explorePageUrl)
                return "explore"
            if (url === libraryPageUrl)
                return "library"
        }

        Component.onCompleted: {
            pushPage(homePageUrl)
        }
    }

    BlurRectangle {
        id: navigationBar
        width: parent.width
        height: 60
        blurRadius: 100
        target: stackView
        Row {
            spacing: 5
            anchors {
                left: parent.left
                leftMargin: 65
                verticalCenter: parent.verticalCenter
            }
            IconButton {
                id: btn_back
                width: 40
                height: 40
                hoverColor: backgroundColor
                iconWidth: 22
                iconHeight: 22
                iconUrl: "qrc:///res/img/arrow-left.svg"
                onClicked: stackView.popPage()
            }
            IconButton {
                id: btn_redo
                width: 40
                height: 40
                hoverColor: backgroundColor
                iconWidth: 22
                iconHeight: 22
                iconUrl: "qrc:///res/img/arrow-right.svg"
                onClicked: stackView.redoPage()
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 30

            FluTextButton {
                id: btn_home
                text: "HOME"
                font.family: "Barlow-Bold"
                font.pixelSize: 18
                font.weight: 700
                textColor: topPageUrl === homePageUrl ? activeColor : "#000"
                implicitHeight: 30
                normalColor: Qt.rgba(0, 0, 0, 1)
                backgroundHoverColor: backgroundColor
                onClicked: stackView.pushPage(homePageUrl)
            }

            FluTextButton {
                id: btn_explore
                text: "EXPLORE"
                font.family: "Barlow-Bold"
                font.pixelSize: 18
                font.weight: 700
                textColor: topPageUrl === explorePageUrl ? activeColor : "#000"
                implicitHeight: 30
                normalColor: Qt.rgba(0, 0, 0, 1)
                backgroundHoverColor: backgroundColor
                onClicked: stackView.pushPage(explorePageUrl)
            }

            FluTextButton {
                id: btn_library
                text: "LIBRARY"
                font.family: "Barlow-Bold"
                font.pixelSize: 18
                font.weight: 700
                textColor: topPageUrl === libraryPageUrl ? activeColor : "#000"
                implicitHeight: 30
                normalColor: Qt.rgba(0, 0, 0, 1)
                backgroundHoverColor: backgroundColor
                onClicked: stackView.pushPage(libraryPageUrl)
            }
        }

        SearchBox {
            anchors {
                right: avatar.left
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
            onCommit: content => {// TODO: post search request
                      }
        }

        FluClip {
            id: avatar
            anchors {
                right: parent.right
                rightMargin: 65
                verticalCenter: parent.verticalCenter
            }
            width: 30
            height: 30
            radius: [15, 15, 15, 15]
            Image {
                anchors.fill: parent
                source: "qrc:///res/img/avatar.svg"
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                anchors.fill: parent
                color: item_mouse.containsMouse ? Qt.rgba(46 / 255,
                                                          46 / 255, 41 / 255,
                                                          0.28) : "transparent"
            }

            MouseArea {
                id: item_mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    menu.popup()
                }
            }
        }

        RadiusMenu {
            id: menu
            radius: 15
            RadiusMenuItem {
                iconSize: 20
                iconUrl: "qrc:///res/img/settings.svg"
                text: "Settings"
                font.family: "Barlow-Bold"
                font.bold: true
            }
            RadiusMenuItem {
                iconSize: 20
                iconUrl: "qrc:///res/img/logout.svg"
                text: "Logout"
                font.family: "Barlow-Bold"
                font.bold: true
            }
            MenuSeparator {}
            RadiusMenuItem {
                iconSize: 20
                iconUrl: "qrc:///res/img/github.svg"
                text: "GitHub Repo"
                font.family: "Barlow-Bold"
                font.bold: true
                onClicked: {
                    Qt.openUrlExternally(
                                "https://github.com/NJUPT-SAST-Cpp/sast-music")
                }
            }
        }

        Pane {
            z: -1
            anchors.fill: parent
            focusPolicy: Qt.ClickFocus
        }
    }

    MusicSlider {
        id: progress
        width: parent.width
        height: 2
        radius: 0
        z: 10
        active: true
        handleVisible: item_mouse_progress.containsMouse
        normalColor: "#e6e6e6"
        tooltipEnabled: true
        tipText: "1:32"
        anchors {
            bottom: playerBar.top
        }
    }

    MouseArea {
        id: item_mouse_progress
        hoverEnabled: true
        propagateComposedEvents: true
        height: 20
        z: progress.z + 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 55
        }
        onClicked: mouse => mouse.accepted = false
        onPressAndHold: mouse => mouse.accepted = false
        onPressed: mouse => mouse.accepted = false
        onReleased: mouse => mouse.accepted = false
    }

    BlurRectangle {
        id: playerBar
        width: parent.width
        height: 60
        blurRadius: 100
        target: stackView
        anchors {
            bottom: parent.bottom
        }

        FluClip {
            id: image_song
            radius: [3, 3, 3, 3]
            width: 45
            height: 45
            anchors {
                left: parent.left
                leftMargin: 65
                verticalCenter: parent.verticalCenter
            }
            FluImage {
                anchors.fill: parent
                source: "qrc:///res/img/netease-music.png"
            }
            FluShadow {}
        }

        Text {
            id: text_song
            text: "Song"
            width: 100
            elide: Text.ElideRight
            maximumLineCount: 1
            font.family: "Barlow-Bold"
            font.bold: true
            font.pixelSize: 16
            anchors {
                left: image_song.right
                leftMargin: 10
                top: parent.top
                topMargin: 10
            }
        }

        Text {
            id: text_singer
            text: "singer"
            width: 100
            elide: Text.ElideRight
            maximumLineCount: 1
            font.family: "Barlow-Bold"
            font.pixelSize: 12
            color: "#73706c"
            anchors {
                left: image_song.right
                leftMargin: 10
                top: parent.top
                topMargin: 35
            }
        }

        IconButton {
            property bool liked: false
            width: 30
            height: 30
            iconUrl: liked ? "qrc:///res/img/heart.svg" : "qrc:///res/img/heart-solid.svg"
            anchors {
                left: image_song.right
                leftMargin: 20 + (text_song.implicitWidth > text_singer.implicitWidth ? text_song.implicitWidth : text_singer.implicitWidth)
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                liked = !liked
            }
        }

        IconButton {
            anchors {
                right: btn_play.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
            iconUrl: "qrc:///res/img/previous.svg"
        }

        IconButton {
            id: btn_play
            property bool playing: true
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: 10
            iconWidth: 20
            iconHeight: 25
            iconUrl: playing ? "qrc:///res/img/play.svg" : "qrc:///res/img/pause.svg"
            onClicked: {
                playing = !playing
            }
        }

        IconButton {
            anchors {
                left: btn_play.right
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            iconUrl: "qrc:///res/img/next.svg"
        }

        IconButton {
            anchors {
                right: parent.right
                rightMargin: 65
                verticalCenter: parent.verticalCenter
            }
            id: btn_arrow_up
            iconUrl: "qrc:///res/img/arrow-up.svg"
        }

        MusicSlider {
            id: slider
            anchors {
                right: btn_arrow_up.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            value: 20
            width: 85
            active: item_mouse_slider.containsMouse
            handleVisible: item_mouse_slider.containsMouse
        }
        MouseArea {
            id: item_mouse_slider
            propagateComposedEvents: true
            width: 85
            anchors {
                right: btn_arrow_up.left
                rightMargin: 10
                top: parent.top
                bottom: parent.bottom
                topMargin: 15
                bottomMargin: 15
            }
            onClicked: mouse => mouse.accepted = false
            onPressAndHold: mouse => mouse.accepted = false
            onPressed: mouse => mouse.accepted = false
            onReleased: mouse => mouse.accepted = false
            hoverEnabled: true
        }

        Row {
            anchors {
                right: slider.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            IconButton {
                iconUrl: "qrc:///res/img/list.svg"
            }
            IconButton {
                iconUrl: "qrc:///res/img/repeat.svg"
            }
            IconButton {
                iconUrl: "qrc:///res/img/shuffle.svg"
            }
            IconButton {
                id: btn_volume
                property bool mute: false
                property int value: 0
                iconUrl: mute ? "qrc:///res/img/volume-mute.svg" : (slider.value > 50 ? "qrc:///res/img/volume.svg" : "qrc:///res/img/volume-half.svg")
                onClicked: {
                    if (!mute) {
                        value = slider.value
                        slider.value = 0
                    } else {
                        slider.value = value
                    }
                    mute = !mute
                }
            }
        }
    }
}