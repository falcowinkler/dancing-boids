import ScreenSaver
import Flockingbird
import Metal

class DancingBoidsView : ScreenSaverView {
    private let screenSaverDelegates: [ScreenSaverViewDelegate.Type] = [
        LuminecentBoidsScreenSaverViewDeletgate.self
    ]
    private var currentlyDisplayingScreenSaverDelegate: ScreenSaverViewDelegate!
    private var frameCount = 0
    private var switchDelegateAfterNumberOfFrames = 30 * 30
    let flockSim: FlockSimulation

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    override func draw(_ rect: NSRect) {
        let device = MTLCreateSystemDefaultDevice()!
        let layer = CAMetalLayer()
        layer.device = device
        layer.pixelFormat = .bgra8Unorm
        layer.framebufferOnly = true
        layer.frame = self.frame
        self.layer!.addSublayer(layer)
        let vertexData: [Float] = flockSim.currentFlock.boids.flatMap {
            [$0.position.x / Float(frame.size.width), $0.position.y / Float(frame.size.height), 0]
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        let commandQueue = device.makeCommandQueue()!
        let drawable = layer.nextDrawable()!
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 104.0/255.0,
            blue: 55.0/255.0,
            alpha: 1.0)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder
            .drawPrimitives(type: .point, vertexStart: 0, vertexCount: flockSim.currentFlock.boids.count)
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
    

