import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let frame = NSRect(x: 0, y: 0, width: 792, height: 792)
        window.setFrame(frame, display: true)
        let screenSaverView = DancingBoidsView(frame: frame, isPreview: false)
        window.contentView?.addSubview(screenSaverView)
        screenSaverView.startAnimation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
