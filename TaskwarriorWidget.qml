import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    function formatDue(raw) {
        if (!raw) return ""
        const due = new Date(
            raw.substring(0,4) + "-" + raw.substring(4,6) + "-" + raw.substring(6,8) +
            "T" + raw.substring(9,11) + ":" + raw.substring(11,13) + ":" + raw.substring(13,15) + "Z"
        )
        const diffMin = Math.round((due - new Date()) / 60000)
        if (diffMin < -2880) return Math.round(diffMin / 1440) + "d"
        if (diffMin < -1440) return "yesterday"
        if (diffMin < -60)   return Math.round(diffMin / 60) + "h"
        if (diffMin < 0)     return diffMin + "min"
        if (diffMin < 1)     return "now"
        if (diffMin < 60)    return diffMin + "min"
        if (diffMin < 1440)  return Math.round(diffMin / 60) + "h"
        if (diffMin < 2880)  return "tomorrow"
        return Math.round(diffMin / 1440) + "d"
    }

    property var tasks: []
    readonly property int pendingCount: tasks.length

    Component {
        id: doneProcessComponent

        Process {
            property int taskId: 0
            command: ["task", taskId.toString(), "done"]

            onExited: (exitCode) => {
                if (exitCode !== 0)
                    console.error("[taskwarrior] failed to complete task", taskId)
                taskProcess.running = true
                destroy()
            }
        }
    }

    function markDone(id) {
        const p = doneProcessComponent.createObject(root, { taskId: id })
        if (p) p.running = true
    }

    Process {
        id: taskProcess
        running: false
        command: ["sh", "-c", "task status:pending export"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text)
                    root.tasks = parsed.sort((a, b) => (b.urgency ?? 0) - (a.urgency ?? 0))
                } catch (e) {
                    console.error("[taskwarrior] parse error:", e)
                }
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: taskProcess.running = true
    }

    Component.onCompleted: taskProcess.running = true

    horizontalBarPill: Component {
        Row {
            spacing: (root.barConfig?.noBackground ?? false) ? 1 : 2

            DankIcon {
                name: "task_alt"
                size: Theme.barIconSize(root.barThickness, -4)
                color: Theme.widgetIconColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.pendingCount.toString()
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: "task_alt"
                size: Theme.barIconSize(root.barThickness)
                color: Theme.widgetIconColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.pendingCount.toString()
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Tasks"
            detailsText: root.pendingCount + " pending"
            showCloseButton: true

            headerActions: Component {
                DankActionButton {
                    iconName: "refresh"
                    iconColor: Theme.surfaceVariantText
                    buttonSize: 28
                    tooltipText: "Refresh"
                    tooltipSide: "bottom"
                    onClicked: taskProcess.running = true
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingS

                Repeater {
                    model: root.tasks.slice(0, 10)

                    delegate: StyledRect {
                        required property var modelData
                        width: parent.width
                        height: cardContent.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.withAlpha(Theme.surfaceContainerHighest, Theme.popupTransparency)

                        Row {
                            id: cardContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: {
                                    const u = modelData.urgency ?? 0
                                    if (u >= 10) return Theme.error
                                    if (u >= 5)  return Theme.warning ?? Theme.primary
                                    return Theme.primary
                                }
                            }

                            Column {
                                width: parent.width - 8 - 28 - Theme.spacingM * 2
                                spacing: 2

                                StyledText {
                                    width: parent.width
                                    text: modelData.description ?? ""
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    elide: Text.ElideRight
                                }

                                Row {
                                    spacing: Theme.spacingS
                                    visible: !!(modelData.priority || modelData.due || (modelData.tags ?? []).length > 0)

                                    Rectangle {
                                        visible: !!modelData.priority
                                        width: priorityLabel.implicitWidth + 6
                                        height: priorityLabel.implicitHeight + 2
                                        radius: 3
                                        color: {
                                            switch (modelData.priority) {
                                                case "H": return Theme.error
                                                case "M": return Theme.warning ?? Theme.primary
                                                default:  return Theme.surfaceVariantText
                                            }
                                        }
                                        anchors.verticalCenter: parent.verticalCenter

                                        StyledText {
                                            id: priorityLabel
                                            anchors.centerIn: parent
                                            text: modelData.priority ?? ""
                                            font.pixelSize: Theme.fontSizeSmall - 2
                                            color: Theme.onPrimary ?? "white"
                                            font.weight: Font.Bold
                                        }
                                    }

                                    StyledText {
                                        visible: !!modelData.due
                                        text: root.formatDue(modelData.due ?? "")
                                        font.pixelSize: Theme.fontSizeSmall - 2
                                        color: {
                                            const d = modelData.due ?? ""
                                            if (!d) return Theme.surfaceVariantText
                                            const due = new Date(d.substring(0,4)+"-"+d.substring(4,6)+"-"+d.substring(6,8)+"T"+d.substring(9,11)+":"+d.substring(11,13)+":"+d.substring(13,15)+"Z")
                                            return due < new Date() ? Theme.error : Theme.surfaceVariantText
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        model: modelData.tags ?? []
                                        delegate: Rectangle {
                                            required property string modelData
                                            height: tagLabel.implicitHeight + 4
                                            width: tagLabel.implicitWidth + 10
                                            radius: height / 2
                                            color: Theme.surfaceContainerHigh ?? Theme.surfaceVariant ?? "#33ffffff"
                                            anchors.verticalCenter: parent.verticalCenter

                                            StyledText {
                                                id: tagLabel
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Theme.fontSizeSmall - 2
                                                color: Theme.primary
                                            }
                                        }
                                    }
                                }
                            }
                            DankActionButton {
                                iconName: "check_circle"
                                iconColor: Theme.primary
                                buttonSize: 28
                                tooltipText: "Mark done"
                                tooltipSide: "left"
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: root.markDone(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
