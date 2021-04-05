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
        NSColor.white.set()
        bPath.fill()
        NSColor(red: 0, green: 0, blue: 0, alpha: 1).set()
        let flock = Flockingbird(numberOfBoids: 10)
        for boid in flock!.currentFlock.boids {
            let x = abs(boid.position.x)
            let y = abs(boid.position.y)
            let dx: CGFloat = CGFloat(x) * (bounds.width / 10)
            let dy: CGFloat = CGFloat(y) * (bounds.height / 10)
            let bPath:NSBezierPath = NSBezierPath(rect: CGRect(x: dx, y: dy, width: 10, height: 10))
            bPath.fill()
        }
     }
    
    override func animateOneFrame() {
    }
}
    

