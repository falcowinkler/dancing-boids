import ScreenSaver
import Flockingbird

class DancingBoidsView : ScreenSaverView {
    let flockSim: FlockSimulation
    override init(frame: NSRect, isPreview: Bool) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: 100, maxX: Int32(frame.size.width), maxY: Int32(frame.size.height)),
            simulationParameters: FlockSimulationParameters(
                fromDict:
                    ["maxX": Int(frame.size.width),
                     "maxY": Int(frame.size.height)]))
        super.init(frame: frame, isPreview: isPreview)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    override func draw(_ rect: NSRect) {
        let bPath:NSBezierPath = NSBezierPath(rect: bounds)
        NSColor.black.set()
        bPath.fill()

        let context = NSGraphicsContext.current!.cgContext
        for boid in flockSim.currentFlock.boids {
            let x = abs(boid.position.x)
            let y = abs(boid.position.y)
            let theta = atan2(boid.velocity.y, boid.velocity.x) - Float(Double.pi)/2;
            context.saveGState()
            context.setStrokeColor(.white)
            context.translateBy(x: CGFloat(x), y: CGFloat(y))
            context.rotate(by: CGFloat(theta))
            context.addLines(between: [
                CGPoint(x: -2.5, y: 0),
                CGPoint(x: 2.5, y: 0),
                CGPoint(x: 0, y: 10),
                CGPoint(x: -2.5, y: 0)
            ])
            context.drawPath(using: .stroke)
            context.restoreGState()
        }
     }

    override func animateOneFrame() {
        super.animateOneFrame()
        flockSim.step()
        setNeedsDisplay(bounds)
    }
}
    

