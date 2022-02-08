import ScreenSaver
import Flockingbird
import MetalKit
import GLKit

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
}
