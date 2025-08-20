import Foundation
import Cocoa

// MARK: - Modules Data
let MODULES: [Module] = [
    // Speed Modules - Level 1
    Module(id: "speed-1-normal", name: "Speed Module", type: .speed, level: 1, quality: .normal,
           speedBonus: 0.2, productivityBonus: 0, efficiencyBonus: -0.5, iconAsset: "speed_module"),
    Module(id: "speed-1-uncommon", name: "Speed Module", type: .speed, level: 1, quality: .uncommon,
           speedBonus: 0.26, productivityBonus: 0, efficiencyBonus: -0.65, iconAsset: "speed_module"),
    Module(id: "speed-1-rare", name: "Speed Module", type: .speed, level: 1, quality: .rare,
           speedBonus: 0.32, productivityBonus: 0, efficiencyBonus: -0.8, iconAsset: "speed_module"),
    Module(id: "speed-1-epic", name: "Speed Module", type: .speed, level: 1, quality: .epic,
           speedBonus: 0.38, productivityBonus: 0, efficiencyBonus: -0.95, iconAsset: "speed_module"),
    Module(id: "speed-1-legendary", name: "Speed Module", type: .speed, level: 1, quality: .legendary,
           speedBonus: 0.5, productivityBonus: 0, efficiencyBonus: -1.25, iconAsset: "speed_module"),
    
    // Speed Modules - Level 2
    Module(id: "speed-2-normal", name: "Speed Module 2", type: .speed, level: 2, quality: .normal,
           speedBonus: 0.3, productivityBonus: 0, efficiencyBonus: -0.6, iconAsset: "speed_module_2"),
    Module(id: "speed-2-uncommon", name: "Speed Module 2", type: .speed, level: 2, quality: .uncommon,
           speedBonus: 0.39, productivityBonus: 0, efficiencyBonus: -0.78, iconAsset: "speed_module_2"),
    Module(id: "speed-2-rare", name: "Speed Module 2", type: .speed, level: 2, quality: .rare,
           speedBonus: 0.48, productivityBonus: 0, efficiencyBonus: -0.96, iconAsset: "speed_module_2"),
    Module(id: "speed-2-epic", name: "Speed Module 2", type: .speed, level: 2, quality: .epic,
           speedBonus: 0.57, productivityBonus: 0, efficiencyBonus: -1.14, iconAsset: "speed_module_2"),
    Module(id: "speed-2-legendary", name: "Speed Module 2", type: .speed, level: 2, quality: .legendary,
           speedBonus: 0.75, productivityBonus: 0, efficiencyBonus: -1.5, iconAsset: "speed_module_2"),
    
    // Speed Modules - Level 3
    Module(id: "speed-3-normal", name: "Speed Module 3", type: .speed, level: 3, quality: .normal,
           speedBonus: 0.5, productivityBonus: 0, efficiencyBonus: -0.7, iconAsset: "speed_module_3"),
    Module(id: "speed-3-uncommon", name: "Speed Module 3", type: .speed, level: 3, quality: .uncommon,
           speedBonus: 0.65, productivityBonus: 0, efficiencyBonus: -0.91, iconAsset: "speed_module_3"),
    Module(id: "speed-3-rare", name: "Speed Module 3", type: .speed, level: 3, quality: .rare,
           speedBonus: 0.8, productivityBonus: 0, efficiencyBonus: -1.12, iconAsset: "speed_module_3"),
    Module(id: "speed-3-epic", name: "Speed Module 3", type: .speed, level: 3, quality: .epic,
           speedBonus: 0.95, productivityBonus: 0, efficiencyBonus: -1.33, iconAsset: "speed_module_3"),
    Module(id: "speed-3-legendary", name: "Speed Module 3", type: .speed, level: 3, quality: .legendary,
           speedBonus: 1.25, productivityBonus: 0, efficiencyBonus: -1.75, iconAsset: "speed_module_3"),
    
    // Productivity Modules - Level 1
    Module(id: "productivity-1-normal", name: "Productivity Module", type: .productivity, level: 1, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.04, efficiencyBonus: -0.8, iconAsset: "productivity_module"),
    Module(id: "productivity-1-uncommon", name: "Productivity Module", type: .productivity, level: 1, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.052, efficiencyBonus: -1.04, iconAsset: "productivity_module"),
    Module(id: "productivity-1-rare", name: "Productivity Module", type: .productivity, level: 1, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.064, efficiencyBonus: -1.28, iconAsset: "productivity_module"),
    Module(id: "productivity-1-epic", name: "Productivity Module", type: .productivity, level: 1, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.076, efficiencyBonus: -1.52, iconAsset: "productivity_module"),
    Module(id: "productivity-1-legendary", name: "Productivity Module", type: .productivity, level: 1, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.1, efficiencyBonus: -2.0, iconAsset: "productivity_module"),
    
    // Productivity Modules - Level 2
    Module(id: "productivity-2-normal", name: "Productivity Module 2", type: .productivity, level: 2, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.06, efficiencyBonus: -0.8, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-uncommon", name: "Productivity Module 2", type: .productivity, level: 2, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.078, efficiencyBonus: -1.04, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-rare", name: "Productivity Module 2", type: .productivity, level: 2, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.096, efficiencyBonus: -1.28, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-epic", name: "Productivity Module 2", type: .productivity, level: 2, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.114, efficiencyBonus: -1.52, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-legendary", name: "Productivity Module 2", type: .productivity, level: 2, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.15, efficiencyBonus: -2.0, iconAsset: "productivity_module_2"),
    
    // Productivity Modules - Level 3
    Module(id: "productivity-3-normal", name: "Productivity Module 3", type: .productivity, level: 3, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.1, efficiencyBonus: -0.8, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-uncommon", name: "Productivity Module 3", type: .productivity, level: 3, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.13, efficiencyBonus: -1.04, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-rare", name: "Productivity Module 3", type: .productivity, level: 3, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.16, efficiencyBonus: -1.28, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-epic", name: "Productivity Module 3", type: .productivity, level: 3, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.19, efficiencyBonus: -1.52, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-legendary", name: "Productivity Module 3", type: .productivity, level: 3, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.25, efficiencyBonus: -2.0, iconAsset: "productivity_module_3"),
    
    // Efficiency Modules - Level 1
    Module(id: "efficiency-1-normal", name: "Efficiency Module", type: .efficiency, level: 1, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.3, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-uncommon", name: "Efficiency Module", type: .efficiency, level: 1, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.39, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-rare", name: "Efficiency Module", type: .efficiency, level: 1, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.48, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-epic", name: "Efficiency Module", type: .efficiency, level: 1, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.57, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-legendary", name: "Efficiency Module", type: .efficiency, level: 1, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.75, iconAsset: "efficiency_module"),
    
    // Efficiency Modules - Level 2
    Module(id: "efficiency-2-normal", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.4, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-uncommon", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.52, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-rare", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.64, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-epic", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.76, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-legendary", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 1.0, iconAsset: "efficiency_module_2"),
    
    // Efficiency Modules - Level 3
    Module(id: "efficiency-3-normal", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.5, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-uncommon", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.65, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-rare", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.8, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-epic", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.95, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-legendary", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 1.25, iconAsset: "efficiency_module_3"),
    
    // Quality Modules - Level 1
    Module(id: "quality-1-normal", name: "Quality Module", type: .quality, level: 1, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module"),
    Module(id: "quality-1-uncommon", name: "Quality Module", type: .quality, level: 1, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module"),
    Module(id: "quality-1-rare", name: "Quality Module", type: .quality, level: 1, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module"),
    Module(id: "quality-1-epic", name: "Quality Module", type: .quality, level: 1, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module"),
    Module(id: "quality-1-legendary", name: "Quality Module", type: .quality, level: 1, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module"),
    
    // Quality Modules - Level 2
    Module(id: "quality-2-normal", name: "Quality Module 2", type: .quality, level: 2, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_2"),
    Module(id: "quality-2-uncommon", name: "Quality Module 2", type: .quality, level: 2, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module_2"),
    Module(id: "quality-2-rare", name: "Quality Module 2", type: .quality, level: 2, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module_2"),
    Module(id: "quality-2-epic", name: "Quality Module 2", type: .quality, level: 2, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module_2"),
    Module(id: "quality-2-legendary", name: "Quality Module 2", type: .quality, level: 2, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module_2"),
    
    // Quality Modules - Level 3
    Module(id: "quality-3-normal", name: "Quality Module 3", type: .quality, level: 3, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_3"),
    Module(id: "quality-3-uncommon", name: "Quality Module 3", type: .quality, level: 3, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module_3"),
    Module(id: "quality-3-rare", name: "Quality Module 3", type: .quality, level: 3, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module_3"),
    Module(id: "quality-3-epic", name: "Quality Module 3", type: .quality, level: 3, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module_3"),
    Module(id: "quality-3-legendary", name: "Quality Module 3", type: .quality, level: 3, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module_3"),
]

