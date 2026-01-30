#!/bin/bash
set -e

echo "Building ScreensaverSwitch..."
swiftc -o ScreensaverSwitch.app/Contents/MacOS/ScreensaverSwitch ScreensaverSwitch.swift -framework Cocoa
echo "Done! Run with: open ScreensaverSwitch.app"
