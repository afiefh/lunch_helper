import QtQuick 2.0

MouseArea
{
    Image
    {
        id: daffy
        source: "../images/daffy.gif"
    }
    Image
    {
        id: daffyFlipped
        source: "../images/daffy_i.gif"
        visible: false
    }
    width: daffy.width
    height: daffy.height

    onClicked: {
        daffy.visible = !daffy.visible;
        daffyFlipped.visible = !daffyFlipped.visible;
    }
}
