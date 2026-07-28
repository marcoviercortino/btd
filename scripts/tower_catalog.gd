class_name TowerCatalog
extends RefCounted

const COSTS := [120, 330, 400, 450, 600, 650]
const NAMES := ["Dardo", "Bumerán", "Bombardero", "Mago", "Arquero místico", "Granja de bananas"]
const COLORS := [Color("6cc4ed"), Color("ffcc66"), Color("ef8256"), Color("7aa9ff"), Color("9a7ee8"), Color("ffe164")]

static func config(kind: int) -> Dictionary:
	var configs := [
		{"range": 135.0, "damage": 1, "reload": 0.85, "projectile_speed": 600.0, "projectile_range": 260.0},
		{"range": 180.0, "damage": 2, "reload": 1.35, "projectile_speed": 520.0, "projectile_range": 270.0},
		{"range": 155.0, "damage": 1, "reload": 2.0, "projectile_speed": 360.0, "projectile_range": 260.0},
		{"range": 120.0, "damage": 1, "reload": 2.15, "projectile_speed": 0.0, "projectile_range": 0.0},
		{"range": 240.0, "damage": 1, "reload": 1.1, "projectile_speed": 940.0, "projectile_range": 520.0},
		{"range": 0.0, "damage": 0, "reload": 0.0, "projectile_speed": 0.0, "projectile_range": 0.0}
	]
	return configs[kind]
