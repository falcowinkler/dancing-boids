import ScreenSaver
protocol ScreenSaverViewDelegate {
    func draw(_ rect: NSRect)
    func animateOneFrame()
    init(frame: NSRect, isPreview: Bool)
}
