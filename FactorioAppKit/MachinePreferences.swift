import Foundation


// MARK: - Machine Preferences
class MachinePreferences: ObservableObject, Codable {
    @Published var defaultTiers: [String: String] = [:]
    
    enum CodingKeys: CodingKey {
        case defaultTiers
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultTiers = try container.decode([String: String].self, forKey: .defaultTiers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultTiers, forKey: .defaultTiers)
    }
    
    func getDefaultTier(for category: String) -> String? {
        return defaultTiers[category]
    }
    
    func setDefaultTier(for category: String, tierID: String) {
        defaultTiers[category] = tierID
        savePreferences()
    }
    
    private func savePreferences() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "MachinePreferences")
        }
    }
    
    static func load() -> MachinePreferences {
        if let data = UserDefaults.standard.data(forKey: "MachinePreferences"),
           let preferences = try? JSONDecoder().decode(MachinePreferences.self, from: data) {
            return preferences
        }
        return MachinePreferences()
    }
}
