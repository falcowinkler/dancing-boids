import ScreenSaver
import Flockingbird
import Metal
import MetalKit
import simd
import GLKit

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

func buildProjectionMatrix(width: Float, height: Float) -> simd_float4x4 {
    let aspect = width / height
    let projectionMatrix = GLKMatrix4MakeOrtho(-aspect, aspect,
                                               -1, 1,
                                               -1, 1)
    var modelViewMatrix = GLKMatrix4Identity
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, aspect, -aspect, 1.0)
    let out = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
    return simd_float4x4(matrix: out)
}

class DancingBoidsView : ScreenSaverView {
    private var frameCount = 0
    private var switchDelegateAfterNumberOfFrames = 30 * 30
    private let flockSim: FlockSimulation
    private var drawingLayer: CAMetalLayer!
    private var device: MTLDevice!
    private var fragmentFunction: MTLFunction!
    private var vertexFunction: MTLFunction!
    private var pipelineState: MTLRenderPipelineState!
    private let colors: [simd_float4]

    override init(frame: NSRect, isPreview: Bool) {
        let size = 100

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

    func normaliseCoord(boid: Boid) -> (x: Float, y: Float)  {
        // TODO: make the library capable of dealing with -1, 1 coordinate space
        let drawableSize = drawingLayer.drawableSize
        let aspect = Float(drawableSize.width / drawableSize.height)
        let x = 2 * (boid.position.x / Float(drawableSize.width)) - 1
        let y = (2 * (boid.position.y / Float(drawableSize.height)) - 1 ) / aspect
        return (x: x, y: y)
    }

    override func draw(_ rect: NSRect) {
        // TODO: when to add the layer? (when is self.layer != nil?)
        if self.layer!.sublayers == nil {
            self.layer?.addSublayer(self.drawingLayer)
        }
        let boids = flockSim.currentFlock.boids
        let positions = boids.map(normaliseCoord)


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
            let pos = normaliseCoord(boid: boid)
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

        let drawableSize = drawingLayer.drawableSize
        let projectionMatrix = buildProjectionMatrix(
            width: Float(drawableSize.width),
            height: Float(drawableSize.height)
        )

        var union = Uniforms(projectionMatrix: projectionMatrix)
        let unionsBuffer = device.makeBuffer(bytes: &union, length: MemoryLayout<Uniforms>.stride, options: [])

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
        renderEncoder.setVertexBuffer(unionsBuffer, offset: 0, index: 2)
        renderEncoder
            .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
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
}


func translationMatrix(dx: Float, dy: Float) -> matrix_float4x4 {
    .init(.init(1, 0, 0, dx),
          .init(0, 1, 0, dy),
          .init(0, 0, 1, 0),
          .init(0, 0, 0, 1))
}

func  rotationMatrix(theta: Float) -> simd_float4x4
{
    return  .init(.init(cos(theta), -sin(theta), 0, 0),
                  .init(sin(theta), cos(theta), 0, 0),
                  .init(0, 0, 1, 0),
                  .init(0, 0, 0, 1))
}

extension simd_float4x4 {
    init(matrix m: GLKMatrix4) {
        self.init(columns: (
            simd_float4(x: m.m00, y: m.m01, z: m.m02, w: m.m03),
            simd_float4(x: m.m10, y: m.m11, z: m.m12, w: m.m13),
            simd_float4(x: m.m20, y: m.m21, z: m.m22, w: m.m23),
            simd_float4(x: m.m30, y: m.m31, z: m.m32, w: m.m33)))
    }
}
