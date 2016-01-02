import QtQuick 2.0
import QtQuick.Controls 1.3

ApplicationWindow {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    width: tabView.implicitWidth * 2
    height: tabView.implicitHeight * 2
    title: "Lunch Helper"
    TabView
    {
        id: tabView
        anchors.fill: parent
        Tab
        {
            title: "Restaurants"
            RestaurantTab
            {
                id: restaurantSplit
                anchors.fill: parent
            }
        }
        Tab
        {
            title: "Manage DB"
            ManageDBTab
            {
                id: manageDBTab
                anchors.fill: parent
            }
        }
    }

}
