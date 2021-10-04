import Flockingbird
import ScreenSaver

struct LuminecentBoidsScreenSaverViewDeletgate: ScreenSaverViewDelegate {
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
                     "maxY": Int(frame.size.height),
                     ]))
        self.frame = frame
        self.isPreview = isPreview
    }

    private func magnitude(_ vector: Vector) -> Float {
        return sqrt(vector.x*vector.x + vector.y*vector.y)
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
            let brightness = CGFloat(min(1, exp(magnitude(boid.velocity) / 10) - 1))
            context.setStrokeColor(CGColor(red: 116/255, green: 186/255, blue: 212/255, alpha: brightness))
            context.setFillColor(CGColor(red: 154/255, green: 255/255, blue: 200/255, alpha: brightness))
            context.translateBy(x: CGFloat(x), y: CGFloat(y))
            context.rotate(by: CGFloat(theta))
            context.addLines(between: [
                CGPoint(x: -5, y: 0),
                CGPoint(x: 5, y: 0),
                CGPoint(x: 0, y: 20),
                CGPoint(x: -5, y: 0)
            ])
            context.drawPath(using: .fillStroke)
            context.restoreGState()
        }
    }

    func animateOneFrame() {
        flockSim.step()
    }
}
