import Cocoa

class ConfigureSheetController : NSObject {
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var checkingForUpdatesLabel: NSTextField!

    let checkForUpdatesService: CheckForUpdatesService = .live

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        if !myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil) {
            fatalError("Could not load configure sheet")
        }

        Task {
            let isUpdateAvailable = await checkForUpdatesService.isUpdateAvailable()
            await renderUpdateButton(isUpdateAvailable: isUpdateAvailable)
        }
    }

    @MainActor
    private func renderUpdateButton(isUpdateAvailable: Bool) {
        if isUpdateAvailable {
            updateButton.isEnabled = true
            checkingForUpdatesLabel.isHidden = true
        }
        else {
            checkingForUpdatesLabel.stringValue = "No updates available."
        }
    }

    @IBAction func onClickUpdate(_ sender: Any) {
        let url = URL(string: "https://github.com/netlight/dancing-boids/releases")!
        NSWorkspace.shared.open(url)
    }

    @IBAction func closeWindow(_ sender: Any) {
        window.endSheet(window)
    }
}
