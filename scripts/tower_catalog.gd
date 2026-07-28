class_name TowerCatalog
extends RefCounted

const COSTS := [120, 330, 400, 450, 600, 650, 520, 900, 700]
const NAMES := ["Dardo", "Bumerán", "Bombardero", "Mago", "Arquero místico", "Granja de bananas", "Médica del Arrecife", "Pirata", "Cortasendas"]
const COLORS := [Color("6cc4ed"), Color("ffcc66"), Color("ef8256"), Color("7aa9ff"), Color("9a7ee8"), Color("ffe164"), Color("62c6a6"), Color("d99055"), Color("9da7ae")]

static func config(kind: int) -> Dictionary:
	var configs := [
		{"range": 135.0, "damage": 1, "damage_type": "physical", "reload": 0.85, "projectile_speed": 600.0, "projectile_range": 260.0, "thermal_vision": false},
		{"range": 180.0, "damage": 2, "damage_type": "physical", "reload": 1.35, "projectile_speed": 520.0, "projectile_range": 270.0, "thermal_vision": true},
		{"range": 155.0, "damage": 1, "damage_type": "magic", "reload": 2.0, "projectile_speed": 360.0, "projectile_range": 260.0, "thermal_vision": false},
		{"range": 120.0, "damage": 1, "damage_type": "magic", "reload": 2.15, "projectile_speed": 0.0, "projectile_range": 0.0, "thermal_vision": false},
		{"range": 240.0, "damage": 1, "damage_type": "magic", "reload": 1.1, "projectile_speed": 940.0, "projectile_range": 520.0, "thermal_vision": true},
		{"range": 0.0, "damage": 0, "damage_type": "none", "reload": 0.0, "projectile_speed": 0.0, "projectile_range": 0.0, "thermal_vision": false},
		{"range": 0.0, "damage": 0, "damage_type": "none", "reload": 6.0, "projectile_speed": 0.0, "projectile_range": 0.0, "thermal_vision": false},
		{"range": 90.0, "damage": 2, "damage_type": "physical", "reload": 1.75, "projectile_speed": 0.0, "projectile_range": 0.0, "thermal_vision": false},
		{"range": 130.0, "damage": 1, "damage_type": "physical", "reload": 7.0, "projectile_speed": 0.0, "projectile_range": 0.0, "thermal_vision": true}
	]
	return configs[kind]
