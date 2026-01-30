# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

ScreensaverSwitch - macOSのスクリーンセーバー待機時間をワンクリックで切り替えるメニューバー常駐アプリ。1分/30分のプリセット切り替えに加え、任意の時間（分単位）も設定可能。

## 技術スタック

- **言語**: Swift
- **フレームワーク**: Cocoa (AppKit)
- **対象OS**: macOS 10.15+

## ビルド方法

```bash
# ビルドスクリプトを使用
./build.sh

# または直接コンパイル
swiftc -o ScreensaverSwitch.app/Contents/MacOS/ScreensaverSwitch ScreensaverSwitch.swift -framework Cocoa
```

## 実行方法

```bash
open ScreensaverSwitch.app
```

## ファイル構成

- `ScreensaverSwitch.swift` - メインソースコード（NSStatusItemを使用したメニューバーアプリ）
- `ScreensaverSwitch.app/` - ビルド済みアプリバンドル
- `build.sh` - ビルドスクリプト
- `README.md` - プロジェクトドキュメント

## アーキテクチャ

シンプルな単一ファイル構成。AppDelegateクラスでメニューバーアイテムの管理とスクリーンセーバー設定の読み書きを行う。`defaults` コマンドを使用して `com.apple.screensaver` の `idleTime` を操作。
