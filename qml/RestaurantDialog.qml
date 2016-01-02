import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Dialog
{
    id: root
    standardButtons: StandardButton.Save | StandardButton.Discard
    width: layout.implicitWidth
    property string restaurantName : ''
    property variant restaurantComment : ''

    onAccepted: {restaurantComment = txtRestaurantComment.text; root.restaurantName = txtRestaurantName.text}

    GridLayout
    {
        id: layout
        columns:2

        Label { text: "Name:" }
        TextField {
            id: txtRestaurantName
            Layout.fillWidth:true
            text: root.restaurantName
        }
        Label { text: "Comments:"; Layout.alignment: Qt.AlignTop }
        TextArea
        {
            id: txtRestaurantComment
            Layout.fillWidth:true
            text: root.restaurantComment
        }
    }

    function openWithParams(name, comment)
    {
        root.restaurantName = name
        root.restaurantComment = comment
        root.open()
    }
}
