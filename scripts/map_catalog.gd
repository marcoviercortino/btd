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
		PackedVector2Array([Vector2(250, 170), Vector2(470, 170), Vector2(530, 310), Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)]),
		PackedVector2Array([Vector2(210, 130), Vector2(420, 250), Vector2(700, 180), Vector2(850, 390), Vector2(1080, 340), Vector2(1190, 560), Vector2(1280, 630)]),
		PackedVector2Array([Vector2(180, 520), Vector2(370, 390), Vector2(540, 500), Vector2(720, 330), Vector2(900, 450), Vector2(1110, 260), Vector2(1280, 310)]),
		PackedVector2Array([Vector2(190, 170), Vector2(370, 310), Vector2(560, 210), Vector2(720, 390), Vector2(890, 280), Vector2(1050, 500), Vector2(1280, 430)])
	]
	return paths[clampi(index, 0, paths.size() - 1)]
