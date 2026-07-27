extends Node2D

const WIDTH := 1280.0
const HEIGHT := 720.0
const PLAY_RECT := Rect2(250, 0, 1030, 720)
const TOWER_COSTS := [120, 330]
const TOWER_NAMES := ["Dardo", "Bumerán"]
const TOWER_COLORS := [Color("6cc4ed"), Color("ffcc66")]
const MAP_TEXTURE = preload("res://assets/coral_bend_map.svg")
const DART_RANGER_TEXTURE = preload("res://assets/characters/dart_ranger.svg")
const BOOMERANG_SCOUT_TEXTURE = preload("res://assets/characters/boomerang_scout.svg")
const GUARDIAN_TEXTURE = preload("res://assets/characters/guardian.svg")

var path := PackedVector2Array([
	Vector2(250, 170), Vector2(470, 170), Vector2(530, 310),
	Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)
])
var path_lengths: Array[float] = []
var path_total := 1.0
var balloons: Array[Dictionary] = []
var towers: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var money := 650
var lives := 30
var wave := 0
var selected_tower := 0
var wave_active := false
var spawn_left := 0
var spawn_timer := 0.0
var spawn_delay := 0.58
var wave_banner := 0.0
var game_over := false
var won := false
var rng := RandomNumberGenerator.new()
var mode_selected := false
var multiplayer_mode := false
var online_mode := false
var online_lobby := false
var active_player := 1
var network_peer: ENetMultiplayerPeer
var lobby_ip := "127.0.0.1"
var lobby_port := "7777"
var editing_field := ""
var lobby_status := "Introduce una IP y un puerto para conectarte."
var rival_lives := 30
var rival_money := 650
var rival_wave := 0
var rival_towers: Array[Dictionary] = []
var rival_balloons: Array[Dictionary] = []
var rival_defeated := false
var net_sync_timer := 0.0

func _ready() -> void:
	rng.randomize()
	for i in range(path.size() - 1):
		path_lengths.append(path[i].distance_to(path[i + 1]))
		path_total += path_lengths[i]
	queue_redraw()

func _process(delta: float) -> void:
	if not mode_selected:
		queue_redraw()
		return
	if game_over or won:
		queue_redraw()
		return
	update_wave(delta)
	update_balloons(delta)
	update_towers(delta)
	update_projectiles(delta)
	if online_mode:
		net_sync_timer -= delta
		if net_sync_timer <= 0.0:
			net_sync_timer = 0.25
			rpc_update_rival.rpc(lives, money, wave, towers, balloons, game_over)
	if wave_banner > 0.0:
		wave_banner -= delta
	queue_redraw()

func update_wave(delta: float) -> void:
	if wave_active:
		spawn_timer -= delta
		if spawn_left > 0 and spawn_timer <= 0.0:
			spawn_balloon()
			spawn_left -= 1
			spawn_timer = spawn_delay
		if spawn_left == 0 and balloons.is_empty():
			wave_active = false
			money += 80 + wave * 12
			if wave >= 12:
				won = true

func start_wave() -> void:
	if online_mode:
		start_wave_local()
		return
	start_wave_local()

func start_wave_local() -> void:
	if wave_active or game_over or won:
		return
	wave += 1
	wave_active = true
	spawn_left = 6 + wave * 3
	spawn_delay = max(0.18, 0.63 - wave * 0.025)
	spawn_timer = 0.15
	wave_banner = 1.8

func spawn_balloon() -> void:
	var tier := 1
	if wave >= 5 and rng.randf() < 0.22 + wave * 0.012:
		tier = 2
	if wave >= 9 and rng.randf() < 0.16:
		tier = 3
	var hp := tier
	balloons.append({"distance": 0.0, "speed": 58.0 + wave * 4.0 + tier * 8.0, "hp": hp, "max_hp": hp, "tier": tier})

func update_balloons(delta: float) -> void:
	for i in range(balloons.size() - 1, -1, -1):
		balloons[i].distance += balloons[i].speed * delta
		if balloons[i].distance >= path_total:
			lives -= balloons[i].tier
			balloons.remove_at(i)
			if lives <= 0:
				lives = 0
				game_over = true
				if online_mode:
					rpc_update_rival.rpc(lives, money, wave, towers, balloons, true)

func update_towers(delta: float) -> void:
	for tower in towers:
		tower.cooldown -= delta
		if tower.cooldown > 0.0:
			continue
		var target_index := -1
		var best_distance := -1.0
		for i in balloons.size():
			var balloon_position := point_on_path(balloons[i].distance)
			if tower.position.distance_to(balloon_position) <= tower.range and balloons[i].distance > best_distance:
				target_index = i
				best_distance = balloons[i].distance
		if target_index >= 0:
			projectiles.append({"position": tower.position, "target": target_index, "damage": tower.damage, "speed": 600.0, "color": tower.color})
			tower.cooldown = tower.reload

func update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var p := projectiles[i]
		if p.target < 0 or p.target >= balloons.size():
			projectiles.remove_at(i)
			continue
		var target_pos := point_on_path(balloons[p.target].distance)
		p.position = p.position.move_toward(target_pos, p.speed * delta)
		if p.position.distance_to(target_pos) < 15.0:
			balloons[p.target].hp -= p.damage
			if balloons[p.target].hp <= 0:
				money += 12 * balloons[p.target].tier
				balloons.remove_at(p.target)
				for other in projectiles:
					if other.target > p.target:
						other.target -= 1
			projectiles.remove_at(i)

func point_on_path(distance: float) -> Vector2:
	var remaining := distance
	for i in range(path_lengths.size()):
		if remaining <= path_lengths[i]:
			return path[i].lerp(path[i + 1], remaining / path_lengths[i])
		remaining -= path_lengths[i]
	return path[path.size() - 1]

func _input(event: InputEvent) -> void:
	if not mode_selected:
		if online_lobby:
			handle_lobby_input(event)
			return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if Rect2(250, 330, 230, 190).has_point(event.position):
				mode_selected = true
				multiplayer_mode = false
			elif Rect2(525, 330, 230, 190).has_point(event.position):
				mode_selected = true
				multiplayer_mode = true
			elif Rect2(800, 330, 230, 190).has_point(event.position):
				online_lobby = true
			queue_redraw()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1: selected_tower = 0
		if event.keycode == KEY_2: selected_tower = 1
		if event.keycode == KEY_SPACE: start_wave()
		if (game_over or won) and event.keycode == KEY_R: get_tree().reload_current_scene()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse: Vector2 = event.position
		if game_over or won:
			get_tree().reload_current_scene()
			return
		if online_mode:
			if Rect2(0, 60, 640, 317).has_point(mouse):
				var duel_position := (mouse - Vector2(0, 60)) / Vector2(0.5, 0.44)
				if PLAY_RECT.has_point(duel_position):
					place_tower(duel_position)
			if Rect2(20, 620, 260, 58).has_point(mouse):
				start_wave()
			return
		if Rect2(18, 400, 210, 72).has_point(mouse):
			selected_tower = 0
			return
		if Rect2(18, 482, 210, 72).has_point(mouse):
			selected_tower = 1
			return
		if Rect2(18, 602, 210, 64).has_point(mouse):
			start_wave()
			return
		if PLAY_RECT.has_point(mouse):
			place_tower(mouse)

func place_tower(position: Vector2) -> void:
	if online_mode:
		var before_count := towers.size()
		place_tower_local(position, selected_tower)
		if towers.size() > before_count:
			rpc_place_rival_tower.rpc(position, selected_tower)
		return
	place_tower_local(position, selected_tower)

func place_tower_local(position: Vector2, tower_kind: int) -> void:
	if money < TOWER_COSTS[tower_kind] or too_close_to_path(position) or too_close_to_tower(position):
		return
	money -= TOWER_COSTS[tower_kind]
	var is_boomerang := tower_kind == 1
	towers.append({
		"position": position, "range": 135.0 if not is_boomerang else 180.0,
		"damage": 1 if not is_boomerang else 2,
		"reload": 0.38 if not is_boomerang else 0.82,
		"cooldown": 0.0, "color": TOWER_COLORS[tower_kind], "type": tower_kind
	})
	if multiplayer_mode:
		active_player = 2 if active_player == 1 else 1

@rpc("any_peer", "reliable")
func rpc_update_rival(remote_lives: int, remote_money: int, remote_wave: int, remote_towers: Array, remote_balloons: Array, remote_lost: bool) -> void:
	rival_lives = remote_lives
	rival_money = remote_money
	rival_wave = remote_wave
	rival_towers = remote_towers
	rival_balloons = remote_balloons
	rival_defeated = remote_lost
	if remote_lost and not game_over:
		won = true

@rpc("any_peer", "reliable")
func rpc_place_rival_tower(position: Vector2, tower_kind: int) -> void:
	var is_boomerang := tower_kind == 1
	rival_towers.append({
		"position": position, "range": 135.0 if not is_boomerang else 180.0,
		"damage": 1 if not is_boomerang else 2,
		"reload": 0.38 if not is_boomerang else 0.82,
		"cooldown": 0.0, "color": TOWER_COLORS[tower_kind], "type": tower_kind
	})

func too_close_to_tower(position: Vector2) -> bool:
	for tower in towers:
		if position.distance_to(tower.position) < 58.0:
			return true
	return false

func too_close_to_path(position: Vector2) -> bool:
	for i in range(path.size() - 1):
		if Geometry2D.get_closest_point_to_segment(position, path[i], path[i + 1]).distance_to(position) < 48.0:
			return true
	return false

func _draw() -> void:
	if not mode_selected:
		if online_lobby:
			draw_online_lobby()
		else:
			draw_mode_select()
		return
	if online_mode:
		draw_online_duel()
		return
	draw_texture_rect(MAP_TEXTURE, Rect2(0, 0, WIDTH, HEIGHT), false)
	draw_rect(Rect2(0, 0, 248, HEIGHT), Color("102536"))
	draw_line(Vector2(248, 0), Vector2(248, HEIGHT), Color("72d2c8"), 2.0)
	draw_hud()
	# A friendly map guardian makes the island feel inhabited.
	draw_texture_rect(GUARDIAN_TEXTURE, Rect2(1130, 42, 70, 70), false)
	if online_mode:
		draw_duel_status()
	for tower in towers:
		var tower_texture = DART_RANGER_TEXTURE if tower.type == 0 else BOOMERANG_SCOUT_TEXTURE
		draw_texture_rect(tower_texture, Rect2(tower.position - Vector2(34, 38), Vector2(68, 68)), false)
	for balloon in balloons:
		draw_balloon(point_on_path(balloon.distance), balloon)
	for projectile in projectiles:
		draw_circle(projectile.position, 5, projectile.color)
	if wave_banner > 0.0:
		draw_centered("OLEADA %d" % wave, Vector2(765, 75), 34, Color.WHITE)
	if game_over or won:
		draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color(0.03, 0.08, 0.13, 0.76))
		draw_centered("¡FRONTERA DEFENDIDA!" if won else "LOS GLOBOS ESCAPARON", Vector2(765, 300), 42, Color("f8d36a") if won else Color("ff8d8d"))
		draw_centered("Haz clic o pulsa R para jugar de nuevo", Vector2(765, 355), 22, Color.WHITE)

func draw_hud() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(18, 46), "BALLOON\nFRONTIER", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("72d2c8"))
	draw_string(font, Vector2(18, 126), "$ %d" % money, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("ffd76a"))
	draw_string(font, Vector2(18, 164), "♥ %d     Oleada %d / 12" % [lives, wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	var mode_text := "CO-OP LOCAL\nTurno: Jugador %d" % active_player if multiplayer_mode else "1 VS 1 EN LINEA\nDuelo en curso" if online_mode else "INDIVIDUAL\nDefiende la salida"
	draw_string(font, Vector2(18, 210), "%s\n1 / 2: elige torre\nEspacio: iniciar oleada" % mode_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("bdd1de"))
	draw_tower_card(Rect2(18, 400, 210, 72), 0, "Dardo", "$120 · rápido")
	draw_tower_card(Rect2(18, 482, 210, 72), 1, "Bumerán", "$330 · potente")
	var button_color := Color("4bba83") if not wave_active else Color("355b70")
	draw_style_box(make_box(button_color, 10), Rect2(18, 602, 210, 64))
	draw_centered("INICIAR OLEADA" if not wave_active else "OLEADA ACTIVA", Vector2(123, 641), 15, Color.WHITE)

func draw_tower_card(rect: Rect2, kind: int, title: String, subtitle: String) -> void:
	var active := kind == selected_tower
	draw_style_box(make_box(Color("31546c") if active else Color("203c50"), 9), rect)
	var card_texture = DART_RANGER_TEXTURE if kind == 0 else BOOMERANG_SCOUT_TEXTURE
	draw_texture_rect(card_texture, Rect2(rect.position + Vector2(5, 4), Vector2(57, 57)), false)
	var font := ThemeDB.fallback_font
	draw_string(font, rect.position + Vector2(60, 30), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	draw_string(font, rect.position + Vector2(60, 53), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("bdd1de"))

func make_box(color: Color, radius: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.corner_radius_top_left = int(radius)
	box.corner_radius_top_right = int(radius)
	box.corner_radius_bottom_left = int(radius)
	box.corner_radius_bottom_right = int(radius)
	return box

func draw_balloon(position: Vector2, balloon: Dictionary) -> void:
	var colors := [Color("ef5e62"), Color("478fe4"), Color("f5d35d"), Color("a97cdd")]
	var color: Color = colors[balloon.tier]
	draw_circle(position, 15 + balloon.tier * 2, Color("263544"))
	draw_circle(position + Vector2(0, -2), 13 + balloon.tier * 2, color)
	draw_line(position + Vector2(0, 13), position + Vector2(0, 25), Color.WHITE, 1.5)
	if balloon.max_hp > 1:
		draw_rect(Rect2(position + Vector2(-16, -28), Vector2(32, 4)), Color("263544"))
		draw_rect(Rect2(position + Vector2(-16, -28), Vector2(32.0 * balloon.hp / balloon.max_hp, 4)), Color("7af092"))

func draw_centered(text_value: String, center: Vector2, size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var text_width := font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, center - Vector2(text_width / 2.0, 0), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func draw_mode_select() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	for i in range(11):
		draw_circle(Vector2(80 + i * 128, 100 + (i % 3) * 210), 90, Color("173c54"))
	draw_centered("BALLOON FRONTIER", Vector2(640, 145), 46, Color("72d2c8"))
	draw_centered("ELIGE TU MODO DE JUEGO", Vector2(640, 205), 20, Color("d9eef4"))
	draw_mode_card(Rect2(250, 330, 230, 190), Color("398cc0"), "INDIVIDUAL", "Defiende Coral Bend\na tu propio ritmo", "1 jugador")
	draw_mode_card(Rect2(525, 330, 230, 190), Color("b967a0"), "CO-OP LOCAL", "Cooperativo local:\nalterna turnos", "2 jugadores")
	draw_mode_card(Rect2(800, 330, 230, 190), Color("ef884e"), "EN LINEA 1 VS 1", "Crea una sala o\nunete a tu rival", "2 jugadores")
	draw_centered("Haz clic en un modo para comenzar", Vector2(640, 610), 18, Color("bdd1de"))

func draw_mode_card(rect: Rect2, accent: Color, title: String, description: String, players: String) -> void:
	draw_style_box(make_box(Color("1d4055"), 18), rect)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 10)), accent)
	draw_circle(rect.position + Vector2(rect.size.x / 2, 53), 25, accent)
	var font := ThemeDB.fallback_font
	var title_width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_string(font, rect.position + Vector2((rect.size.x - title_width) / 2, 102), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	var description_lines := description.split("\n")
	for i in range(description_lines.size()):
		var line_width := font.get_string_size(description_lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		draw_string(font, rect.position + Vector2((rect.size.x - line_width) / 2, 130 + i * 20), description_lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c9e2ea"))
	var player_width := font.get_string_size(players, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	draw_string(font, rect.position + Vector2((rect.size.x - player_width) / 2, 173), players, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, accent)

func handle_lobby_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and not editing_field.is_empty():
		if event.keycode == KEY_BACKSPACE:
			if editing_field == "ip": lobby_ip = lobby_ip.left(-1)
			else: lobby_port = lobby_port.left(-1)
		elif event.unicode > 0:
			var typed := char(event.unicode)
			if editing_field == "ip" and (typed == "." or typed.is_valid_int()): lobby_ip += typed
			if editing_field == "port" and typed.is_valid_int(): lobby_port += typed
		queue_redraw()
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if Rect2(400, 370, 480, 48).has_point(event.position):
		editing_field = "ip"
	elif Rect2(400, 425, 480, 48).has_point(event.position):
		editing_field = "port"
	elif Rect2(400, 500, 220, 62).has_point(event.position):
		create_online_room()
	elif Rect2(660, 500, 220, 62).has_point(event.position):
		join_online_room()
	elif Rect2(545, 630, 190, 46).has_point(event.position):
		online_lobby = false
	queue_redraw()

func create_online_room() -> void:
	var port_value := lobby_port.to_int()
	if port_value < 1 or port_value > 65535:
		lobby_status = "El puerto debe estar entre 1 y 65535."
		return
	network_peer = ENetMultiplayerPeer.new()
	var result := network_peer.create_server(port_value, 1)
	if result != OK:
		lobby_status = "No se pudo abrir ese puerto (%s)." % error_string(result)
		return
	multiplayer.multiplayer_peer = network_peer
	multiplayer.peer_connected.connect(_on_online_peer_connected)
	lobby_status = "Sala creada en el puerto %d. Esperando rival..." % port_value

func join_online_room() -> void:
	var port_value := lobby_port.to_int()
	if lobby_ip.is_empty() or port_value < 1 or port_value > 65535:
		lobby_status = "Escribe una IP y un puerto válidos."
		return
	network_peer = ENetMultiplayerPeer.new()
	var result := network_peer.create_client(lobby_ip, port_value)
	if result != OK:
		lobby_status = "No se pudo iniciar la conexión (%s)." % error_string(result)
		return
	multiplayer.multiplayer_peer = network_peer
	multiplayer.connected_to_server.connect(_on_online_connected)
	multiplayer.connection_failed.connect(_on_online_connection_failed)
	lobby_status = "Conectando con %s:%d..." % [lobby_ip, port_value]

func _on_online_peer_connected(_peer_id: int) -> void:
	launch_online_match()

func _on_online_connected() -> void:
	launch_online_match()

func _on_online_connection_failed() -> void:
	lobby_status = "No se pudo conectar. Revisa IP, puerto y firewall."

func launch_online_match() -> void:
	mode_selected = true
	online_lobby = false
	online_mode = true
	multiplayer_mode = false
	editing_field = ""
	queue_redraw()

func draw_online_lobby() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_centered("SALA EN LINEA · 1 VS 1", Vector2(640, 155), 38, Color("efaa5a"))
	draw_centered("ELIGE COMO QUIERES JUGAR", Vector2(640, 210), 19, Color("d9eef4"))
	draw_style_box(make_box(Color("1d4055"), 16), Rect2(340, 280, 600, 330))
	draw_centered("Introduce los datos de la sala", Vector2(640, 330), 17, Color("c9e2ea"))
	draw_lobby_field(Rect2(400, 370, 480, 48), "IP DEL RIVAL", lobby_ip, editing_field == "ip")
	draw_lobby_field(Rect2(400, 425, 480, 48), "PUERTO", lobby_port, editing_field == "port")
	draw_style_box(make_box(Color("b86247"), 12), Rect2(400, 500, 220, 62))
	draw_style_box(make_box(Color("3f93bb"), 12), Rect2(660, 500, 220, 62))
	draw_centered("CREAR SALA", Vector2(510, 539), 18, Color.WHITE)
	draw_centered("UNIRSE A SALA", Vector2(770, 539), 18, Color.WHITE)
	draw_centered(lobby_status, Vector2(640, 585), 14, Color("efcc80"))
	draw_style_box(make_box(Color("294a60"), 8), Rect2(545, 630, 190, 46))
	draw_centered("VOLVER", Vector2(640, 659), 16, Color("d9eef4"))

func draw_lobby_field(rect: Rect2, label: String, value: String, focused: bool) -> void:
	draw_style_box(make_box(Color("31546c") if focused else Color("294a60"), 8), rect)
	var font := ThemeDB.fallback_font
	draw_string(font, rect.position + Vector2(14, 20), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("9ebfcf"))
	draw_string(font, rect.position + Vector2(14, 39), value, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

func draw_duel_status() -> void:
	var font := ThemeDB.fallback_font
	draw_style_box(make_box(Color("1b5268"), 10), Rect2(286, 18, 260, 88))
	draw_style_box(make_box(Color("6a3545"), 10), Rect2(570, 18, 260, 88))
	draw_string(font, Vector2(305, 48), "TU FRENTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("8ce1f1"))
	draw_string(font, Vector2(305, 80), "♥ %d   $ %d   OLEADA %d" % [lives, money, wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(font, Vector2(589, 48), "FRENTE RIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffb0a8"))
	draw_string(font, Vector2(589, 80), "♥ %d   $ %d   OLEADA %d" % [rival_lives, rival_money, rival_wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func draw_online_duel() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_style_box(make_box(Color("1b5268"), 8), Rect2(12, 10, 616, 38))
	draw_style_box(make_box(Color("6a3545"), 8), Rect2(652, 10, 616, 38))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(30, 36), "TU MAPA · VIDAS %d · $ %d · OLEADA %d" % [lives, money, wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(font, Vector2(670, 36), "MAPA RIVAL · VIDAS %d · $ %d · OLEADA %d" % [rival_lives, rival_money, rival_wave], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_duel_arena(Vector2(0, 60), towers, balloons)
	draw_duel_arena(Vector2(640, 60), rival_towers, rival_balloons)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_style_box(make_box(Color("203c50"), 10), Rect2(20, 410, 270, 148))
	draw_string(font, Vector2(36, 442), "TORRE: %s" % TOWER_NAMES[selected_tower], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, TOWER_COLORS[selected_tower])
	draw_string(font, Vector2(36, 472), "1: Dardo ($120)   2: Bumerán ($330)", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
	draw_string(font, Vector2(36, 500), "Clic en TU MAPA para colocar", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("bdd1de"))
	draw_style_box(make_box(Color("4bba83") if not wave_active else Color("355b70"), 9), Rect2(20, 620, 260, 58))
	draw_centered("INICIAR TU OLEADA" if not wave_active else "OLEADA EN CURSO", Vector2(150, 656), 15, Color.WHITE)
	draw_string(font, Vector2(320, 444), "Gana quien aguanta más.", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("f4d66d"))
	draw_string(font, Vector2(320, 478), "Cada jugador defiende su propio mapa.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9eef4"))
	draw_string(font, Vector2(320, 510), "El primero que pierde todas sus vidas cae.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9eef4"))
	if game_over or won:
		draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color(0.03, 0.08, 0.13, 0.78))
		draw_centered("¡GANASTE EL DUELO!" if won else "TU FRENTE CAYO", Vector2(640, 350), 42, Color("f8d36a") if won else Color("ff8d8d"))
		draw_centered("Haz clic para volver a empezar", Vector2(640, 400), 21, Color.WHITE)

func draw_duel_arena(origin: Vector2, arena_towers: Array, arena_balloons: Array) -> void:
	draw_set_transform(origin, 0.0, Vector2(0.5, 0.44))
	draw_texture_rect(MAP_TEXTURE, Rect2(0, 0, WIDTH, HEIGHT), false)
	for tower in arena_towers:
		var tower_texture = DART_RANGER_TEXTURE if tower.type == 0 else BOOMERANG_SCOUT_TEXTURE
		draw_texture_rect(tower_texture, Rect2(tower.position - Vector2(34, 38), Vector2(68, 68)), false)
	for balloon in arena_balloons:
		draw_balloon(point_on_path(balloon.distance), balloon)
