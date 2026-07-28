class_name MapCatalog
extends RefCounted

const NAMES := ["Coral Bend", "Paso Volcanico", "Fiordo Helado", "Ruinas Celestes"]
const TEXTURES := [
	preload("res://assets/coral_bend_map.svg"),
	preload("res://assets/maps/volcano_pass.svg"),
	preload("res://assets/maps/frost_fjord.svg"),
	preload("res://assets/maps/sky_ruins.svg")
]

static func path_for(index: int) -> PackedVector2Array:
	var paths := [
		PackedVector2Array([Vector2(257, 170), Vector2(470, 170), Vector2(530, 310), Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)]),
		PackedVector2Array([Vector2(250, 170), Vector2(470, 170), Vector2(530, 310), Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)]),
		PackedVector2Array([Vector2(250, 170), Vector2(470, 170), Vector2(530, 310), Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)]),
		PackedVector2Array([Vector2(250, 170), Vector2(470, 170), Vector2(530, 310), Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)])
	]
	return paths[clampi(index, 0, paths.size() - 1)]
