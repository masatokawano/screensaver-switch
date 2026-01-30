import Cocoa

func L(_ key: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!

    let shortTime = 60      // 1 min
    let longTime = 1800     // 30 min

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if statusItem.button != nil {
            updateIcon()
        }

        menu = NSMenu()
        menu.addItem(NSMenuItem(title: L("menu.set1min"), action: #selector(setShort), keyEquivalent: "1"))
        menu.addItem(NSMenuItem(title: L("menu.set30min"), action: #selector(setLong), keyEquivalent: "3"))
        menu.addItem(NSMenuItem(title: L("menu.custom"), action: #selector(setCustom), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L("menu.quit"), action: #selector(quit), keyEquivalent: "q"))

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
            button.title = isShort ? "⏱️" : "💤"
            let format = L("tooltip.format")
            button.toolTip = String(format: format, currentTime / 60)
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
        alert.messageText = L("dialog.title")
        alert.informativeText = L("dialog.message")
        alert.addButton(withTitle: L("dialog.ok"))
        alert.addButton(withTitle: L("dialog.cancel"))

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
