import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.setFrame(NSScreen.main!.visibleFrame, display: true)
        let screenSaverView = DancingBoidsView(frame: (window.contentView?.bounds)!, isPreview: false)
        window.contentView?.addSubview(screenSaverView)
        screenSaverView.startAnimation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
