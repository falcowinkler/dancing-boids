import ScreenSaver
import Flockingbird
import Metal
import simd

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

    var vertexBuffer: MTLBuffer!

    override init(frame: NSRect, isPreview: Bool) {
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: 10,
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
//        self.fragmentFunction = defaultLibrary.makeFunction(name: "basic_fragment")
  //      self.vertexFunction = defaultLibrary.makeFunction(name: "basic_vertex")
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
        let vertexData: [Vertex] = flockSim.currentFlock.boids.map {
            Vertex(
                position:
                        .init(
                            x: $0.position.x / Float(frame.size.width),
                            y: $0.position.y / Float(frame.size.height),
                            z: 0,
                            w: 1),
                color: .init(x:1, y:1, z:1, w:1),
                pointsize: 10
            )
        }
        /*let vertexData: [Float] = flockSim.currentFlock.boids.flatMap {
            [$0.position.x / Float(frame.size.width), $0.position.y / Float(frame.size.height), 0]
        }*/
        let dataSize = vertexData.count * MemoryLayout<Vertex>.stride
        // let dataSize = vertexData.count * MemoryLayout<Float>.stride
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])

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
        renderEncoder
            .drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexData.count)
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
    

