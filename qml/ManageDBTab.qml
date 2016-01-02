import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2

Item
{
    MessageDialog
    {
        id: errorDialog
        icon: StandardIcon.Critical
    }

    MessageDialog
    {
        id: confirmPersonDeletion
        icon: StandardIcon.Question
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: deletePersonConfirmed(idToDelete)

        property int idToDelete
    }

    MessageDialog
    {
        id: confirmRestaurantDeletion
        icon: StandardIcon.Question
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: deleteRestaurant(idToDelete)

        property int idToDelete
    }

    PersonDialog
    {
        id: addPersonDialog
        onAccepted: { addPerson(personName, restaurants); }
    }

    PersonDialog
    {
        id: editPersonDialog
        property int personId
        onAccepted: { editPerson(personId, personName, restaurants); }
    }

    RestaurantDialog
    {
        id: addRestaurantDialog
        onAccepted: addRestaurant(restaurantName, restaurantComment)
    }

    RestaurantDialog
    {
        id: editRestaurantDialog
        property int restaurantId
        onAccepted: editRestaurant(restaurantId, restaurantName, restaurantComment)
    }

    anchors.fill: parent
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    RowLayout
    {
        anchors.fill: parent
        ManageDBTabSide
        {
            id: peopleSide
            Layout.fillWidth: true
            height: parent.height
            model: myModel.peopleList
            onAddClicked: addPersonDialog.openWithParams("", [])
            onDeleteClicked: deletePersonPressed(itemId)
            onEditClicked: editPersonPressed(itemId)
        }

        Rectangle
        {
            width: 1
            height: parent.height
            color: sysPalette.mid
        }

        ManageDBTabSide
        {
            id: restaurantSide
            Layout.fillWidth: true
            height: parent.height
            anchors.right: parent.right
            model: myModel.allRestaurantsList
            onAddClicked: addRestaurantDialog.openWithParams("", "")
            onDeleteClicked: {console.log(itemId); deleteRestaurantPressed(itemId)}
            onEditClicked: editRestaurantPressed(itemId)
        }
    }


    /***********************/
    /****** functions ******/
    /***********************/

    /** delete person **/
    function deletePersonPressed(id)
    {
        if (id == -1)
        {
            errorDialog.text = "Please select a person to delete"
            errorDialog.open()
            return
        }
        confirmPersonDeletion.idToDelete = id
        confirmPersonDeletion.text = "Are you sure you want to delete person id=" + confirmPersonDeletion.idToDelete
        confirmPersonDeletion.open()

        return
    }
    function deletePersonConfirmed(id)
    {
        var result = myModel.deletePersonById(id)
        console.log("Deleting " + id + " result=" + result)
        if (!result)
        {
            errorDialog.text = "Person no longer exists"
            errorDialog.open()
        }
    }

    /** add person **/

    function addPerson(name, restaurants)
    {
        var result = myModel.addPerson(name, restaurants)
        if (!result)
        {
            errorDialog.text = "An error occurred while adding new person"
            errorDialog.open()
        }

    }
    /** edit person **/
    function editPersonPressed(personId)
    {
        var person = myModel.getPersonById(personId)
        editPersonDialog.personId = personId
        editPersonDialog.openWithParams(person.name, person.restaurants)
        editPersonDialog.open()
    }
    function editPerson(id, name, restaurants)
    {
        var result = myModel.editPerson(id, name, restaurants)
        if (!result)
        {
            errorDialog.text = "An error occurred while adding new person"
            errorDialog.open()
        }
    }

    /** delete restaurant **/
    function deleteRestaurantPressed(id)
    {
        if (id == -1)
        {
            errorDialog.text = "Please select a restaurant to delete"
            errorDialog.open()
            return
        }
        confirmRestaurantDeletion.idToDelete = id
        confirmRestaurantDeletion.text = "Are you sure you want to delete restaurant id=" + confirmRestaurantDeletion.idToDelete
        confirmRestaurantDeletion.open()

        return
    }
    function deleteRestaurant(id)
    {
        var result = myModel.deleteRestaurantById(id)
        console.log("Deleting " + id + " result=" + result)
        if (!result)
        {
            errorDialog.text = "Error while deleting restaurant"
            errorDialog.open()
        }
    }

    function addRestaurant(name, comment)
    {
        if (!myModel.addRestaurant(name, comment))
        {
            errorDialog.text = "Error occured while adding restaurant"
            errorDialog.open()
            return
        }
    }
    function editRestaurantPressed(id)
    {
        if (id == -1)
        {
            errorDialog.text = "Please select a restaurant to edit"
            errorDialog.open()
            return
        }
        var restaurant = myModel.getRestaurantById(id)
        if (restaurant.id == -1)
        {
            errorDialog.text = "Couldn't load restaurant"
            errorDialog.open()
            return
        }
        editRestaurantDialog.restaurantId = id
        editRestaurantDialog.openWithParams(restaurant.name, restaurant.comment)
    }
    function editRestaurant(restaurantId, restaurantName, restaurantComment)
    {
        var result = myModel.editRestaurant(restaurantId, restaurantName, restaurantComment)
        if (!result)
        {
            errorDialog.text = "An error occurred while adding new person"
            errorDialog.open()
        }
    }

}
