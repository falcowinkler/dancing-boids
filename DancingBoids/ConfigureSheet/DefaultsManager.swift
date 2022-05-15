
import ScreenSaver
struct DefaultsManager {
    var getNumberOfBoids: () -> Int
    var setNumberOfBoids: (Int) -> ()
}

extension DefaultsManager {
    static var live: Self {
        let identifier = Bundle(for: ConfigureSheetController.self).bundleIdentifier
        let defaults = ScreenSaverDefaults(forModuleWithName: identifier!)!
        let key = "numberOfBoids"
        defaults.register(defaults: [
            key: 150
        ])
        return Self.init(getNumberOfBoids: {
            defaults.integer(forKey: key)
        }, setNumberOfBoids: { newValue in
            defaults.set(newValue, forKey: key)
            defaults.synchronize()
        })
    }
}
