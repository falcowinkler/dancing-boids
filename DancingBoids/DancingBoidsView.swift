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
    lazy var sheetController: ConfigureSheetController = ConfigureSheetController()
    private var overlayWindow: NSBox!

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
        mtkView.alphaValue = 0
        self.addSubview(mtkView)
        setupUpdateAvailableView()
        mtkView.delegate = self
        self.swapDelegate()
    }


    private func setupUpdateAvailableView() {
        let updateAvailableView = UpdateAvailableView(
            frame: .init(origin: .zero, size: .init(width: mtkView.frame.width, height: 44))
        )

        self.addSubview(updateAvailableView, positioned: .above, relativeTo: mtkView)

        updateAvailableView.translatesAutoresizingMaskIntoConstraints = false
        updateAvailableView.bottomAnchor.constraint(equalTo: mtkView.bottomAnchor).isActive = true
        updateAvailableView.leftAnchor.constraint(equalTo: mtkView.leftAnchor).isActive = true
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
        let animationSeconds = 5
        let animationFrames = 30 * animationSeconds
        if frameCount < animationFrames {
            mtkView.alphaValue = CGFloat(frameCount) / CGFloat(animationFrames)
        }
        if switchDelegateAfterNumberOfFrames - frameCount < animationFrames {
            mtkView.alphaValue = CGFloat(switchDelegateAfterNumberOfFrames - frameCount) / CGFloat(animationFrames)
        }
        setNeedsDisplay(bounds)
    }

    override var configureSheet: NSWindow? {
        sheetController.window
    }

    override var hasConfigureSheet: Bool {
        true
    }
}
