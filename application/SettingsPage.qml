/*
 * Copyright 2018 Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.Page {
    title: "Settings"
    objectName: "Settings"
    
    Column {
        id: settingsLayout
        anchors.fill: parent
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.Heading {
            id: websocketLabel
            level: 2
            font.bold: true
            color: Kirigami.Theme.textColor;
            width: parent.width
            text: "Websocket Address"
        }
        
        Controls.Label {
            id: exampleLabel
            text: "Example: <tt>ws://192.168.1.1</tt>"
            width: parent.width
        }
        
        Rectangle {
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            color: Kirigami.Theme.backgroundColor
            width: parent.width
            height: Kirigami.Units.gridUnit * 3
            radius: 5
            
            Controls.TextField {
                id: webSocketAddressField
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: Kirigami.Units.largeSpacing
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -Kirigami.Units.smallSpacing
                Component.onCompleted:{
                    webSocketAddressField.text = Mycroft.GlobalSettings.webSocketAddress
                }
            }
        }

        RowLayout {
           width: parent.width
           height: Kirigami.Units.gridUnit * 4
                       
           Controls.Button {
                id: applySettings
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                text: "Apply"
                
                onClicked:{ 
                    Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                    Mycroft.MycroftController.reconnect()
                }
            }
           
           Controls.Button{
                id: reverSettings
                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                text: "Revert"
                
                onClicked: {
                    webSocketAddressField.text = "ws://0.0.0.0"
                    Mycroft.GlobalSettings.webSocketAddress = webSocketAddressField.text
                    Mycroft.MycroftController.reconnect()
                }
            }
        }
        
        Item {
            height: Kirigami.Units.largeSpacing * 2
        }
        
        Kirigami.Heading {
            level: 2
            text: "About Application"
            font.bold: true
            width: parent.width
            color: Kirigami.Theme.textColor
        }

        Controls.Label {
            id: mycroftAndroidAppVersionLabel
            text: "Application Version: 0.80"
            width: parent.width
            color: Kirigami.Theme.textColor;
        }
        
        Controls.Label {
            id: mycroftGuiVersionLabel
            text: "GUI Version: 1.0"
            width: parent.width
            color: Kirigami.Theme.textColor;
        }
    }
}
