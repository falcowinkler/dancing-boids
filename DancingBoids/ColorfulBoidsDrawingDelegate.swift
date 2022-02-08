import Metal
import MetalKit
import Flockingbird

struct Vertex {
    let position: simd_float4
    let color: simd_float4
}

struct Transformation {
    let rotation: simd_float4x4
    let translation: simd_float4x4
}

struct Uniforms {
    let projectionMatrix: simd_float4x4
}


struct ColorfulBoidsDrawingDelegate: DrawingDelegate {
    private let flockSim: FlockSimulation
    private var fragmentFunction: MTLFunction!
    private var vertexFunction: MTLFunction!
    private var pipelineState: MTLRenderPipelineState!
    private let colors: [simd_float4]
    private let frame: NSRect
    
    init(frame: NSRect, isPreview: Bool, mtkView: MTKView) {
        let size = 100
        self.frame = frame

        func rand() -> Float {
            Float.random(in: 0.1...1)
        }
        flockSim = FlockSimulation(
            flock: Flock(numberOfBoids: Int32(size),
                         maxX: Int32(frame.size.width), maxY: Int32(frame.size.height)),
            simulationParameters: FlockSimulationParameters(
                fromDict:
                    ["maxX": Int(frame.size.width),
                     "maxY": Int(frame.size.height),
                    ]))
        colors = (0...size).map { _ in simd_float4(rand(), rand(), rand(), 1) }

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        let bundle = Bundle(for: DancingBoidsView.self)
        let defaultLibrary = (
            try? device.makeDefaultLibrary(bundle: bundle)) ??
        device.makeDefaultLibrary()!

        self.fragmentFunction = defaultLibrary.makeFunction(name: "fragment_main")
        self.vertexFunction = defaultLibrary.makeFunction(name: "vertex_main")
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = self.vertexFunction
        pipelineStateDescriptor.fragmentFunction = self.fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }

    func drawableSizeWillChange(view: MTKView, size: CGSize) {
        // TODO: change aspect ratio here
    }

    func draw(view: MTKView) {
        let boids = flockSim.currentFlock.boids
        let positions = boids.map { normaliseCoord(frame: self.frame, boid: $0) }
        let device = view.device!

        let vertexData: [Vertex] = positions.enumerated().flatMap { (index, position) -> [Vertex] in
            let x: Float = 0
            let y: Float = 0
            let triangleVertices = [(x,y + 0.05), (x-0.0125,y), (x+0.0125, y)]
            return triangleVertices.map { vertex in
                Vertex(
                    position: .init(vertex.0, vertex.1, 0, 1),
                    color: colors[index]
                )
            }
        }


        let transformations = boids.flatMap { boid -> [Transformation] in
            let pos = normaliseCoord(frame: self.frame, boid: boid)
            let x = pos.x
            let y = pos.y
            let theta = atan2(boid.velocity.y, boid.velocity.x) - Float(Double.pi) / 2
            return [
                Transformation (
                    rotation: rotationMatrix(theta: theta),
                    translation: translationMatrix(dx: x, dy: y)
                ),
                Transformation (
                    rotation: rotationMatrix(theta: theta),
                    translation: translationMatrix(dx: x, dy: y)
                ),
                Transformation (
                    rotation: rotationMatrix(theta: theta),
                    translation: translationMatrix(dx: x, dy: y)
                )
            ]
        }

        let dataSize = vertexData.count * MemoryLayout<Vertex>.stride
        let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        let transformationBuffer = device.makeBuffer(bytes: transformations, length: transformations.count * MemoryLayout<Transformation>.stride, options: [])

        let projectionMatrix = buildProjectionMatrix(
            width: Float(self.frame.width),
            height: Float(self.frame.height)
        )

        var union = Uniforms(projectionMatrix: projectionMatrix)
        let unionsBuffer = device.makeBuffer(bytes: &union, length: MemoryLayout<Uniforms>.stride, options: [])

        let commandQueue = device.makeCommandQueue()!
        let drawable = view.currentDrawable!
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
        renderEncoder.setVertexBuffer(unionsBuffer, offset: 0, index: 2)
        renderEncoder
            .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func animateOneFrame() {
        flockSim.step()
    }
}
