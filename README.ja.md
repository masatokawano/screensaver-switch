# ScreensaverSwitch

macOSのスクリーンセーバー待機時間をワンクリックで切り替えるメニューバーアプリです。

[English](README.md)

## 機能

- メニューバーに常駐し、現在の設定をアイコンで表示
  - `⏱️` : 1分（短時間）に設定中
  - `💤` : 30分（長時間）に設定中
- クリックでメニューを開き、1分/30分を簡単に切り替え
- カスタム設定で任意の時間（分単位）を指定可能
- 多言語対応（10言語）

## 必要環境

- macOS 10.15 (Catalina) 以降
- Swift（再ビルドする場合）

## インストール

### ビルド済みアプリを使用

```bash
open ScreensaverSwitch.app
```

### ソースからビルド

```bash
./build.sh
open ScreensaverSwitch.app
```

## 使い方

1. アプリを起動するとメニューバーにアイコンが表示されます
2. アイコンをクリックしてメニューを開きます
3. 「1分に設定」「30分に設定」または「カスタム設定...」を選択します
   - カスタム設定では任意の分数をダイアログで入力できます

### ログイン時に自動起動

`システム設定 > 一般 > ログイン項目` に `ScreensaverSwitch.app` を追加してください。

## 対応言語

システムの言語設定に応じて自動的に切り替わります。

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

## ファイル構成

```
screensaver-switch/
├── ScreensaverSwitch.swift    # メインソースコード
├── ScreensaverSwitch.app/     # ビルド済みアプリバンドル
│   └── Contents/
│       ├── Info.plist         # アプリ設定
│       ├── MacOS/
│       │   └── ScreensaverSwitch  # 実行ファイル
│       └── Resources/         # ローカライズリソース
│           └── *.lproj/
├── Resources/                 # ソースローカライズファイル
│   ├── en.lproj/
│   ├── ja.lproj/
│   └── ...
├── build.sh                   # ビルドスクリプト
└── README.md                  # このファイル
```

## 技術詳細

### 使用技術

- **言語**: Swift
- **フレームワーク**: Cocoa (AppKit)
- **アーキテクチャ**: NSStatusItem を使用したメニューバーアプリ

### スクリーンセーバー設定の変更方法

macOSの `defaults` コマンドを使用してスクリーンセーバーの待機時間を変更しています：

```bash
# 読み取り
defaults -currentHost read com.apple.screensaver idleTime

# 書き込み（例: 60秒に設定）
defaults -currentHost write com.apple.screensaver idleTime -int 60
```

### LSUIElement

`Info.plist` で `LSUIElement` を `true` に設定することで、Dockにアイコンを表示せずメニューバーのみに常駐するアプリとして動作します。

## ライセンス

MIT License
