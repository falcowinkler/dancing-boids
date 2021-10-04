import Flockingbird
import ScreenSaver
import Metal
import simd

struct  MBEVertex {
    let position: vector_float4
    let color: vector_float4
    let pointsize: Float
}


struct MetalDrawingDelegate: ScreenSaverViewDelegate {
    let flockSim: FlockSimulation
    let frame: NSRect
    let isPreview: Bool
    let layer: CAMetalLayer
    var vertexBuffer: MTLBuffer!
    
    init(frame: NSRect, isPreview: Bool, layer: CALayer) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: SSRandomIntBetween(100, 200),
                         maxX: 1, maxY: 1),
            simulationParameters: FlockSimulationParameters(
                fromDict:
                    ["maxX": 1,
                     "maxY": 1]))
        self.frame = frame
        self.isPreview = isPreview
        self.layer = layer as! CAMetalLayer

        self.layer.device = MTLCreateSystemDefaultDevice()
        self.layer.pixelFormat = .bgra8Unorm
    }

    func draw(_ rect: NSRect) {
        let vertexData: [Float] = [
            0.0,  1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0
        ]
    }

    func animateOneFrame() {
    }
}
