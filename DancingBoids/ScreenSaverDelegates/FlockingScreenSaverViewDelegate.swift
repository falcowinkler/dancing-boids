import Flockingbird
import ScreenSaver

struct FlockingScreenSaverViewDelegate: ScreenSaverViewDelegate {
    let flockSim: FlockSimulation
    let frame: NSRect
    let isPreview: Bool

    init(frame: NSRect, isPreview: Bool, layer: CALayer) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: SSRandomIntBetween(100, 200),
                         maxX: Int32(frame.size.width), maxY: Int32(frame.size.height)),
            simulationParameters: FlockSimulationParameters(
                fromDict:
                    ["maxX": Int(frame.size.width),
                     "maxY": Int(frame.size.height)]))
        self.frame = frame
        self.isPreview = isPreview
    }

    func draw(_ rect: NSRect) {
        let bPath:NSBezierPath = NSBezierPath(rect: rect)
        NSColor.black.set()
        bPath.fill()

        let context = NSGraphicsContext.current!.cgContext
        for boid in flockSim.currentFlock.boids {
            let x = abs(boid.position.x)
            let y = abs(boid.position.y)
            let theta = atan2(boid.velocity.y, boid.velocity.x) - Float(Double.pi) / 2
            context.saveGState()

            context.setStrokeColor(CGColor(red: 0.5 - CGFloat(y) / (self.frame.height * 4),
                                           green: 0.25 + CGFloat(y) / (self.frame.height * 4),
                                           blue: 0.5 + CGFloat(y) / (self.frame.height * 2), alpha: 1))
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
    
    func animateOneFrame() {
        flockSim.step()
    }
}
