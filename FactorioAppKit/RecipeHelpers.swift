import Cocoa

// MARK: - Helper Functions
func isRecyclingRecipe(_ recipe: Recipe) -> Bool {
    return recipe.category == "recycling" || recipe.id.contains("recycling")
}

func getSimplifiedCategory(_ recipe: Recipe) -> String {
    switch recipe.category {
    case "crafting", "crafting-with-fluid", "advanced-crafting":
        return "crafting"
    case "smelting":
        return "smelting"
    case "chemistry", "oil-processing":
        return "chemistry"
    case "biochamber", "organic", "agriculture", "nutrients":
        return "organic"
    case "electromagnetics":
        return "electromagnetics"
    case "metallurgy", "casting":
        return "metallurgy"
    case "crushing":
        return "crushing"
    case "recycling":
        return "recycling"
    case "cryogenic", "cryogenics":
        return "cryogenics"
    case "centrifuging":
        return "centrifuging"
    case "rocket-building":
        return "rocket-building"
    default:
        return recipe.category
    }
}



func getSelectedMachineTier(for node: Node) -> MachineTier? {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
          let tiers = MACHINE_TIERS[recipe.category] else {
        return nil
    }
    
    if let selectedID = node.selectedMachineTierID,
       let tier = tiers.first(where: { $0.id == selectedID }) {
        return tier
    }
    
    return tiers.first
}

func createMonogram(for item: String) -> NSImage {
    let size = NSSize(width: 32, height: 32)
    let image = NSImage(size: size)
    
    image.lockFocus()
    
    // Background
    NSColor.systemBlue.withAlphaComponent(0.2).setFill()
    let rect = NSRect(origin: .zero, size: size)
    let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
    path.fill()
    
    // Border
    NSColor.systemBlue.withAlphaComponent(0.5).setStroke()
    path.lineWidth = 1
    path.stroke()
    
    // Text
    let initials = item.split(separator: " ")
        .compactMap { $0.first }
        .prefix(2)
        .map { String($0) }
        .joined()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 14, weight: .bold),
        .foregroundColor: NSColor.labelColor
    ]
    
    let textSize = initials.size(withAttributes: attrs)
    let textRect = NSRect(
        x: (size.width - textSize.width) / 2,
        y: (size.height - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )
    
    initials.draw(in: textRect, withAttributes: attrs)
    
    image.unlockFocus()
    
    return image
}

func formatBonus(_ value: Double) -> String {
    let percentage = value * 100
    if percentage > 0 {
        return "+\(Int(percentage))%"
    } else {
        return "\(Int(percentage))%"
    }
}

func canUseModule(_ module: Module, forRecipe recipe: Recipe) -> Bool {
    // Quality modules can be used on anything
    if module.type == .quality {
        return true
    }
    
    // Productivity modules have restrictions
    if module.type == .productivity {
        // Check if it's an intermediate product
        if INTERMEDIATE_PRODUCTS.contains(recipe.mainOutput) {
            return true
        }
        
        // Check specific categories that allow productivity
        if recipe.category == "smelting" || recipe.category == "chemistry" ||
           recipe.category == "metallurgy" || recipe.category == "organic" {
            // But only for intermediate products
            return INTERMEDIATE_PRODUCTS.contains(recipe.mainOutput)
        }
        
        return false
    }
    
    // Speed and efficiency modules can be used on anything
    return true
}
