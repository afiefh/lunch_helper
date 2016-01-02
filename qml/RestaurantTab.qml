import QtQuick 2.0
import QtQuick.Controls 1.3

Item
{
    SplitView
    {
        id:restaurantSplit
        anchors.fill: parent;
        TableView {
            id: peopleTable
            TableViewColumn {
                role: "name"
                title: "Person"
            }
            selectionMode: SelectionMode.MultiSelection
            model: myModel.peopleList

            onClicked: {
                restaurantTable.selection.clear();
                var arr = [];
                peopleTable.selection.forEach(function(rowIndex) { arr.push(model.rowToId(rowIndex)); } );
                myModel.setRestaurantIntersectionIds(arr);
                commentTab.height = 0
            }
        }
        Item
        {
            id: rightSide
            Item
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: commentTab.top

                TableView {
                    id: restaurantTable
                    anchors.fill: parent
                    TableViewColumn {
                        role: "name"
                        title: "Restaurant"
                    }
                    model: myModel.restaurantsIntersectionList

                    onClicked: {
                        if (currentRow != -1)
                        {
                            commentTab.height = rightSide.height * 0.5
                            var restaurantId = model.rowToId(currentRow)
                            var restaurant = myModel.getRestaurantById(restaurantId)
                            restaurantName.text = restaurant.name
                            restaurantComment.text = restaurant.comment
                        }
                        else
                        {
                            commentTab.height = 0
                        }
                    }
                }
                Daffy {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 5;
                    anchors.bottomMargin: 5;
                }
            }
            Item
            {
                id: commentTab
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                //height: parent.height/2
                Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.OutCirc } }
                Label
                {
                    id: restaurantName
                    text: "Name"
                    font.pixelSize: 22
                    anchors.top: parent.top
                }
                Label
                {
                    id: restaurantComment
                    text: "comment"
                    anchors.top: restaurantName.bottom
                }
            }
        }
    }
}
