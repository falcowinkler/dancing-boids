import Foundation

struct CheckForUpdatesService {
    var getLatestTag: () async -> String?
    var isUpdateAvailable: () async -> Bool
}

extension CheckForUpdatesService {
    static var live: Self {
        func getLatestTag() async -> String? {
            let url = URL(string: "https://api.github.com/repos/netlight/dancing-boids/releases/latest")!
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else {
                return nil
            }
            return json["tag_name"] as? String
        }
        return Self(getLatestTag: {
            await getLatestTag()
        }, isUpdateAvailable: {
            let remoteVersion = await getLatestTag()
            if remoteVersion == nil {
                return false
            }
            let path = Bundle.main.path(forResource: "current_tag", ofType: "txt") ?? Bundle(for: UpdateAvailableView.self).path(forResource: "current_tag", ofType: "txt")!
            let localVersion = try! String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            return localVersion != remoteVersion
        })
    }
}
