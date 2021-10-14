import ScreenSaver
import Flockingbird
import Metal
import MetalKit
import simd
import GLKit

struct Vertex {
    let position: simd_float4
    let color: simd_float4
    let pointsize: simd_float1
}

class DancingBoidsView : ScreenSaverView {
    private let screenSaverDelegates: [ScreenSaverViewDelegate.Type] = [
        LuminecentBoidsScreenSaverViewDeletgate.self
    ]
    private var currentlyDisplayingScreenSaverDelegate: ScreenSaverViewDelegate!
    private var frameCount = 0
    private var switchDelegateAfterNumberOfFrames = 30 * 30
    private let flockSim: FlockSimulation
    private var drawingLayer: CAMetalLayer!
    private var device: MTLDevice!
    private var fragmentFunction: MTLFunction!
    private var vertexFunction: MTLFunction!
    private var pipelineState: MTLRenderPipelineState!

    override init(frame: NSRect, isPreview: Bool) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: 1,
                         maxX: Int32(frame.size.width), maxY: Int32(frame.size.height)),
            simulationParameters: FlockSimulationParameters(
                fromDict:
                    ["maxX": Int(frame.size.width),
                     "maxY": Int(frame.size.height),
                    ]))

        super.init(frame: frame, isPreview: isPreview)!
    }

    override func startAnimation() {
        super.startAnimation()
        self.device = MTLCreateSystemDefaultDevice()!
        let layer = CAMetalLayer()
        layer.device = device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true
        layer.frame = self.frame

        let defaultLibrary = device.makeDefaultLibrary()!
        self.fragmentFunction = defaultLibrary.makeFunction(name: "fragment_main")
        self.vertexFunction = defaultLibrary.makeFunction(name: "vertex_main")
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = self.vertexFunction
        pipelineStateDescriptor.fragmentFunction = self.fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = layer.pixelFormat

        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        self.drawingLayer = layer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    override func draw(_ rect: NSRect) {
        if self.layer!.sublayers == nil {
            self.layer?.addSublayer(self.drawingLayer)
        }
        let boids = flockSim.currentFlock.boids
        let positions = boids.map { boid -> (x: Float, y: Float) in
            let x = 2 * (boid.position.x / Float(frame.size.width)) - 1
            let y = 2 * (boid.position.y / Float(frame.size.height)) - 1
            return (x: x, y: y)
        }
        let vertexData: [Float] = positions.flatMap { (position) -> [Float] in
            let x: Float = position.x
            let y: Float = position.y
            let triangleVertices = [(x,y - 0.1), (x-0.025,y), (x+0.025, y)]
            return triangleVertices.flatMap {
                [$0.0, $0.1, 0, 1]
            }
        }

        let dataSize = vertexData.count * MemoryLayout<Float>.stride
        let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        let rotationMatrix = matrix_from_rotation(radians: 0, x: positions.first!.x, y: positions.first!.y)

        let transformationBuffer = device.makeBuffer(length: MemoryLayout.size(ofValue: rotationMatrix), options: [])

        let commandQueue = device.makeCommandQueue()!
        let drawable = drawingLayer.nextDrawable()!
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 0,
            blue: 0,
            alpha: 1.0)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(transformationBuffer, offset: 0, index: 1)
        renderEncoder
            .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count * 3)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    override func animateOneFrame() {
        // According to https://stackoverflow.com/a/40697758/3885491 this
        // Switches to a GPU, Metal-based renderer, greatly improving performance.
        super.animateOneFrame()
        frameCount = (frameCount + 1) % switchDelegateAfterNumberOfFrames
        flockSim.step()
        setNeedsDisplay(bounds)
    }

    private func drawFadeOverlay() {
        let bPath:NSBezierPath = NSBezierPath(rect: frame)
        let frameCountWhenFullyFadedin: Float = Float(switchDelegateAfterNumberOfFrames) / 10.0
        let fadeInOverlayAlpha = 1 - CGFloat(min(
                                                Float(self.frameCount),
                                                frameCountWhenFullyFadedin)/frameCountWhenFullyFadedin)
        NSColor.init(
            deviceRed: 0,
            green: 0,
            blue: 0,
            alpha: fadeInOverlayAlpha
        ).set()
        bPath.fill()
    }
}
    

func  matrix_from_rotation(radians: Float, x: Float, y: Float, z: Float = 1) -> matrix_float4x4
{
    let v = vector_float3(x: x, y: y, z: z)
    let cos = cosf(radians)
    let cosp = 1.0 - cos
    let sin = sinf(radians)

    return matrix_float4x4(
        .init(cos + cosp * v.x * v.x,
              cosp * v.x * v.y + v.z * sin,
              cosp * v.x * v.z - v.y * sin,
              0),
        .init(cosp * v.x * v.y - v.z * sin,
              cosp * v.x * v.y + v.z * sin,
              cosp * v.x * v.z - v.y * sin,
              0),
        .init(cosp * v.x * v.z + v.y * sin,
              cosp * v.y * v.z - v.x * sin,
              cos + cosp * v.z * v.z,
              0),
            .init(0, 0, 0, 1)
    )
}
