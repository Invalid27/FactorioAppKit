import Cocoa

// MARK: - Icon Assets (Categories + Items + Helpers)
// Drop PNGs/SVGs into Assets.xcassets using these names.
// If an item isn't listed in ITEM_ASSETS, we auto-generate a slug so you still get an icon
// as long as your asset file uses the same slug (lowercased, spaces/symbols -> underscores).

@inline(__always)
public func slug(_ s: String) -> String {
    let lowered = s.lowercased()
    let replaced = lowered.replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
    return replaced.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
}

// MARK: Icon Assets
public let ICON_ASSETS: [String: String] = [
    // Production categories
    "assembling": "assembling_machine_3",
    "smelting": "electric_furnace",
    "foundry": "foundry",
    "chemistry": "chemical_plant",
    "pumping": "offshore_pump",
    "mining": "electric_mining_drill",
    "crushing": "crusher",
    "recycling": "recycler",
    "bio": "biolab",
    "cryogenic": "cryogenic_plant",
    "electromagnetic": "electromagnetic_plant",

    // Logistics / rail / lab
    "rail": "train_stop",
    "lab": "lab",

    // Utilities (if you use these as categories anywhere)
    "power": "steam_turbine",
    "energy": "accumulator",

    // --- Plates, ores, bars, fluids ---
    "Iron Plate": "iron_plate",
    "Copper Plate": "copper_plate",
    "Steel Plate": "steel_plate",
    "Tungsten Plate": "tungsten_plate",
    "Lithium Plate": "lithium_plate",
    "Holmium Plate": "holmium_plate",
    "Iron Ore": "iron_ore",
    "Copper Ore": "copper_ore",
    "Tungsten Ore": "tungsten_ore",
    "Holmium Ore": "holmium_ore",
    "Uranium Ore": "uranium_ore",
    "Stone": "stone",
    "Stone Brick": "stone_brick",
    "Coal": "coal",
    "Plastic Bar": "plastic_bar",
    "Tungsten Carbide": "tungsten_carbide",
    "Uranium-235": "uranium_235",
    "Uranium-238": "uranium_238",
    "Lithium": "lithium",

    // --- Fluids ---
    "Water": "water",
    "Steam": "steam",
    "Heavy Oil": "heavy_oil",
    "Light Oil": "light_oil",
    "Petroleum Gas": "petroleum_gas",
    "Lubricant": "lubricant",
    "Sulfuric Acid": "sulfuric_acid",
    "Sulfur": "sulfur",
    "Ammonia": "ammonia",
    "Ammoniacal Solution": "ammoniacal_solution",
    "Fluorine": "fluorine",
    "Lithium Brine": "lithium_brine",
    "Holmium Solution": "holmium_solution",
    "Electrolyte": "electrolyte",
    "Fluoroketone Cold": "fluoroketone_cold",
    "Fluoroketone Hot": "fluoroketone_hot",
    "Molten Iron": "molten_iron",
    "Molten Copper": "molten_copper",
    "Molten Iron from Lava": "molten_iron_from_lava",
    "Molten Copper from Lava": "molten_copper_from_lava",
    "Lava": "lava",
    "Ice": "ice",
    "Crude Oil": "crude_oil",

    // --- Barrels ---
    "Barrel": "barrel",
    "Empty Barrel": "empty_barrel",
    "Water Barrel": "water_barrel",
    "Crude Oil Barrel": "crude_oil_barrel",
    "Heavy Oil Barrel": "heavy_oil_barrel",
    "Light Oil Barrel": "light_oil_barrel",
    "Petroleum Gas Barrel": "petroleum_gas_barrel",
    "Lubricant Barrel": "lubricant_barrel",
    "Sulfuric Acid Barrel": "sulfuric_acid_barrel",

    // --- Components ---
    "Iron Stick": "iron_stick",
    "Iron Gear Wheel": "iron_gear_wheel",
    "Copper Cable": "copper_cable",
    "Pipe": "pipe",
    "Pipe to Ground": "pipe_to_ground",
    "Engine Unit": "engine_unit",
    "Electric Engine Unit": "electric_engine_unit",
    "Flying Robot Frame": "flying_robot_frame",
    "Advanced Circuit": "advanced_circuit",
    "Electronic Circuit": "electronic_circuit",
    "Processing Unit": "processing_unit",
    "Quantum Processor": "quantum_processor",
    "Low Density Structure": "low_density_structure",
    "Accumulator": "accumulator",
    "Battery": "battery",
    "Supercapacitor": "supercapacitor",
    "Superconductor": "superconductor",
    "Carbon": "carbon",
    "Carbon Fiber": "carbon_fiber",
    "Calcite": "calcite",
    "Explosives": "explosives",
    "Solid Fuel": "solid_fuel",
    "Rocket Control Unit": "rocket_control_unit",

    // --- Modules ---
    "Speed Module": "speed_module",
    "Speed Module 2": "speed_module_2",
    "Speed Module 3": "speed_module_3",
    "Productivity Module": "productivity_module",
    "Productivity Module 2": "productivity_module_2",
    "Productivity Module 3": "productivity_module_3",
    "Efficiency Module": "efficiency_module",
    "Efficiency Module 2": "efficiency_module_2",
    "Efficiency Module 3": "efficiency_module_3",
    "Quality Module": "quality_module",
    "Quality Module 2": "quality_module_2",
    "Quality Module 3": "quality_module_3",

    // --- Machines / buildings ---
    "Assembling Machine 1": "assembling_machine_1",
    "Assembling Machine 2": "assembling_machine_2",
    "Assembling Machine 3": "assembling_machine_3",
    "Stone Furnace": "stone_furnace",
    "Steel Furnace": "steel_furnace",
    "Electric Furnace": "electric_furnace",
    "Chemical Plant": "chemical_plant",
    "Oil Refinery": "oil_refinery",
    "Electromagnetic Plant": "electromagnetic_plant",
    "Cryogenic Plant": "cryogenic_plant",
    "Crusher": "crusher",
    "Foundry": "foundry",
    "Lab": "lab",
    "Biolab": "biolab",
    "Biochamber": "biochamber",
    "Offshore Pump": "offshore_pump",
    "Pumpjack": "pumpjack",
    "Pump": "pump",
    "Electric Mining Drill": "electric_mining_drill",
    "Burner Mining Drill": "burner_mining_drill",
    "Big Mining Drill": "big_mining_drill",
    "Lightning Collector": "lightning_collector",
    "Lightning Rod": "lightning_rod",
    "Asteroid Collector": "asteroid_collector",
    "Recycler": "recycler",
    "Heating Tower": "heating_tower",
    "Centrifuge": "centrifuge",
    "Agricultural Tower": "agricultural_tower",
    "Beacon": "beacon",
    "Radar": "radar",
    "Storage Tank": "storage_tank",

    // --- Nuclear ---
    "Nuclear Reactor": "nuclear_reactor",
    "Nuclear Fuel": "nuclear_fuel",
    "Uranium Fuel Cell": "uranium_fuel_cell",
    "Used Up Uranium Fuel Cell": "used_up_uranium_fuel_cell",
    "Fusion Reactor": "fusion_reactor",
    "Fusion Generator": "fusion_generator",
    "Fusion Power Cell": "fusion_power_cell",

    // --- Logistics / chests / belts ---
    "Active Provider Chest": "active_provider_chest",
    "Passive Provider Chest": "passive_provider_chest",
    "Buffer Chest": "buffer_chest",
    "Requester Chest": "requester_chest",
    "Storage Chest": "storage_chest",
    "Steel Chest": "steel_chest",
    "Iron Chest": "iron_chest",
    "Wooden Chest": "wooden_chest",

    "Transport Belt": "transport_belt",
    "Underground Belt": "underground_belt",
    "Splitter": "splitter",
    "Fast Transport Belt": "fast_transport_belt",
    "Fast Underground Belt": "fast_underground_belt",
    "Fast Splitter": "fast_splitter",
    "Express Transport Belt": "express_transport_belt",
    "Express Underground Belt": "express_underground_belt",
    "Express Splitter": "express_splitter",
    "Turbo Transport Belt": "turbo_transport_belt",
    "Turbo Underground Belt": "turbo_underground_belt",
    "Turbo Splitter": "turbo_splitter",

    // --- Inserters ---
    "Inserter": "inserter",
    "Long-handed Inserter": "long-handed_inserter",
    "Fast Inserter": "fast_inserter",
    "Bulk Inserter": "bulk_inserter",
    "Stack Inserter": "stack_inserter",

    // --- Robots ---
    "Construction Robot": "construction_robot",
    "Logistic Robot": "logistic_robot",
    "Roboport": "roboport",

    // --- Power ---
    "Steam Engine": "steam_engine",
    "Steam Turbine": "steam_turbine",
    "Heat Exchanger": "heat_exchanger",
    "Solar Panel": "solar_panel",

    // --- Rail ---
    "Train Stop": "train_stop",
    "Rail": "rail",
    "Straight Rail": "straight_rail",
    "Rail Signal": "rail_signal",
    "Rail Chain Signal": "rail_chain_signal",
    "Rail Ramp": "rail_ramp",
    "Rail Support": "rail_support",
    "Locomotive": "locomotive",
    "Cargo Wagon": "cargo_wagon",
    "Fluid Wagon": "fluid_wagon",

    // --- Science packs ---
    "Automation Science Pack": "automation_science_pack",
    "Logistic Science Pack": "logistic_science_pack",
    "Military Science Pack": "military_science_pack",
    "Chemical Science Pack": "chemical_science_pack",
    "Production Science Pack": "production_science_pack",
    "Utility Science Pack": "utility_science_pack",
    "Space Science Pack": "space_science_pack",
    "Agricultural Science Pack": "agricultural_science_pack",
    "Electromagnetic Science Pack": "electromagnetic_science_pack",
    "Metallurgic Science Pack": "metallurgic_science_pack",
    "Cryogenic Science Pack": "cryogenic_science_pack",
    "Promethium Science Pack": "promethium_science_pack",

    // --- Bio chain ---
    "Bioflux": "bioflux",
    "Nutrients": "nutrients",
    "Jelly": "jelly",
    "Jellynut": "jellynut",
    "Jellynut Seed": "jellynut_seed",
    "Yumako": "yumako",
    "Yumako Seed": "yumako_seed",
    "Yumako Mash": "yumako_mash",
    "Pentapod Egg": "pentapod_egg",
    "Raw Fish": "raw_fish",
    "Spoilage": "spoilage",
    "Tree Seed": "tree_seed",
    "Wood": "wood",
    "Artificial Jellynut Soil": "artificial_jellynut_soil",
    "Artificial Yumako Soil": "artificial_yumako_soil",
    "Captive Biter Spawner": "captive_biter_spawner",
    "Iron Bacteria": "iron_bacteria",
    "Copper Bacteria": "copper_bacteria",

    // --- Weapons / ammo / defense ---
    "Grenade": "grenade",
    "Firearm Magazine": "firearm_magazine",
    "Piercing Rounds Magazine": "piercing_rounds_magazine",
    "Uranium Rounds Magazine": "uranium_rounds_magazine",
    "Cannon Shell": "cannon_shell",
    "Explosive Cannon Shell": "explosive_cannon_shell",
    "Uranium Cannon Shell": "uranium_cannon_shell",
    "Explosive Uranium Cannon Shell": "explosive_uranium_cannon_shell",
    "Artillery Shell": "artillery_shell",
    "Rocket": "rocket",
    "Explosive Rocket": "explosive_rocket",
    "Atomic Bomb": "atomic_bomb",
    "Flamethrower Ammo": "flamethrower_ammo",
    "Gun Turret": "gun_turret",
    "Laser Turret": "laser_turret",
    "Flamethrower Turret": "flamethrower_turret",
    "Artillery Turret": "artillery_turret",
    "Tesla Ammo": "tesla_ammo",
    "Tesla Turret": "tesla_turret",
    "Railgun": "railgun",
    "Railgun Ammo": "railgun_ammo",
    "Railgun Turret": "railgun_turret",
    "Rocket Turret": "rocket_turret",
    "Cliff Explosives": "cliff_explosives",

    // --- Armor / equipment ---
    "Mech Armor": "mech_armor",
    "Exoskeleton": "exoskeleton",
    "Energy Shield": "energy_shield",
    "Energy Shield MK2": "energy_shield_MK2",
    "Nightvision": "nightvision",
    "Toolbelt Equipment": "toolbelt_equipment",
    "Portable Solar Panel": "portable_solar_panel",
    "Portable Fusion Reactor": "portable_fusion_reactor",
    "Personal Battery": "personal_battery",
    "Personal Battery MK2": "personal_battery_MK2",
    "Personal Battery MK3": "personal_battery_MK3",
    "Personal Roboport": "personal_roboport",
    "Personal Roboport MK2": "personal_roboport_MK2",

    // --- Space / Asteroids ---
    "Rocket Fuel": "rocket_fuel",
    "Rocket Part": "rocket_part",
    "Rocket Silo": "rocket_silo",
    "Space Platform Foundation": "space_platform_foundation",
    "Space Platform Starter Pack": "space_platform_starter_pack",
    "Space Platform Hub": "space_platform_hub",
    "Satellite": "satellite",
    "Cargo Bay": "cargo_bay",
    "Thruster": "thruster",
    "Thruster Fuel": "thruster_fuel",
    "Thruster Oxidizer": "thruster_oxidizer",
    "Foundation": "foundation",
    "Ice Platform": "ice_platform",
    "Metallic Asteroid Chunk": "metallic_asteroid_chunk",
    "Carbonic Asteroid Chunk": "carbonic_asteroid_chunk",
    "Oxide Asteroid Chunk": "oxide_asteroid_chunk",
    "Promethium Asteroid Chunk": "promethium_asteroid_chunk",

    // --- Concrete ---
    "Concrete": "concrete",
    "Hazard Concrete": "hazard_concrete",
    "Refined Concrete": "refined_concrete",
    "Refined Hazard Concrete": "refined_hazard_concrete",

    // --- Circuit Network ---
    "Arithmetic Combinator": "arithmetic_combinator",
    "Decider Combinator": "decider_combinator",
    "Constant Combinator": "constant_combinator",
    "Power Switch": "power_switch",
    "Programmable Speaker": "programmable_speaker",
    "Display Panel": "display_panel",
    "Green Wire": "green_wire",
    "Red Wire": "red_wire",

    // --- Misc ---
    "Lamp": "small_lamp",
    "Small Lamp": "small_lamp",
    "Wall": "wall",
    "Gate": "gate",
    "Landfill": "landfill",
    "Repair Pack": "repair_pack",
    "Scrap": "scrap",
    "Blueprint": "blueprint",
    "Deconstruction Planner": "deconstruction_planner",
    "Upgrade Planner": "upgrade_planner"
]

/// Return the best image asset name for any item or category.
@inline(__always)
public func iconAssetName(for name: String) -> String {
    if let item = ICON_ASSETS[name] { return item }
    if let cat = ICON_ASSETS[name] { return cat }
    return slug(name) // graceful fallback if not explicitly listed
}
