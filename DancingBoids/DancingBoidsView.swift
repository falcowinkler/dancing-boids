import ScreenSaver
import Flockingbird

class DancingBoidsView : ScreenSaverView {
    private let screenSaverDelegates: [ScreenSaverViewDelegate.Type] = [
        FlockingScreenSaverViewDelegate.self,
        LuminecentBoidsScreenSaverViewDeletgate.self
    ]
    private var currentlyDisplayingScreenSaverDelegate: ScreenSaverViewDelegate!
    private var frameCount = 0
    private var switchDelegateAfterNumberOfFrames = 30 * 30

    override init(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)!
        currentlyDisplayingScreenSaverDelegate = initializeRandomScreenSaverDelegate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("no storyboards")
    }

    override func draw(_ rect: NSRect) {
        currentlyDisplayingScreenSaverDelegate.draw(rect)
        drawFadeOverlay()
    }

    override func animateOneFrame() {
        // According to https://stackoverflow.com/a/40697758/3885491 this
        // Switches to a GPU, Metal-based renderer, greatly improving performance.
        self.layer!.drawsAsynchronously = true

        super.animateOneFrame()
        frameCount = (frameCount + 1) % switchDelegateAfterNumberOfFrames
        if frameCount == 0 {
            currentlyDisplayingScreenSaverDelegate = initializeRandomScreenSaverDelegate()
        }
        currentlyDisplayingScreenSaverDelegate.animateOneFrame()
        setNeedsDisplay(bounds)
    }

    private func initializeRandomScreenSaverDelegate() -> ScreenSaverViewDelegate {
        let type = screenSaverDelegates.randomElement()!
        return type.init(frame: frame, isPreview: isPreview)
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
    

