import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SessionManagementScreen {

    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property int usernameFontSize

    property string lastUserName

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents.TextField {
        id: userNameInput
        Layout.fillWidth: true

        text: lastUserName
        font.family: config.Font || "Noto Sans"
        font.hintingPreference: config.FontHinting || "PreferDefaultHinting"
        font.pointSize: config.FontSize || "9"

        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        onAccepted: passwordBox.forceActiveFocus()
    }

    PlasmaComponents.TextField {
        id: passwordBox
        Layout.fillWidth: true

        font.family: config.Font || "Noto Sans"
        font.hintingPreference: config.FontHinting || "PreferDefaultHinting"
        font.pointSize: config.FontSize || "9"

        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password
        revealPasswordButtonShown: true

        onAccepted: startLogin()

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        //if empty and left or right is pressed change selection in user switch
        //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }
    PlasmaComponents.Button {
        id: loginButton
        Layout.fillWidth: true

        font.family: config.Font || "Noto Sans"
        font.hintingPreference: config.FontHinting || "PreferNoHinting"
        font.pointSize: config.FontSize || "9"


        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
        onClicked: startLogin();
    }

}
