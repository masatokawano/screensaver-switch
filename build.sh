#!/bin/bash
set -e

echo "Building ScreensaverSwitch..."

# Create app bundle structure
mkdir -p ScreensaverSwitch.app/Contents/MacOS
mkdir -p ScreensaverSwitch.app/Contents/Resources

# Compile
swiftc -o ScreensaverSwitch.app/Contents/MacOS/ScreensaverSwitch ScreensaverSwitch.swift -framework Cocoa

# Copy localization resources
cp -r Resources/*.lproj ScreensaverSwitch.app/Contents/Resources/

echo "Done! Run with: open ScreensaverSwitch.app"
