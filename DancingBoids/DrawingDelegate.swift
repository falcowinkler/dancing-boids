import MetalKit
import Foundation
protocol DrawingDelegate {
    init(frame: NSRect, isPreview: Bool, mtkView: MTKView)
    func drawableSizeWillChange(view: MTKView, size: CGSize) -> Void
    func draw(view: MTKView)
    func animateOneFrame()
}
