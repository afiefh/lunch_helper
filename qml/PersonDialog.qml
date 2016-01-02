import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2

Dialog
{
    id: root
    standardButtons: StandardButton.Save | StandardButton.Discard
    width: layout.implicitWidth
    property string personName : ''
    property variant restaurants : []

    onAccepted: {
        root.personName = txtPersonName.text
        root.restaurants = []
        lstPersonRestaurants.selection.forEach( function(rowIndex) {root.restaurants.push(lstPersonRestaurants.model.rowToId(rowIndex)); } )
    }

    GridLayout
    {
        id: layout
        columns:2

        Label { text: "Name:" }
        TextField {
            id: txtPersonName
            Layout.fillWidth:true
            text: root.personName
            onEditingFinished: root.personName = text
        }
        Label { text: "Restaurants:"; Layout.alignment: Qt.AlignTop }
        TableView
        {
            id: lstPersonRestaurants
            Layout.fillWidth:true
            selectionMode: SelectionMode.MultiSelection
            model: myModel.allRestaurantsList
            headerVisible: false
            TableViewColumn {
                role: "name"
            }
        }
    }

    function selectRestaurants(restaurantIds)
    {
        lstPersonRestaurants.selection.clear()
        for (var row=0; row<lstPersonRestaurants.rowCount; row++)
        {
            var id = lstPersonRestaurants.model.rowToId(row)
            var shouldBeSelected = restaurantIds.indexOf(id)
            if (shouldBeSelected != -1)
            {
                lstPersonRestaurants.selection.select(row);
            }
        }
    }
    function openWithParams(name, restaurantIds)
    {
        root.personName = name
        selectRestaurants(restaurantIds)
        root.open()
    }
}
