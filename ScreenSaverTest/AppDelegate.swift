import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    lazy var screenSaverView = DancingBoidsView(frame: NSZeroRect, isPreview: false)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        screenSaverView.frame = (window.contentView?.bounds)!
        window.contentView?.addSubview(screenSaverView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
