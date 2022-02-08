import ScreenSaver
import Flockingbird
import MetalKit
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

class DancingBoidsView : ScreenSaverView, MTKViewDelegate {
    private var frameCount = 0
    private var switchDelegateAfterNumberOfFrames = 30 * 30
    private var mtkView: MTKView!
    private var drawingDelegates: [DrawingDelegate.Type] = [ColorfulBoidsDrawingDelegate.self]
    private var currentDelegate: DrawingDelegate!

    private func swapDelegate() {
        self.currentDelegate = drawingDelegates.randomElement()!.init(frame: frame, isPreview: isPreview, mtkView: self.mtkView)
    }

    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)!
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        self.mtkView = MTKView(frame: frame, device: device)
        self.mtkView.colorPixelFormat = .bgra8Unorm
        self.mtkView.framebufferOnly = true
        self.addSubview(mtkView)
        mtkView.delegate = self
        self.swapDelegate()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.currentDelegate.drawableSizeWillChange(view: view, size: size)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    func draw(in view: MTKView) {
        self.currentDelegate.draw(view: view)
        self.drawFadeOverlay()
    }

    override func animateOneFrame() {
        self.currentDelegate.animateOneFrame()
        super.animateOneFrame()
        frameCount = (frameCount + 1) % switchDelegateAfterNumberOfFrames
        if frameCount == 0 {
            self.swapDelegate()
        }
        setNeedsDisplay(bounds)
    }

    private func drawFadeOverlay() {
    }
}
