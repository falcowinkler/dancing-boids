import ScreenSaver

class DancingBoidsView : ScreenSaverView {
    
    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    

    override func draw(_ rect: NSRect) {
        let bPath:NSBezierPath = NSBezierPath(rect: bounds)
        NSColor(red: 0, green: 0.0, blue: 1, alpha: 1).set()
        bPath.fill()

     }
    
    override func animateOneFrame() {
    }
}
    

