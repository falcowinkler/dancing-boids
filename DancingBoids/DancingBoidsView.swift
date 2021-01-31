import ScreenSaver
import Flockingbird

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
        NSColor(red: CGFloat(Flockingbird().my_num()), green: CGFloat(Flockingbird().my_num()), blue: CGFloat(Flockingbird().my_num()), alpha: 1).set()
        bPath.fill()
     }
    
    override func animateOneFrame() {
    }
}
    

