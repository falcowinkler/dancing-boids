
import ScreenSaver
import Metal
import IOKit.ps

func selectMetalDevice() -> MTLDevice
{
    var device: MTLDevice?
    var message: String

    if IOPSGetTimeRemainingEstimate() == kIOPSTimeRemainingUnlimited {
        device = MTLCreateSystemDefaultDevice()
        message = "Connected to power, using default video device"
    } else {
        for d in MTLCopyAllDevices() {
            device = d
            if d.isLowPower && !d.isHeadless {
                message = "On battery, using low power video device"
                break
            }
        }
        message = "On battery, using video device"
    }
    if let name = device?.name {
        NSLog("TWGlyphSaver: \(message) \(name)")
    } else {
        NSLog("TWGlyphSaver: No or unknown video device. Screen saver might not work.")
    }
    return device!
    }
