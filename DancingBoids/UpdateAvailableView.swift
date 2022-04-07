import Foundation
import AppKit
class UpdateAvailableView: NSView {
    func checkIfNewerVersionIsAvailable() async -> Bool {
        let url = URL(string: "https://api.github.com/repos/pointfreeco/swift-composable-architecture/releases/latest")!
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {
            return false
        }
        let remoteVersion = json["tag_name"] as! String
        let path = Bundle.main.path(forResource: "current_tag", ofType: "txt")!
        let localVersion = try! String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        return localVersion != remoteVersion
    }

    override func viewDidMoveToWindow() {
        let label = NSTextField()
        label.stringValue = ""
        label.textColor = .lightGray
        label.isEditable = false
        label.isSelectable = false
        label.backgroundColor = .clear
        label.drawsBackground = false
        label.isBezeled = false
        label.alignment = .natural
        label.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: label.controlSize))
        label.lineBreakMode = .byClipping
        label.cell?.isScrollable = true
        label.cell?.wraps = false
        label.sizeToFit()
        self.addSubview(label)

        Task.init {
            let newVersionAvailable = await checkIfNewerVersionIsAvailable()
            if newVersionAvailable {
                label.stringValue = "Update available! please open the config sheet"
                label.sizeToFit()
            }
        }
    }
}
