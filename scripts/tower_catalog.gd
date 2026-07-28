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

static func upgrades(kind: int) -> Array:
	var paths: Array = [
		[{"name":"Punta de acero", "description":"Dardos más pesados: +1 daño.", "cost":180, "damage":1}, {"name":"Cadencia táctica", "description":"Dispara más rápido y gana alcance.", "cost":300, "reload_mult":0.72, "range":15}, {"name":"Ráfaga solar", "description":"Una descarga luminosa: +2 daño.", "cost":600, "damage":2}],
		[{"name":"Filo gemelo", "description":"Bumerán reforzado: +1 daño.", "cost":240, "damage":1}, {"name":"Órbita amplia", "description":"Trayectoria más larga y +25 alcance.", "cost":420, "range":25, "projectile_range":70}, {"name":"Retorno ciclón", "description":"Regresa con fuerza: +2 daño y más cadencia.", "cost":760, "damage":2, "reload_mult":0.80}],
		[{"name":"Carga concentrada", "description":"La bomba hace +1 daño y explota más lejos.", "cost":250, "damage":1, "explosion":16}, {"name":"Mecha rápida", "description":"Recarga más deprisa.", "cost":430, "reload_mult":0.72}, {"name":"Granada solar", "description":"Gran explosión: +2 daño y radio extra.", "cost":780, "damage":2, "explosion":28}],
		[{"name":"Chispa arcana", "description":"El rayo inflige +1 daño.", "cost":280, "damage":1}, {"name":"Cadenas vivas", "description":"El rayo rebota en dos globos más.", "cost":460, "chain":2}, {"name":"Tormenta ancestral", "description":"+2 daño y recarga más rápida.", "cost":820, "damage":2, "reload_mult":0.78}],
		[{"name":"Flecha espectral", "description":"Flechas más potentes: +1 daño.", "cost":300, "damage":1}, {"name":"Vista lunar", "description":"+55 alcance para sus flechas perforantes.", "cost":500, "range":55, "projectile_range":90}, {"name":"Lluvia mística", "description":"+2 daño y mayor cadencia.", "cost":880, "damage":2, "reload_mult":0.78}],
		[{"name":"Cosecha fértil", "description":"Cada banana vale $10 más.", "cost":300, "banana_value":10}, {"name":"Cestas veloces", "description":"Produce bananas cada 2 s menos.", "cost":480, "banana_interval":-2}, {"name":"Tesoro tropical", "description":"Las bananas ganan $25 de valor.", "cost":800, "banana_value":25}],
		[{"name":"Bálsamo coral", "description":"Cada cura recupera 4 vidas más.", "cost":260, "heal":4}, {"name":"Pulso vital", "description":"Cura con mayor frecuencia.", "cost":440, "reload_mult":0.72}, {"name":"Rescate marino", "description":"Una ola de vida: +8 curación.", "cost":780, "heal":8}],
		[{"name":"Acero salado", "description":"El sable inflige +1 daño.", "cost":360, "damage":1}, {"name":"Corte amplio", "description":"El barrido gana 30 de alcance.", "cost":580, "range":30}, {"name":"Furia corsaria", "description":"+2 daño y ataques más rápidos.", "cost":950, "damage":2, "reload_mult":0.78}],
		[{"name":"Púas dentadas", "description":"Cada púa hace +1 daño.", "cost":280, "damage":1}, {"name":"Sembradora", "description":"Suelta dos púas extra por tanda.", "cost":460, "spike_count":2}, {"name":"Alfombra de acero", "description":"Coloca púas mucho más rápido.", "cost":800, "reload_mult":0.72}]
	]
	return paths[kind]
