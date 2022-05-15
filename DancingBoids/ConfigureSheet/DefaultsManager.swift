
import ScreenSaver
struct DefaultsManager {
    var getNumberOfBoids: () -> Int
    var setNumberOfBoids: (Int) -> ()
}

extension DefaultsManager {
    static var live: Self {
        let identifier = Bundle(for: ConfigureSheetController.self).bundleIdentifier
        let defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
        return Self.init(getNumberOfBoids: {
            defaults.object(forKey: "numberOfBoids") as? Int ?? 150
        }, setNumberOfBoids: { newValue in
            defaults.set(newValue, forKey: "numberOfBoids")
        })
    }
}
