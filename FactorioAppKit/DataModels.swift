import Foundation
import Cocoa

// MARK: - Enums
public enum ModuleType: String, Codable, CaseIterable {
    case speed = "Speed"
    case productivity = "Productivity"
    case efficiency = "Efficiency"
    case quality = "Quality"
    
    var color: NSColor {
        switch self {
        case .speed: return .systemBlue
        case .productivity: return .systemRed
        case .efficiency: return .systemGreen
        case .quality: return .systemYellow
        }
    }
}

public enum Quality: String, Codable, CaseIterable {
    case normal = "Normal"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: NSColor {
        switch self {
        case .normal: return .systemGray
        case .uncommon: return .systemGreen
        case .rare: return .systemBlue
        case .epic: return .systemPurple
        case .legendary: return .systemOrange
        }
    }
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .uncommon: return 1.3
        case .rare: return 1.6
        case .epic: return 1.9
        case .legendary: return 2.5
        }
    }
}

public enum IOSide: String, Codable, CaseIterable {
    case input = "input"
    case output = "output"
    
    var opposite: IOSide {
        switch self {
        case .input: return .output
        case .output: return .input
        }
    }
}

// MARK: - Data Models
public struct Module: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let type: ModuleType
    public let level: Int
    public let quality: Quality
    public let speedBonus: Double
    public let productivityBonus: Double
    public let efficiencyBonus: Double
    public let iconAsset: String?
    
    public var displayName: String {
        "\(name) (\(quality.rawValue))"
    }
}

public struct MachineTier: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let category: String
    public let speed: Double
    public let iconAsset: String?
    public let moduleSlots: Int
}

public struct Recipe: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var category: String
    public var time: Double
    public var inputs: [String: Double]
    public var outputs: [String: Double]
    public var primaryOutput: String?
    
    public init(id: String, name: String, category: String, time: Double,
         inputs: [String: Double], outputs: [String: Double],
         primaryOutput: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.time = time
        self.inputs = inputs
        self.outputs = outputs
        self.primaryOutput = primaryOutput
    }
    
    public var mainOutput: String {
        primaryOutput ?? outputs.keys.first ?? name
    }
}

public struct Node: Identifiable, Codable, Hashable {
    public var id = UUID()
    public var recipeID: String
    public var x: CGFloat
    public var y: CGFloat
    public var targetPerMin: Double?
    public var speedMultiplier: Double
    public var selectedMachineTierID: String?
    public var modules: [Module?] = []
    
    public init(recipeID: String, x: CGFloat, y: CGFloat,
         targetPerMin: Double? = nil, speedMultiplier: Double? = nil) {
        self.recipeID = recipeID
        self.x = x
        self.y = y
        self.targetPerMin = targetPerMin
        
        if let recipe = RECIPES.first(where: { $0.id == recipeID }),
           recipe.category == "cryogenic" {
            self.speedMultiplier = speedMultiplier ?? 2.0
        } else {
            self.speedMultiplier = speedMultiplier ?? 1.0
        }
    }
    
    public var totalSpeedBonus: Double {
        modules.compactMap { $0?.speedBonus }.reduce(0, +)
    }
    
    public var totalProductivityBonus: Double {
        modules.compactMap { $0?.productivityBonus }.reduce(0, +)
    }
    
    public var totalEfficiencyBonus: Double {
        modules.compactMap { $0?.efficiencyBonus }.reduce(0, +)
    }
}

public struct Edge: Identifiable, Codable, Hashable {
    public var id = UUID()
    public var fromNode: UUID
    public var toNode: UUID
    public var item: String
    public var quality: Quality = .normal
}

public struct PortKey: Hashable {
    public let nodeID: UUID
    public let side: IOSide
    public let item: String
    public let quality: Quality
}

public struct PickerContext {
    public let fromPort: PortContext
    public let dropPoint: CGPoint
    
    public struct PortContext {
        public let nodeID: UUID
        public let side: IOSide
        public let item: String
        public let quality: Quality
    }
}

public struct DragContext {
    public let nodeID: UUID
    public let portSide: IOSide
    public let item: String
    public let quality: Quality
    public let startPoint: CGPoint
    public let currentPoint: CGPoint
}
