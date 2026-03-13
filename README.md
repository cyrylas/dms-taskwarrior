# Taskwarrior for DMS

A DankMaterialShell bar widget that shows your pending Taskwarrior tasks sorted by urgency.

## Features

- Displays pending task count in the bar (horizontal and vertical layouts)
- Popout panel showing top 10 tasks sorted by urgency
- Urgency dot indicator (red for high urgency ≥10, amber for ≥5, primary color otherwise)
- Priority badges (H/M/L) color-coded by severity
- Relative due dates (e.g. `2h`, `tomorrow`, `3d`) with overdue tasks highlighted in red
- Tag pills for each task
- Manual refresh button in popout header
- Auto-refreshes every 60 seconds

## Requirements

- [Taskwarrior](https://taskwarrior.org/) — the `task` CLI must be in PATH

## Installation

### Via DMS Settings (recommended)

1. Open DMS Settings → Plugins
2. Click "Scan for Plugins"
3. Find **Taskwarrior** and enable it
4. Add the widget to the bar

### Manual

```sh
git clone https://github.com/cyrylas/dms-taskwarrior ~/.config/DankMaterialShell/plugins/taskwarrior
```

Then scan and enable in DMS Settings → Plugins.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

- **Author**: Michał Wazgird - *cyrylas*
- **DankMaterialShell**: [DankMaterialShell Project](https://github.com/AvengeMedia/DankMaterialShell)
- **QML/Qt**: [Qt Project](https://www.qt.io/)

## Support

For issues, questions, or feature requests:

- Open an issue on GitHub

## Roadmap

- [ ] Transations
- [ ] Mark tasks as completed
- [ ] Add tasks
- [ ] Group tasks by tags

