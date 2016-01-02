import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

Item
{
    id: root
    width: parent.width * 0.5
    height: parent.height

    property var model
    signal addClicked()
    signal deleteClicked(int itemId)
    signal editClicked(int itemId)

    function rowToId(row)
    {
        var result = row == -1 ? -1 : modelTable.model.rowToId(row)
        console.log(result)
        return result
    }

    TableView
    {
        id: modelTable
        anchors.top: parent.top
        anchors.bottom: buttonRow.top
        anchors.right: parent.right
        anchors.left: parent.left
        model: root.model
        headerVisible: false
        onDoubleClicked: root.editClicked(rowToId(modelTable.currentRow))
        TableViewColumn {
            role: "name"
        }
    }

    RowLayout
    {
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        Button
        {
            id: addPerson
            anchors.left: parent.left
            Layout.fillWidth: true
            text: "+"
            tooltip: "Add Person"
            onClicked: root.addClicked()

            style: ButtonStyle {
                label: Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 20
                    text: control.text
                }
            }
        }
        Button
        {
            id: deletePerson
            anchors.left: addPerson.right
            Layout.fillWidth: true
            text: "🚮"
            tooltip: "Delete Person"
            onClicked: root.deleteClicked(rowToId(modelTable.currentRow))

            style: ButtonStyle {
                label: Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 20
                    text: control.text
                }
            }
        }
        Button
        {
            id: editPerson
            anchors.left: deletePerson.right
            anchors.right: parent.right
            Layout.fillWidth: true
            text: "✎"
            tooltip: "Edit Person"
            onClicked: root.editClicked(rowToId(modelTable.currentRow))

            style: ButtonStyle {
                label: Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 20
                    text: control.text
                }
            }
        }
    }
}
