import ScreenSaver
import Flockingbird

class DancingBoidsView : ScreenSaverView {
    let flockSim: FlockSimulation
    override init(frame: NSRect, isPreview: Bool) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: 100, maxX: 1024, maxY: 600),
            simulationParameters: FlockSimulationParameters(fromDict: ["maxX": 1024, "maxY": 600]))
        super.init(frame: frame, isPreview: isPreview)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    override func draw(_ rect: NSRect) {
        let bPath:NSBezierPath = NSBezierPath(rect: bounds)
        NSColor.white.set()
        bPath.fill()
        NSColor(red: 0, green: 0, blue: 0, alpha: 1).set()
        let context = NSGraphicsContext.current!.cgContext
        for boid in flockSim.currentFlock.boids {
            let x = abs(boid.position.x)
            let y = abs(boid.position.y)
            let theta = atan2(boid.velocity.y, boid.velocity.x) - Float(Double.pi)/2;
            context.saveGState()
            context.setFillColor(.black)
            context.translateBy(x: CGFloat(x), y: CGFloat(y))
            context.rotate(by: CGFloat(theta))
            context.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10)])
            context.drawPath(using: .fillStroke)
            context.restoreGState()
        }
     }

    override func animateOneFrame() {
        super.animateOneFrame()
        flockSim.step()
        setNeedsDisplay(bounds)
    }
}
    

