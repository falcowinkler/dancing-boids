import Foundation
import AppKit
class UpdateAvailableView: NSView {
    var checkForUpdateService: CheckForUpdatesService = .live

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
            let newVersionAvailable = await checkForUpdateService.isUpdateAvailable()
            if newVersionAvailable {
                label.stringValue = "New version available! Open the screensaver settings to update."
                label.sizeToFit()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 30) {
                label.isHidden = true
            }
        }
    }
}
