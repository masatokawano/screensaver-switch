import Cocoa

func L(_ key: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

struct Preset {
    let minutes: Int
    let icon: String?
}

struct Config {
    let presets: [Preset]
    let shortThreshold: Int  // minutes

    static let defaultConfig = Config(
        presets: [
            Preset(minutes: 1, icon: nil),
            Preset(minutes: 30, icon: nil)
        ],
        shortThreshold: 1
    )

    static func load() -> Config {
        let configPath = NSString(string: "~/.config/screensaver-switch/config.yaml").expandingTildeInPath

        guard FileManager.default.fileExists(atPath: configPath),
              let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            return defaultConfig
        }

        return parse(yaml: content)
    }

    static func parse(yaml content: String) -> Config {
        var presets: [Preset] = []
        var shortThreshold = 1
        var inPresets = false

        for line in content.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            if trimmed.hasPrefix("presets:") {
                inPresets = true
                continue
            }

            if trimmed.hasPrefix("short_threshold:") {
                let value = trimmed.replacingOccurrences(of: "short_threshold:", with: "").trimmingCharacters(in: .whitespaces)
                shortThreshold = Int(value) ?? 1
                inPresets = false
                continue
            }

            if inPresets && trimmed.hasPrefix("- ") {
                let value = trimmed.replacingOccurrences(of: "- ", with: "").trimmingCharacters(in: .whitespaces)
                if let minutes = Int(value) {
                    presets.append(Preset(minutes: minutes, icon: nil))
                }
            }
        }

        if presets.isEmpty {
            return defaultConfig
        }

        return Config(presets: presets, shortThreshold: shortThreshold)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var config: Config!

    func applicationDidFinishLaunching(_ notification: Notification) {
        config = Config.load()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if statusItem.button != nil {
            updateIcon()
        }

        buildMenu()
        statusItem.menu = menu
    }

    func buildMenu() {
        menu = NSMenu()

        for (index, preset) in config.presets.enumerated() {
            let title = String(format: L("menu.setMinutes"), preset.minutes)
            let item = NSMenuItem(title: title, action: #selector(presetSelected(_:)), keyEquivalent: index < 9 ? String(index + 1) : "")
            item.tag = preset.minutes
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem(title: L("menu.custom"), action: #selector(setCustom), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L("menu.quit"), action: #selector(quit), keyEquivalent: "q"))
    }

    @objc func presetSelected(_ sender: NSMenuItem) {
        setIdleTime(sender.tag * 60)
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
        let currentMinutes = currentTime / 60
        let isShort = currentMinutes <= config.shortThreshold

        if let button = statusItem.button {
            button.title = isShort ? "⏱️" : "💤"
            let format = L("tooltip.format")
            button.toolTip = String(format: format, currentMinutes)
        }
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
