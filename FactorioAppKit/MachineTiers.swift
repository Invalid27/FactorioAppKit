import Foundation
import Cocoa

// MARK: - Machine Tiers Data
let MACHINE_TIERS: [String: [MachineTier]] = [
    // Standard crafting (most assembling machine recipes)
    "crafting": [
        MachineTier(id: "assembling-1", name: "Assembling Machine 1", category: "crafting", speed: 0.5, iconAsset: "assembling_machine_1", moduleSlots: 0),
        MachineTier(id: "assembling-2", name: "Assembling Machine 2", category: "crafting", speed: 0.75, iconAsset: "assembling_machine_2", moduleSlots: 2),
        MachineTier(id: "assembling-3", name: "Assembling Machine 3", category: "crafting", speed: 1.25, iconAsset: "assembling_machine_3", moduleSlots: 4)
    ],
    
    // Electronics uses assembling machines too!
    "electronics": [
        MachineTier(id: "assembling-1", name: "Assembling Machine 1", category: "electronics", speed: 0.5, iconAsset: "assembling_machine_1", moduleSlots: 0),
        MachineTier(id: "assembling-2", name: "Assembling Machine 2", category: "electronics", speed: 0.75, iconAsset: "assembling_machine_2", moduleSlots: 2),
        MachineTier(id: "assembling-3", name: "Assembling Machine 3", category: "electronics", speed: 1.25, iconAsset: "assembling_machine_3", moduleSlots: 4)
    ],
    
    // Add these simplified category mappings too
    "pressing": [  // For belts and such
        MachineTier(id: "assembling-1", name: "Assembling Machine 1", category: "pressing", speed: 0.5, iconAsset: "assembling_machine_1", moduleSlots: 0),
        MachineTier(id: "assembling-2", name: "Assembling Machine 2", category: "pressing", speed: 0.75, iconAsset: "assembling_machine_2", moduleSlots: 2),
        MachineTier(id: "assembling-3", name: "Assembling Machine 3", category: "pressing", speed: 1.25, iconAsset: "assembling_machine_3", moduleSlots: 4)
    ],
    
    "smelting": [
        MachineTier(id: "stone-furnace", name: "Stone Furnace", category: "smelting", speed: 1.0, iconAsset: "stone_furnace", moduleSlots: 0),
        MachineTier(id: "steel-furnace", name: "Steel Furnace", category: "smelting", speed: 2.0, iconAsset: "steel_furnace", moduleSlots: 0),
        MachineTier(id: "electric-furnace", name: "Electric Furnace", category: "smelting", speed: 2.0, iconAsset: "electric_furnace", moduleSlots: 2)
    ],
    
    "chemistry": [
        MachineTier(id: "chemical-plant", name: "Chemical Plant", category: "chemistry", speed: 1.0, iconAsset: "chemical_plant", moduleSlots: 3)
    ],
    
    "metallurgy": [
        MachineTier(id: "foundry", name: "Foundry", category: "metallurgy", speed: 4.0, iconAsset: "foundry", moduleSlots: 4)
        // Note: Foundry has 50% built-in productivity
    ],
    
    "cryogenics": [
        MachineTier(id: "cryogenic-plant", name: "Cryogenic Plant", category: "cryogenics", speed: 2.0, iconAsset: "cryogenic_plant", moduleSlots: 8)
    ],
    
    "organic": [
        MachineTier(id: "biochamber", name: "Biochamber", category: "organic", speed: 2.0, iconAsset: "biochamber", moduleSlots: 4)
        // Note: Biochamber has 50% built-in productivity
    ],
    
    "electromagnetics": [
        MachineTier(id: "electromagnetic-plant", name: "Electromagnetic Plant", category: "electromagnetics", speed: 2.0, iconAsset: "electromagnetic_plant", moduleSlots: 5)
        // Note: Electromagnetic plant has 50% built-in productivity
    ],
    
    "crushing": [
        MachineTier(id: "crusher", name: "Crusher", category: "crushing", speed: 1.0, iconAsset: "crusher", moduleSlots: 2)
    ],
    
    "recycling": [
        MachineTier(id: "recycler", name: "Recycler", category: "recycling", speed: 0.5, iconAsset: "recycler", moduleSlots: 4)
    ],
    
    "centrifuging": [
        MachineTier(id: "centrifuge", name: "Centrifuge", category: "centrifuging", speed: 1.0, iconAsset: "centrifuge", moduleSlots: 2)
    ],
    
    "oil-processing": [
        MachineTier(id: "oil-refinery", name: "Oil Refinery", category: "oil-processing", speed: 1.0, iconAsset: "oil_refinery", moduleSlots: 3)
    ],
    
    "mining": [
        MachineTier(id: "burner-mining-drill", name: "Burner Mining Drill", category: "mining", speed: 0.25, iconAsset: "burner_mining_drill", moduleSlots: 0),
        MachineTier(id: "electric-mining-drill", name: "Electric Mining Drill", category: "mining", speed: 0.5, iconAsset: "electric_mining_drill", moduleSlots: 3),
        MachineTier(id: "big-mining-drill", name: "Big Mining Drill", category: "mining", speed: 2.5, iconAsset: "big_mining_drill", moduleSlots: 4)
    ],
    
    "research": [
        MachineTier(id: "lab", name: "Lab", category: "research", speed: 1.0, iconAsset: "lab", moduleSlots: 2),
        MachineTier(id: "biolab", name: "Biolab", category: "research", speed: 2.0, iconAsset: "biolab", moduleSlots: 4)
    ],
    
    "rocket-building": [
        MachineTier(id: "rocket-silo", name: "Rocket Silo", category: "rocket-building", speed: 1.0, iconAsset: "rocket_silo", moduleSlots: 4)
    ],
    
    // These don't have modules but still need entries
    "boiling": [
        MachineTier(id: "boiler", name: "Boiler", category: "boiling", speed: 1.0, iconAsset: "boiler", moduleSlots: 0),
        MachineTier(id: "heat-exchanger", name: "Heat Exchanger", category: "boiling", speed: 1.718213058, iconAsset: "heat_exchanger", moduleSlots: 0)
    ],
    
    "growing": [
        MachineTier(id: "agricultural-tower", name: "Agricultural Tower", category: "growing", speed: 1.0, iconAsset: "agricultural_tower", moduleSlots: 0)
    ],
    
    "offshore-pumping": [
        MachineTier(id: "offshore-pump", name: "Offshore Pump", category: "offshore-pumping", speed: 1.0, iconAsset: "offshore_pump", moduleSlots: 0)
    ],
    
    "asteroid-collection": [
        MachineTier(id: "asteroid-collector", name: "Asteroid Collector", category: "asteroid-collection", speed: 1.0, iconAsset: "asteroid_collector", moduleSlots: 0)
    ],
    
    "biter-egg": [
        MachineTier(id: "captive-biter-spawner", name: "Captive Biter Spawner", category: "biter-egg", speed: 1.0, iconAsset: "captive_biter_spawner", moduleSlots: 0)
    ],
    
    "nuclear-reaction": [
        MachineTier(id: "nuclear-reactor", name: "Nuclear Reactor", category: "nuclear-reaction", speed: 1.0, iconAsset: "nuclear_reactor", moduleSlots: 0)
    ]
]
