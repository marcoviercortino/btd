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
		PackedVector2Array([Vector2(40, 610), Vector2(190, 560), Vector2(270, 650), Vector2(380, 540), Vector2(290, 430), Vector2(430, 320), Vector2(560, 400), Vector2(690, 270), Vector2(830, 360), Vector2(930, 250), Vector2(1060, 340), Vector2(1180, 230), Vector2(1280, 310)]),
		PackedVector2Array([Vector2(50, 110), Vector2(170, 190), Vector2(260, 110), Vector2(350, 220), Vector2(430, 350), Vector2(570, 280), Vector2(690, 390), Vector2(810, 300), Vector2(930, 440), Vector2(1030, 350), Vector2(1140, 480), Vector2(1280, 420)]),
		PackedVector2Array([Vector2(60, 580), Vector2(170, 500), Vector2(280, 570), Vector2(360, 430), Vector2(470, 350), Vector2(580, 450), Vector2(690, 330), Vector2(800, 430), Vector2(900, 520), Vector2(1020, 430), Vector2(1130, 530), Vector2(1280, 480)])
	]
	return paths[clampi(index, 0, paths.size() - 1)]
