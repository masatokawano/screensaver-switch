# ScreensaverSwitch

A macOS menu bar app to quickly switch screensaver idle time with one click.

[日本語](README.ja.md)

## Features

- Stays in the menu bar, displaying current setting with an icon
  - `⏱️` : Set to 1 minute (short)
  - `💤` : Set to 30 minutes (long)
- Click to open menu and easily switch between 1 min / 30 min
- Custom setting allows any time (in minutes)
- Multi-language support (10 languages)

## Requirements

- macOS 10.15 (Catalina) or later
- Swift (for building from source)

## Installation

### Using pre-built app

```bash
open ScreensaverSwitch.app
```

### Build from source

```bash
./build.sh
open ScreensaverSwitch.app
```

## Usage

1. Launch the app and an icon will appear in the menu bar
2. Click the icon to open the menu
3. Select "Set to 1 min", "Set to 30 min", or "Custom..."
   - Custom setting allows entering any number of minutes in a dialog

### Launch at Login

Add `ScreensaverSwitch.app` to `System Settings > General > Login Items`.

## Supported Languages

The app automatically switches based on your system language settings.

- English
- 日本語
- 中文（简体）
- 中文（繁體）
- 한국어
- Deutsch
- Français
- Español
- Eesti
- Українська

## File Structure

```
screensaver-switch/
├── ScreensaverSwitch.swift    # Main source code
├── ScreensaverSwitch.app/     # Built app bundle
│   └── Contents/
│       ├── Info.plist         # App configuration
│       ├── MacOS/
│       │   └── ScreensaverSwitch  # Executable
│       └── Resources/         # Localization resources
│           └── *.lproj/
├── Resources/                 # Source localization files
│   ├── en.lproj/
│   ├── ja.lproj/
│   └── ...
├── build.sh                   # Build script
└── README.md                  # This file
```

## Technical Details

### Technologies Used

- **Language**: Swift
- **Framework**: Cocoa (AppKit)
- **Architecture**: Menu bar app using NSStatusItem

### How Screensaver Settings Are Changed

Uses the macOS `defaults` command to modify screensaver idle time:

```bash
# Read
defaults -currentHost read com.apple.screensaver idleTime

# Write (e.g., set to 60 seconds)
defaults -currentHost write com.apple.screensaver idleTime -int 60
```

### LSUIElement

Setting `LSUIElement` to `true` in `Info.plist` makes the app run as a menu bar-only app without showing a Dock icon.

## License

MIT License
