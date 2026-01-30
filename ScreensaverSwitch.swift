import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!

    let shortTime = 60      // 1分
    let longTime = 1800     // 30分

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateIcon()
        }

        menu = NSMenu()
        menu.addItem(NSMenuItem(title: "1分に設定", action: #selector(setShort), keyEquivalent: "1"))
        menu.addItem(NSMenuItem(title: "30分に設定", action: #selector(setLong), keyEquivalent: "3"))
        menu.addItem(NSMenuItem(title: "カスタム設定...", action: #selector(setCustom), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    func getCurrentIdleTime() -> Int {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["-currentHost", "read", "com.apple.screensaver", "idleTime"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               let time = Int(output) {
                return time
            }
        } catch {
            print("Error reading idle time: \(error)")
        }

        return 0
    }

    func setIdleTime(_ seconds: Int) {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["-currentHost", "write", "com.apple.screensaver", "idleTime", "-int", String(seconds)]

        do {
            try task.run()
            task.waitUntilExit()
            updateIcon()
        } catch {
            print("Error setting idle time: \(error)")
        }
    }

    func updateIcon() {
        let currentTime = getCurrentIdleTime()
        let isShort = currentTime <= shortTime

        if let button = statusItem.button {
            // 1分の時は時計アイコン、30分の時はスリープアイコン
            button.title = isShort ? "⏱️" : "💤"
            button.toolTip = "スクリーンセーバー: \(currentTime / 60)分"
        }
    }

    @objc func setShort() {
        setIdleTime(shortTime)
    }

    @objc func setLong() {
        setIdleTime(longTime)
    }

    @objc func setCustom() {
        let alert = NSAlert()
        alert.messageText = "スクリーンセーバー待機時間"
        alert.informativeText = "分単位で入力してください:"
        alert.addButton(withTitle: "設定")
        alert.addButton(withTitle: "キャンセル")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        input.stringValue = String(getCurrentIdleTime() / 60)
        alert.accessoryView = input

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            if let minutes = Int(input.stringValue), minutes > 0 {
                setIdleTime(minutes * 60)
            }
        }
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
