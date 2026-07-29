extends Node2D

const WIDTH := 1920.0
const HEIGHT := 1080.0
const PLAY_RECT := Rect2(250, 0, 1030, 720)
const GAME_SPEEDS := [0.25, 0.5, 1.0, 2.0, 5.0, 10.0]
const SOLO_ARENA_ORIGIN := Vector2(0, 180)
const SOLO_ARENA_SCALE := Vector2(0.9, 0.9)
# Ritmo general de los globos: conserva la diferencia entre niveles, pero da
# más tiempo para responder antes de que crucen la frontera.
const BALLOON_SPEED_SCALE := 0.75
const TowerCatalogScript = preload("res://scripts/tower_catalog.gd")
const RemotePredictionScript = preload("res://scripts/remote_prediction.gd")
const GameSoundScript = preload("res://scripts/game_sound.gd")
const MapCatalogScript = preload("res://scripts/map_catalog.gd")
const TOWER_COSTS = TowerCatalogScript.COSTS
const TOWER_NAMES = TowerCatalogScript.NAMES
const TOWER_COLORS = TowerCatalogScript.COLORS
const DART_RANGER_TEXTURE = preload("res://assets/characters/dart_ranger.svg")
const BOOMERANG_SCOUT_TEXTURE = preload("res://assets/characters/boomerang_scout.svg")
const GUARDIAN_TEXTURE = preload("res://assets/characters/guardian.svg")
const BOMBARDIER_TEXTURE = preload("res://assets/characters/bombardier.svg")
const LIGHTNING_MAGE_TEXTURE = preload("res://assets/characters/lightning_mage.svg")
const MYSTIC_ARCHER_TEXTURE = preload("res://assets/characters/mystic_archer.svg")
const REEF_MEDIC_TEXTURE = preload("res://assets/characters/reef_medic.svg")
const BANANA_FARMER_TEXTURE = preload("res://assets/characters/banana_farmer.svg")
const PIRATE_TEXTURE = preload("res://assets/characters/pirate.svg")
const PATHCUTTER_TEXTURE = preload("res://assets/characters/pathcutter.svg")
const BOOMERANG_PROJECTILE_TEXTURE = preload("res://assets/projectiles/boomerang.svg")
const BOMB_PROJECTILE_TEXTURE = preload("res://assets/projectiles/black_bomb.svg")
const PROFILE_DEFAULT_TEXTURE = preload("res://assets/characters/profile_default.svg")
const MOAB_TEXTURE = preload("res://assets/balloons/moab_happy.svg")
const MOAB_DAMAGED_TEXTURE = preload("res://assets/balloons/moab_damaged.svg")
const MOAB_BROKEN_TEXTURE = preload("res://assets/balloons/moab_broken.svg")

var path := PackedVector2Array([
	Vector2(250, 170), Vector2(470, 170), Vector2(530, 310),
	Vector2(800, 310), Vector2(870, 500), Vector2(1120, 500), Vector2(1280, 610)
])
var path_lengths: Array[float] = []
var path_total := 1.0
var balloons: Array[Dictionary] = []
var towers: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var lightning_effects: Array[Dictionary] = []
var sword_swipes: Array[Dictionary] = []
var spikes: Array[Dictionary] = []
var upgrade_effects: Array[Dictionary] = []
var explosion_effects: Array[Dictionary] = []
var ultimate_tower_types: Dictionary = {}
var rival_sword_swipes: Array[Dictionary] = []
var rival_spikes: Array[Dictionary] = []
var bananas: Array[Dictionary] = []
var rival_bananas: Array[Dictionary] = []
var banana_popup_position := Vector2.ZERO
var banana_popup_time := 0.0
var banana_popup_value := 0
var money := 650
var lives := 150
var wave := 0
var selected_tower := 0
var wave_active := false
var spawn_left := 0
var spawn_timer := 0.0
var spawn_delay := 0.58
var wave_banner := 0.0
var match_elapsed := 0.0
var game_over := false
var won := false
var rng := RandomNumberGenerator.new()
var mode_selected := false
var multiplayer_mode := false
var online_mode := false
var solo_modern_mode := false
var online_lobby := false
var menu_music_select := false
var sound_menu_open := false
var sound_slider_drag := ""
var profile_menu_open := false
var profile_picker_open := false
var profile_name := "Jugador"
var profile_avatar := -1
var pending_profile_name := "Jugador"
var pending_profile_avatar := -1
var profile_avatar_hovered := false
var profile_status := ""
var rival_profile_name := ""
var rival_profile_avatar := -1
var vs_intro_time := 0.0
var vs_intro_spin := 0.0
var active_player := 1
var network_peer: ENetMultiplayerPeer
var lobby_ip := "127.0.0.1"
var lobby_port := "7777"
var editing_field := ""
var lobby_status := "Introduce una IP y un puerto para conectarte."
var rival_lives := 150
var rival_money := 650
var rival_wave := 0
var rival_towers: Array[Dictionary] = []
var rival_balloons: Array[Dictionary] = []
var rival_projectiles: Array[Dictionary] = []
var rival_lightning_effects: Array[Dictionary] = []
var rival_defeated := false
var net_sync_timer := 0.0
var auto_wave_timer := 2.5
var next_balloon_id := 1
var next_projectile_id := 1
var next_combat_effect_id := 1
var heard_rival_projectile_ids: Dictionary = {}
var heard_rival_effect_ids: Dictionary = {}
var next_banana_id := 1
var loadout_select := false
var chosen_towers: Array[int] = []
var loadout_ready := false
var rival_ready := false
var random_tower := -1
var roulette_display := -1
var roulette_time := 0.0
var roulette_tick := 0.0
var roulette_rolls_left := 2
var loadout_scroll_row := 0
var hover_loadout_tower := -1
var all_random_roulette_time := 0.0
var all_random_roulette_tick := 0.0
var all_random_reveal_time := 0.0
var all_random_slots: Array[int] = [-1, -1, -1, -1]
var all_random_results: Array[int] = []
var all_random_rolls_left := 3
var money_popup_amount := 0
var money_popup_time := 0.0
var surrender_prompt := false
var active_duel_tab := 0
var balloon_scroll_row := 0
var send_cooldown := 0.0
var inspected_tower_index := -1
var hover_upgrade_branch := -1
var beneficios := 200
var rival_beneficios := 200
var beneficios_timer := 0.0
var placement_tower := -1
var hover_tower := -1
var tower_ability_cooldowns: Dictionary = {}
var tower_ability_notice := ""
var tower_ability_notice_time := 0.0
var cursor_position := Vector2.ZERO
var local_wave_finished := false
var rival_wave_finished := false
var online_wave_start_timer := -1.0
var game_sound: GameSound
var result_sound_played := false
var gameplay_speed := 1.0
var local_speed_vote := 0.0
var rival_speed_vote := 0.0
var speed_menu_open := false
# El modo de pruebas está disponible siempre; el botón solo abre su panel.
var debug_mode := true
var debug_panel_open := false
var local_debug_vote := 0
var rival_debug_vote := 0
var debug_paused := false
var debug_invulnerable := false
var debug_tab := 0
var debug_spawn_kind := -1
var debug_spawn_camouflaged := false
var debug_spawn_regenerative := false
var debug_hover_balloon := -1
var debug_balloon_scroll_row := 0
var local_pause_vote := 0
var rival_pause_vote := 0
var debug_wave_input := ""
var outgoing_debug_wave := -1
var pending_debug_wave := -1
var map_select := false
var selected_map_vote := -1
var rival_map_vote := -1
var map_ready := false
var rival_map_ready := false
var active_map := 0
var map_reveal_time := 0.0
var map_resolution_label := ""
var map_resolution_spin := 0.0
var map_coin_time := 0.0
var map_coin_spin := 0.0
var map_coin_heads := true
var map_coin_host_vote := 0
var map_coin_join_vote := 0
var map_roulette_time := 0.0
var map_roulette_spin := 0.0
var map_roulette_result := 0

func _ready() -> void:
	game_sound = GameSoundScript.new()
	add_child(game_sound)
	var settings := ConfigFile.new()
	if settings.load("user://balloon_frontier.cfg") == OK:
		lobby_ip = settings.get_value("online", "last_ip", lobby_ip)
		game_sound.set_menu_track(int(settings.get_value("audio", "menu_track", game_sound.menu_track)))
		game_sound.set_music_volume(int(settings.get_value("audio", "music_volume", 100)))
		game_sound.set_effects_volume(int(settings.get_value("audio", "effects_volume", 100)))
		profile_name = str(settings.get_value("profile", "name", profile_name)).left(12)
		profile_avatar = clampi(int(settings.get_value("profile", "avatar", profile_avatar)), -1, 8)
	game_sound.set_music("menu")
	rng.randomize()
	for i in range(path.size() - 1):
		path_lengths.append(path[i].distance_to(path[i + 1]))
		path_total += path_lengths[i]
	queue_redraw()

func _process(delta: float) -> void:
	if money_popup_time > 0.0:
		money_popup_time -= delta
	if send_cooldown > 0.0:
		send_cooldown = maxf(0.0, send_cooldown - delta)
	if vs_intro_time > 0.0:
		game_sound.set_music("menu")
		vs_intro_time -= delta
		vs_intro_spin += delta
		if vs_intro_time <= 0.0:
			open_map_select(true)
		queue_redraw()
		return
	if map_select:
		game_sound.set_music("menu")
		update_map_selection(delta)
		queue_redraw()
		return
	if loadout_select:
		game_sound.set_music("menu")
		update_roulette(delta)
		queue_redraw()
		return
	if not mode_selected:
		game_sound.set_music("menu")
		queue_redraw()
		return
	if game_over or won:
		if not result_sound_played:
			game_sound.play_effect("win" if won else "lose", -1.5)
			result_sound_played = true
		queue_redraw()
		return
	game_sound.set_music("game")
	var gameplay_delta := 0.0 if debug_paused else delta * gameplay_speed
	update_tower_ability_cooldowns(gameplay_delta)
	match_elapsed += gameplay_delta
	update_wave(gameplay_delta)
	update_online_wave_sync(gameplay_delta)
	update_solo_auto_wave(gameplay_delta)
	update_balloons(gameplay_delta)
	update_regenerative_balloons(gameplay_delta)
	update_banana_farms(gameplay_delta)
	beneficios_timer += gameplay_delta
	if beneficios_timer >= 5.0:
		beneficios_timer -= 5.0
		money += beneficios
	if online_mode:
		update_rival_prediction(gameplay_delta)
	update_towers(gameplay_delta)
	update_projectiles(gameplay_delta)
	update_lightning_effects(gameplay_delta)
	update_sword_swipes(gameplay_delta)
	update_upgrade_effects(gameplay_delta)
	update_explosion_effects(gameplay_delta)
	if online_mode:
		net_sync_timer -= delta
		if net_sync_timer <= 0.0:
			net_sync_timer = 0.10
			rpc_update_rival.rpc(lives, money, beneficios, wave, towers, balloons, projectiles, lightning_effects, bananas, sword_swipes, spikes, game_over)
	if wave_banner > 0.0:
		wave_banner -= gameplay_delta
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
			if online_mode:
				report_local_wave_finished()
			elif not multiplayer_mode and wave < 12:
				auto_wave_timer = 2.5
			if wave >= 12 and not online_mode:
				won = true

func update_solo_auto_wave(delta: float) -> void:
	if online_mode or multiplayer_mode or wave_active or game_over or won:
		return
	auto_wave_timer -= delta
	if auto_wave_timer <= 0.0:
		auto_wave_timer = -1.0
		start_wave_local()

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
	if game_sound:
		game_sound.play_wave_start_effect()

func update_online_wave_sync(delta: float) -> void:
	if not online_mode or not multiplayer.is_server() or online_wave_start_timer < 0.0:
		return
	online_wave_start_timer -= delta
	if online_wave_start_timer <= 0.0:
		online_wave_start_timer = -1.0
		rpc_begin_online_wave.rpc(wave + 1)

func report_local_wave_finished() -> void:
	if local_wave_finished:
		return
	local_wave_finished = true
	if multiplayer.is_server():
		try_schedule_online_wave()
	else:
		rpc_report_wave_finished.rpc_id(1, wave)

func try_schedule_online_wave() -> void:
	if local_wave_finished and rival_wave_finished and online_wave_start_timer < 0.0:
		online_wave_start_timer = 2.5

@rpc("any_peer", "reliable")
func rpc_report_wave_finished(finished_wave: int) -> void:
	if multiplayer.is_server() and finished_wave == wave:
		rival_wave_finished = true
		try_schedule_online_wave()

@rpc("any_peer", "call_local", "reliable")
func rpc_begin_online_wave(next_wave: int) -> void:
	if game_over or won:
		return
	wave = next_wave - 1
	local_wave_finished = false
	rival_wave_finished = false
	start_wave_local()

func spawn_balloon() -> void:
	# Special balloon categories use only the top three levels available in a wave.
	var regenerative := wave >= 12 and rng.randf() < minf(0.06 + (wave - 12) * 0.006, 0.18)
	var camouflaged := wave >= 8 and rng.randf() < minf(0.07 + (wave - 8) * 0.008, 0.22)
	if camouflaged or regenerative:
		spawn_ranked_variant(camouflaged, regenerative)
		return
	camouflaged = false
	if wave >= 28 and rng.randf() < minf(0.014 + (wave - 28) * 0.006, 0.07):
		spawn_ceramic_nine_balloon(0.0, camouflaged, regenerative)
		return
	if wave >= 25 and rng.randf() < minf(0.022 + (wave - 25) * 0.009, 0.10):
		spawn_magic_shield_balloon(0.0, camouflaged, regenerative)
		return
	if wave >= 23 and rng.randf() < minf(0.025 + (wave - 23) * 0.01, 0.12):
		spawn_armored_balloon(0.0, camouflaged, regenerative)
		return
	# MOABs are effectively tier 10 threats: rare, late-game and never spammed.
	if wave >= 34 and rng.randf() < minf(0.004 + (wave - 34) * 0.0015, 0.025):
		spawn_moab(0.0, camouflaged, regenerative)
		return
	var tier := 1
	if wave >= 3 and rng.randf() < minf(0.20 + wave * 0.025, 0.55):
		tier = 2
	if wave >= 4 and rng.randf() < minf(0.08 + (wave - 4) * 0.022, 0.42):
		tier = 3
	if wave >= 7 and rng.randf() < minf(0.06 + (wave - 7) * 0.018, 0.31):
		tier = 4
	if wave >= 10 and rng.randf() < minf(0.04 + (wave - 10) * 0.014, 0.24):
		tier = 5
	if wave >= 15 and rng.randf() < minf(0.035 + (wave - 15) * 0.012, 0.16):
		tier = 6
	if wave >= 18 and rng.randf() < minf(0.025 + (wave - 18) * 0.011, 0.13):
		tier = 7
	if wave >= 21 and rng.randf() < minf(0.018 + (wave - 21) * 0.009, 0.10):
		tier = 8
	if wave >= 24 and rng.randf() < minf(0.012 + (wave - 24) * 0.007, 0.075):
		tier = 9
	spawn_balloon_of_tier(tier, 0.0, camouflaged, regenerative)

func spawn_ranked_variant(camouflaged: bool, regenerative: bool) -> void:
	var candidates: Array[float] = []
	if wave >= 34:
		# A MOAB is level 10; level 8 variants, level 9 balloons and the MOAB
		# itself are valid camouflage candidates.
		candidates = [8.0, 8.1, 8.2, 9.0, 9.5, 10.0]
	elif wave >= 28:
		# The ceramic shell is treated as level 9.5, so the lower bound is 8.
		candidates = [8.0, 8.1, 8.2, 9.0, 9.5]
	elif wave >= 24:
		candidates = [7.0, 8.0, 8.1, 8.2, 9.0]
	elif wave >= 21:
		candidates = [6.0, 7.0, 8.0, 8.1]
	elif wave >= 18:
		candidates = [5.0, 6.0, 7.0]
	elif wave >= 15:
		candidates = [4.0, 5.0, 6.0]
	elif wave >= 10:
		candidates = [3.0, 4.0, 5.0]
	else:
		candidates = [2.0, 3.0, 4.0]
	# MOABs can be camouflaged, but never regenerative.
	if regenerative:
		candidates.erase(10.0)
	var selection: float = candidates[rng.randi_range(0, candidates.size() - 1)]
	if is_equal_approx(selection, 10.0):
		spawn_moab(0.0, camouflaged, regenerative)
	elif is_equal_approx(selection, 9.5):
		spawn_ceramic_nine_balloon(0.0, camouflaged, regenerative)
	elif is_equal_approx(selection, 8.1):
		spawn_armored_balloon(0.0, camouflaged, regenerative)
	elif is_equal_approx(selection, 8.2):
		spawn_magic_shield_balloon(0.0, camouflaged, regenerative)
	else:
		spawn_balloon_of_tier(int(selection), 0.0, camouflaged, regenerative)

func spawn_balloon_of_tier(tier: int, initial_distance := 0.0, camouflaged := false, regenerative := false) -> void:
	var hp := tier
	var base_speed := (58.0 + wave * 4.0) * BALLOON_SPEED_SCALE
	var balloon_speed: float = base_speed + tier * 7.0 * BALLOON_SPEED_SCALE
	if tier == 7:
		balloon_speed *= 1.65
	var split_level: int = 5 if tier == 6 else 7 if tier == 8 else 0
	var split_tiers: Array[int] = []
	if tier == 9:
		split_tiers = [8, 8, 8, 8, 7, 7]
	balloons.append({"id": next_balloon_id, "distance": initial_distance, "base_speed": base_speed, "speed": balloon_speed, "hp": hp, "max_hp": hp, "tier": tier, "moab": false, "camouflaged": camouflaged, "regenerative": regenerative, "regen_start_tier": tier, "regen_cap": float(tier), "regen_since_hit": 0.0, "regen_tick": 0.0, "split_on_destroy": split_level > 0 or not split_tiers.is_empty(), "split_level": split_level, "split_tiers": split_tiers, "leak_damage": tier, "radius": 24.0})
	next_balloon_id += 1

func spawn_moab(initial_distance := 0.0, camouflaged := false, regenerative := false) -> void:
	var speed: float = (36.0 + wave * 1.1) * BALLOON_SPEED_SCALE
	balloons.append({"id": next_balloon_id, "distance": initial_distance, "base_speed": speed, "speed": speed, "hp": 100, "max_hp": 100, "tier": 100, "moab": true, "camouflaged": camouflaged, "regenerative": regenerative, "regen_start_tier": 10, "regen_cap": 10.0, "regen_since_hit": 0.0, "regen_tick": 0.0, "moab_hp": 100, "moab_stage": 0, "leak_damage": 140, "radius": 43.0})
	next_balloon_id += 1

func spawn_armored_balloon(initial_distance := 0.0, camouflaged := false, regenerative := false) -> void:
	var base_speed: float = (58.0 + wave * 4.0) * BALLOON_SPEED_SCALE
	var tier_two_speed: float = base_speed + 14.0 * BALLOON_SPEED_SCALE
	balloons.append({"id": next_balloon_id, "distance": initial_distance, "base_speed": base_speed, "speed": tier_two_speed, "hp": 32, "max_hp": 32, "tier": 8, "moab": false, "camouflaged": camouflaged, "regenerative": regenerative, "regen_start_tier": 8, "regen_cap": 8.0, "regen_since_hit": 0.0, "regen_tick": 0.0, "armored": true, "armor_hp": 32, "leak_damage": 18, "radius": 35.0})
	next_balloon_id += 1

func spawn_magic_shield_balloon(initial_distance := 0.0, camouflaged := false, regenerative := false) -> void:
	var base_speed: float = (58.0 + wave * 4.0) * BALLOON_SPEED_SCALE
	var tier_two_speed: float = base_speed + 14.0 * BALLOON_SPEED_SCALE
	balloons.append({"id": next_balloon_id, "distance": initial_distance, "base_speed": base_speed, "speed": tier_two_speed, "hp": 32, "max_hp": 32, "tier": 8, "moab": false, "camouflaged": camouflaged, "regenerative": regenerative, "regen_start_tier": 8, "regen_cap": 8.0, "regen_since_hit": 0.0, "regen_tick": 0.0, "magic_shield": true, "shield_hp": 32, "leak_damage": 18, "radius": 35.0})
	next_balloon_id += 1

func spawn_ceramic_nine_balloon(initial_distance := 0.0, camouflaged := false, regenerative := false) -> void:
	var base_speed: float = (58.0 + wave * 4.0) * BALLOON_SPEED_SCALE
	balloons.append({"id": next_balloon_id, "distance": initial_distance, "base_speed": base_speed, "speed": base_speed + 63.0 * BALLOON_SPEED_SCALE, "hp": 13, "max_hp": 13, "tier": 9, "moab": false, "camouflaged": camouflaged, "regenerative": regenerative, "regen_start_tier": 9, "regen_cap": 9.5, "regen_since_hit": 0.0, "regen_tick": 0.0, "ceramic_shell": true, "shell_hp": 13, "shell_stage": 0, "leak_damage": 9, "radius": 36.0})
	next_balloon_id += 1

func update_balloons(delta: float) -> void:
	for i in range(balloons.size() - 1, -1, -1):
		balloons[i].distance += balloons[i].speed * delta
		for spike_index in range(spikes.size() - 1, -1, -1):
			if point_on_path(balloons[i].distance).distance_to(spikes[spike_index].position) <= 18.0:
				var spike_owner: int = int(spikes[spike_index].get("owner", -1))
				var spike_damage: int = int(spikes[spike_index].get("damage", 1))
				spikes.remove_at(spike_index)
				damage_balloon(i, spike_damage, "physical", spike_owner)
				break
		if i >= balloons.size():
			continue
		if balloons[i].distance >= path_total:
			if not debug_invulnerable:
				lives -= int(balloons[i].get("leak_damage", balloons[i].tier))
			balloons.remove_at(i)
			if lives <= 0:
				lives = 0
				game_over = true
				if online_mode:
					rpc_update_rival.rpc(lives, money, beneficios, wave, towers, balloons, projectiles, lightning_effects, bananas, sword_swipes, spikes, true)
					rpc_report_defeat.rpc()

func update_regenerative_balloons(delta: float) -> void:
	for index in range(balloons.size() - 1, -1, -1):
		var balloon: Dictionary = balloons[index]
		if not balloon.get("regenerative", false):
			continue
		balloon.regen_since_hit = float(balloon.get("regen_since_hit", 0.0)) + delta
		if balloon.regen_since_hit < 5.0:
			continue
		balloon.regen_tick = float(balloon.get("regen_tick", 0.0)) + delta
		if balloon.regen_tick < 2.0:
			continue
		balloon.regen_tick = 0.0
		regenerate_balloon(index)

func regenerate_balloon(index: int) -> void:
	if index < 0 or index >= balloons.size():
		return
	var balloon: Dictionary = balloons[index]
	if balloon.get("moab", false):
		balloon.moab_hp = mini(100, int(balloon.get("moab_hp", 100)) + 10)
		balloon.hp = balloon.moab_hp
		return
	if balloon.get("armored", false):
		balloon.armor_hp = mini(32, int(balloon.get("armor_hp", 32)) + 4)
		balloon.hp = balloon.armor_hp
		return
	if balloon.get("magic_shield", false):
		balloon.shield_hp = mini(32, int(balloon.get("shield_hp", 32)) + 4)
		balloon.hp = balloon.shield_hp
		return
	if balloon.get("ceramic_shell", false):
		balloon.shell_hp = mini(13, int(balloon.get("shell_hp", 13)) + 2)
		balloon.hp = balloon.shell_hp
		return
	var cap: float = float(balloon.get("regen_cap", balloon.get("regen_start_tier", balloon.tier)))
	if float(balloon.tier) < cap:
		balloon.tier += 1
		balloon.hp = balloon.tier
		balloon.max_hp = balloon.tier
		balloon.speed = balloon.base_speed + balloon.tier * 7.0 * BALLOON_SPEED_SCALE
		return
	# A ceramic balloon whose shell was broken reforms it after recovering to
	# its original level 9, then regains the 9.5 ceramic layer.
	if is_equal_approx(cap, 9.5) and not balloon.get("ceramic_shell", false) and balloon.tier >= 9:
		balloon.ceramic_shell = true
		balloon.shell_hp = 13
		balloon.shell_stage = 0
		balloon.hp = 13
		balloon.max_hp = 13

func update_rival_prediction(delta: float) -> void:
	# The opponent sends snapshots; advance balloons and homing darts locally between packets.
	for i in range(rival_balloons.size() - 1, -1, -1):
		rival_balloons[i].distance += rival_balloons[i].speed * delta
		if rival_balloons[i].distance >= path_total:
			rival_balloons.remove_at(i)
	for index in range(rival_projectiles.size() - 1, -1, -1):
		var dart: Dictionary = rival_projectiles[index]
		var previous_position: Vector2 = dart.position
		if dart.kind == 1 and dart.has("circle_center"):
			var angular_step: float = dart.speed / dart.circle_radius * delta
			dart.circle_angle += angular_step
			dart.arc_remaining -= angular_step
			dart.position = dart.circle_center + Vector2(cos(dart.circle_angle), sin(dart.circle_angle)) * dart.circle_radius
		elif dart.kind == 4:
			# The mystic arrow follows the firing vector captured at the tower,
			# rather than chasing the target's later position.
			dart.position += dart.direction * dart.speed * delta
			dart.remaining -= dart.speed * delta
			if dart.remaining <= 0.0:
				rival_projectiles.remove_at(index)
				continue
		else:
			var target_position: Vector2 = dart.target_position
			dart.position = dart.position.move_toward(target_position, dart.speed * delta)
		var movement: Vector2 = dart.position - previous_position
		if movement.length_squared() > 0.01:
			dart.direction = movement.normalized()
	for index in range(rival_sword_swipes.size() - 1, -1, -1):
		rival_sword_swipes[index].time -= delta
		if rival_sword_swipes[index].time <= 0.0:
			rival_sword_swipes.remove_at(index)

func update_towers(delta: float) -> void:
	for tower_index in range(towers.size()):
		var tower: Dictionary = towers[tower_index]
		if tower.type == 0 and float(tower.get("overdrive_time", 0.0)) > 0.0:
			tower.overdrive_time = maxf(0.0, float(tower.overdrive_time) - delta)
		if tower.type == 5:
			continue
		tower.cooldown -= delta
		if tower.type == 6:
			if tower.cooldown <= 0.0:
				var lives_before_heal := lives
				lives = min(150, lives + int(tower.get("heal_amount", 8)))
				tower.cooldown = tower.reload
				if lives > lives_before_heal:
					tower.effective_healing = int(tower.get("effective_healing", 0)) + lives - lives_before_heal
					if game_sound:
						game_sound.play_heal_effect()
			continue
		if tower.type == 8:
			if tower.cooldown <= 0.0:
				drop_path_spikes(tower.position, tower.range, tower_index)
				tower.cooldown = tower.reload
			continue
		if tower.cooldown > 0.0:
			continue
		var target_index := choose_tower_target(tower)
		if target_index >= 0:
			if tower.type == 3:
				cast_chain_lightning(tower.position, target_index, tower_index)
			elif tower.type == 7:
				cast_pirate_sweep(tower.position, point_on_path(balloons[target_index].distance), tower_index)
			else:
				var locked_target_position := point_on_path(balloons[target_index].distance)
				var shot_direction: Vector2 = (locked_target_position - tower.position).normalized()
				var dart_pierce: int = int(tower.get("pierce", 0))
				if tower.type == 0 and tower.get("dart_giant", false): dart_pierce = 999
				var projectile := {"id": next_projectile_id, "owner": tower_index, "position": tower.position, "target": target_index, "target_position": locked_target_position, "damage": tower.damage, "damage_type": tower.damage_type, "speed": tower.projectile_speed, "color": tower.color, "direction": shot_direction, "kind": tower.type, "remaining": tower.projectile_range, "hit_ids": [], "pierce": dart_pierce, "scale": float(tower.get("dart_scale", 1.0))}
				if tower.type == 1:
					var chord: Vector2 = locked_target_position - tower.position
					# El radio base de 80 corresponde al alcance base del bumerÃ¡n (180).
					# De esta forma las mejoras de alcance agrandan la circunferencia en proporciÃ³n.
					var base_range: float = float(TowerCatalogScript.config(1).range)
					var fixed_radius: float = 80.0 * float(tower.range) / base_range
					var half_chord: float = chord.length() * 0.5
					var perpendicular: Vector2 = Vector2(-chord.y, chord.x).normalized()
					var center_a: Vector2 = (tower.position + locked_target_position) * 0.5 + perpendicular * sqrt(maxf(0.0, fixed_radius * fixed_radius - half_chord * half_chord))
					var center_b: Vector2 = (tower.position + locked_target_position) * 0.5 - perpendicular * sqrt(maxf(0.0, fixed_radius * fixed_radius - half_chord * half_chord))
					var start_a: float = (tower.position - center_a).angle()
					var target_a: float = (locked_target_position - center_a).angle()
					var travel_a: float = fposmod(target_a - start_a, TAU)
					var center: Vector2 = center_a if travel_a <= PI else center_b
					projectile.circle_center = center
					projectile.circle_radius = fixed_radius
					projectile.circle_angle = (tower.position - center).angle()
					projectile.arc_remaining = TAU
				var shot_count: int = int(tower.get("burst", 1)) if tower.type == 0 else 1
				for shot in range(shot_count):
					var spread: float = (float(shot) - float(shot_count - 1) * 0.5) * 0.055
					var fired_projectile: Dictionary = projectile.duplicate()
					fired_projectile.id = next_projectile_id
					fired_projectile.direction = shot_direction.rotated(spread)
					projectiles.append(fired_projectile)
					next_projectile_id += 1
				if tower.type == 4:
					game_sound.play_mystic_arrow_effect()
				else:
					game_sound.play_effect("dart", -15.0)
			tower.cooldown = float(tower.reload) / 2.5 if tower.type == 0 and float(tower.get("overdrive_time", 0.0)) > 0.0 else tower.reload

func choose_tower_target(tower: Dictionary) -> int:
	var mode: int = int(tower.get("target_mode", 0))
	var chosen_index := -1
	for index in range(balloons.size()):
		if balloons[index].get("camouflaged", false) and not bool(tower.get("thermal_vision", false)):
			continue
		var balloon_position := point_on_path(balloons[index].distance)
		var target_distance: float = tower.position.distance_to(balloon_position)
		var can_mark: bool = target_distance <= float(tower.range)
		if tower.type == 1:
			var boomerang_radius: float = 80.0 * float(tower.range) / float(TowerCatalogScript.config(1).range)
			# El objetivo debe poder quedar sobre la circunferencia completa del lanzamiento.
			can_mark = target_distance <= minf(float(tower.range), boomerang_radius * 2.0)
		if not can_mark:
			continue
		if chosen_index < 0:
			chosen_index = index
			continue
		var current: Dictionary = balloons[chosen_index]
		var candidate: Dictionary = balloons[index]
		if mode == 0 and candidate.distance > current.distance:
			chosen_index = index
		elif mode == 1 and candidate.distance < current.distance:
			chosen_index = index
		elif mode == 2 and (candidate.tier > current.tier or (candidate.tier == current.tier and candidate.distance > current.distance)):
			chosen_index = index
		elif mode == 3 and (candidate.tier < current.tier or (candidate.tier == current.tier and candidate.distance > current.distance)):
			chosen_index = index
	return chosen_index

func update_banana_farms(delta: float) -> void:
	for farm_index in range(towers.size()):
		var farm: Dictionary = towers[farm_index]
		if farm.type != 5:
			continue
		farm.banana_timer += delta
		if farm.banana_timer >= float(farm.get("banana_interval", 8.0)):
			farm.banana_timer = 0.0
			var base_banana_value: int = int(farm.get("banana_value", 30))
			var spawn_angle := rng.randf_range(0.0, TAU)
			var spawn_distance := sqrt(rng.randf()) * float(farm.get("range", 115.0))
			var banana_position: Vector2 = farm.position + Vector2.from_angle(spawn_angle) * spawn_distance
			bananas.append({"id": next_banana_id, "owner": farm_index, "position": banana_position, "base_value": base_banana_value, "value": base_banana_value, "age": 0.0, "brown_stage": 0, "collecting": false})
			next_banana_id += 1
	if banana_popup_time > 0.0:
		banana_popup_time -= delta
	var cursor_on_map := Rect2(0, 270, 960, 540).has_point(cursor_position)
	var cursor_map_position := (cursor_position - Vector2(0, 270)) / Vector2(0.75, 0.75)
	for i in range(bananas.size() - 1, -1, -1):
		bananas[i].age += delta
		var brown_stage: int = 0
		if bananas[i].age >= 5.0:
			brown_stage = mini(3, int(floor((bananas[i].age - 5.0) / 3.0)) + 1)
		bananas[i].brown_stage = brown_stage
		var brown_value_multiplier: float = [1.0, 0.70, 0.50, 0.20][brown_stage]
		# Las mejoras elevan el valor base; el deterioro se aplica sobre ese valor.
		# Ceil conserva una recompensa justa cuando el resultado tiene decimales.
		bananas[i].value = ceili(float(bananas[i].get("base_value", 30)) * brown_value_multiplier)
		if cursor_on_map and bananas[i].position.distance_to(cursor_map_position) < 165.0:
			bananas[i].collecting = true
			bananas[i].position = bananas[i].position.move_toward(cursor_map_position, 430.0 * delta)
			if bananas[i].position.distance_to(cursor_map_position) < 16.0:
				collect_banana_index(i)
				continue
		if bananas[i].age >= 13.0:
			bananas.remove_at(i)

func cast_chain_lightning(origin: Vector2, first_target: int, owner_index: int) -> void:
	var chain_points: Array[Vector2] = [origin]
	var used_ids: Dictionary = {}
	var current_index := first_target
	var max_jumps: int = int(towers[owner_index].get("chain_hits", 5)) if owner_index >= 0 and owner_index < towers.size() else 5
	var lightning_damage: int = int(towers[owner_index].get("damage", 1)) if owner_index >= 0 and owner_index < towers.size() else 1
	for _jump in range(max_jumps):
		if current_index < 0 or current_index >= balloons.size():
			break
		var target_position := point_on_path(balloons[current_index].distance)
		var target_id: int = int(balloons[current_index].get("id", current_index))
		chain_points.append(target_position)
		used_ids[target_id] = true
		# Cada salto conserva el daño actual del mago, incluidas sus mejoras de poder.
		damage_balloon(current_index, lightning_damage, "magic", owner_index)
		var next_index := -1
		var best_distance := INF
		var origin_point := chain_points[chain_points.size() - 1]
		for i in balloons.size():
			if used_ids.has(int(balloons[i].get("id", i))):
				continue
			if balloons[i].get("camouflaged", false) and not tower_has_thermal_vision(owner_index):
				continue
			var candidate := point_on_path(balloons[i].distance)
			var candidate_distance := origin_point.distance_to(candidate)
			if candidate_distance < best_distance:
				best_distance = candidate_distance
				next_index = i
		current_index = next_index
	lightning_effects.append({"id": next_combat_effect_id, "points": chain_points, "time": 0.78})
	next_combat_effect_id += 1
	if game_sound:
		game_sound.play_lightning_cast_effect()

func update_lightning_effects(delta: float) -> void:
	for i in range(lightning_effects.size() - 1, -1, -1):
		lightning_effects[i].time -= delta
		if lightning_effects[i].time <= 0.0:
			lightning_effects.remove_at(i)

func cast_pirate_sweep(origin: Vector2, target_position: Vector2, owner_index: int) -> void:
	var facing: Vector2 = (target_position - origin).normalized()
	for index in range(balloons.size() - 1, -1, -1):
		var offset: Vector2 = point_on_path(balloons[index].distance) - origin
		if offset.length() <= 90.0 and facing.dot(offset.normalized()) >= 0.0:
			damage_balloon(index, 2, "physical", owner_index)
	sword_swipes.append({"id": next_combat_effect_id, "position": origin, "angle": facing.angle(), "time": 0.32})
	next_combat_effect_id += 1
	if game_sound:
		game_sound.play_pirate_sword_sweep()

func drop_path_spikes(origin: Vector2, tower_range: float, owner_index: int) -> void:
	for _attempt in range(24):
		var drop_position := point_on_path(rng.randf_range(0.0, path_total))
		if origin.distance_to(drop_position) > tower_range or spike_density(drop_position) >= 50:
			continue
		var spike_count: int = int(towers[owner_index].get("spike_count", 4)) if owner_index >= 0 and owner_index < towers.size() else 4
		var spike_damage: int = int(towers[owner_index].get("damage", 1)) if owner_index >= 0 and owner_index < towers.size() else 1
		for _spike in range(spike_count):
			spikes.append({"position": drop_position + Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8)), "owner": owner_index, "damage": spike_damage})
		return

func spike_density(position: Vector2) -> int:
	var count := 0
	for spike in spikes:
		if absf(spike.position.x - position.x) <= 25.0 and absf(spike.position.y - position.y) <= 25.0:
			count += 1
	return count

func update_sword_swipes(delta: float) -> void:
	for index in range(sword_swipes.size() - 1, -1, -1):
		sword_swipes[index].time -= delta
		if sword_swipes[index].time <= 0.0:
			sword_swipes.remove_at(index)

func update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var p := projectiles[i]
		var previous_position: Vector2 = p.position
		if p.kind == 4 or p.kind == 1 or int(p.get("pierce", 0)) > 0:
			if p.kind == 1:
				var angular_step: float = p.speed / p.circle_radius * delta
				p.circle_angle += angular_step
				p.arc_remaining -= angular_step
				p.position = p.circle_center + Vector2(cos(p.circle_angle), sin(p.circle_angle)) * p.circle_radius
			else:
				p.position += p.direction * p.speed * delta
				p.remaining -= p.speed * delta
			for j in range(balloons.size() - 1, -1, -1):
				if balloons[j].id not in p.hit_ids and p.position.distance_to(point_on_path(balloons[j].distance)) < float(balloons[j].get("radius", 24.0)):
					p.hit_ids.append(balloons[j].id)
					damage_balloon(j, p.damage, str(p.get("damage_type", "physical")), int(p.get("owner", -1)))
			if int(p.get("pierce", 0)) > 0 and p.hit_ids.size() > int(p.get("pierce", 0)):
				projectiles.remove_at(i)
				continue
			if (p.kind == 1 and p.arc_remaining <= 0.0) or (p.kind != 1 and p.remaining <= 0.0):
				projectiles.remove_at(i)
			continue
		if p.target < 0 or p.target >= balloons.size():
			projectiles.remove_at(i)
			continue
		var target_pos: Vector2 = p.target_position
		p.position = p.position.move_toward(target_pos, p.speed * delta)
		var movement: Vector2 = p.position - previous_position
		if movement.length_squared() > 0.01:
			p.direction = movement.normalized()
		if p.position.distance_to(target_pos) < 15.0:
			if p.kind == 2:
				var explosion_radius := 68.0
				var explosion_owner: int = int(p.get("owner", -1))
				if explosion_owner >= 0 and explosion_owner < towers.size():
					explosion_radius = float(towers[explosion_owner].get("explosion_radius", 68.0))
				for j in range(balloons.size() - 1, -1, -1):
					if point_on_path(balloons[j].distance).distance_to(target_pos) <= explosion_radius:
						damage_balloon(j, p.damage, str(p.get("damage_type", "physical")), int(p.get("owner", -1)))
				explosion_effects.append({"position": target_pos, "radius": explosion_radius, "time": 0.32})
				game_sound.play_explosion_effect()
			else:
				damage_balloon(p.target, p.damage, str(p.get("damage_type", "physical")), int(p.get("owner", -1)))
			projectiles.remove_at(i)

func damage_balloon(index: int, damage: int, damage_type := "physical", owner_index := -1) -> void:
	if index < 0 or index >= balloons.size():
		return
	if balloons[index].get("camouflaged", false) and not tower_has_thermal_vision(owner_index):
		return
	if balloons[index].get("regenerative", false):
		balloons[index].regen_since_hit = 0.0
		balloons[index].regen_tick = 0.0
	if balloons[index].get("moab", false):
		var old_moab_hp: int = int(balloons[index].moab_hp)
		var new_moab_hp: int = max(0, old_moab_hp - damage)
		balloons[index].moab_hp = new_moab_hp
		balloons[index].hp = new_moab_hp
		record_tower_damage(owner_index, old_moab_hp - new_moab_hp, new_moab_hp <= 0)
		var new_moab_stage: int = 1 if new_moab_hp <= 80 else 0
		if new_moab_hp <= 40:
			new_moab_stage = 2
		if new_moab_hp <= 0:
			new_moab_stage = 3
		if new_moab_stage > int(balloons[index].moab_stage):
			game_sound.play_effect("balloon_break", -7.0)
			balloons[index].moab_stage = new_moab_stage
		if new_moab_hp <= 0:
			destroy_moab(index)
		return
	if balloons[index].get("armored", false):
		if damage_type == "magic":
			record_tower_damage(owner_index, int(balloons[index].armor_hp), true)
			destroy_armored_balloon(index)
			return
		record_tower_damage(owner_index, mini(damage, int(balloons[index].armor_hp)), balloons[index].armor_hp <= damage)
		balloons[index].armor_hp -= damage
		balloons[index].hp = balloons[index].armor_hp
		game_sound.play_effect("metal", -10.0)
		if balloons[index].armor_hp <= 0:
			destroy_armored_balloon(index)
		return
	if balloons[index].get("magic_shield", false):
		if damage_type == "physical":
			record_tower_damage(owner_index, int(balloons[index].shield_hp), true)
			destroy_magic_shield_balloon(index)
			return
		record_tower_damage(owner_index, mini(damage, int(balloons[index].shield_hp)), balloons[index].shield_hp <= damage)
		balloons[index].shield_hp -= damage
		balloons[index].hp = balloons[index].shield_hp
		game_sound.play_effect("saber", -12.0)
		if balloons[index].shield_hp <= 0:
			destroy_magic_shield_balloon(index)
		return
	if balloons[index].get("ceramic_shell", false):
		var old_shell_hp: int = int(balloons[index].shell_hp)
		var new_shell_hp: int = max(0, old_shell_hp - damage)
		balloons[index].shell_hp = new_shell_hp
		balloons[index].hp = new_shell_hp
		record_tower_damage(owner_index, old_shell_hp - new_shell_hp, false)
		game_sound.play_effect("ceramic_hit", -12.0)
		var new_stage: int = 1 if new_shell_hp <= 8 else 0
		if new_shell_hp <= 3:
			new_stage = 2
		if new_shell_hp <= 0:
			new_stage = 3
		if new_stage > int(balloons[index].shell_stage):
			game_sound.play_effect("ceramic_break", -8.0)
			balloons[index].shell_stage = new_stage
		if new_shell_hp <= 0:
			balloons[index].ceramic_shell = false
			balloons[index].tier = 9
			balloons[index].hp = 9
			balloons[index].max_hp = 9
			balloons[index].speed = balloons[index].base_speed + 63.0 * BALLOON_SPEED_SCALE
		return
	game_sound.play_effect("impact", -15.0)
	record_tower_damage(owner_index, mini(damage, int(balloons[index].tier)), balloons[index].tier <= damage)
	# Each health layer is one balloon tier: damage removes that many layers.
	balloons[index].tier -= damage
	if balloons[index].tier > 0:
		balloons[index].max_hp = balloons[index].tier
		balloons[index].hp = balloons[index].tier
		if not balloons[index].get("moab", false):
			balloons[index].speed = balloons[index].base_speed + balloons[index].tier * 7.0 * BALLOON_SPEED_SCALE
		return
	var destroyed_distance: float = balloons[index].distance
	var was_camouflaged: bool = balloons[index].get("camouflaged", false)
	var was_regenerative: bool = balloons[index].get("regenerative", false)
	var splits_into_two: bool = balloons[index].get("split_on_destroy", false)
	var split_level: int = int(balloons[index].get("split_level", 5))
	var split_tiers: Array = balloons[index].get("split_tiers", [])
	balloons.remove_at(index)
	if splits_into_two:
		if split_tiers.is_empty():
			spawn_balloon_of_tier(split_level, destroyed_distance - 12.0, was_camouflaged, was_regenerative)
			spawn_balloon_of_tier(split_level, destroyed_distance + 12.0, was_camouflaged, was_regenerative)
		else:
			for split_index in range(split_tiers.size()):
				spawn_balloon_of_tier(int(split_tiers[split_index]), destroyed_distance + (split_index - 2.5) * 16.0, was_camouflaged, was_regenerative)
	for other in projectiles:
		if other.target > index:
			other.target -= 1

func record_tower_damage(owner_index: int, amount: int, destroyed: bool) -> void:
	if owner_index < 0 or owner_index >= towers.size():
		return
	towers[owner_index].damage_dealt = int(towers[owner_index].get("damage_dealt", 0)) + amount
	if destroyed:
		towers[owner_index].bloons_popped = int(towers[owner_index].get("bloons_popped", 0)) + 1

func tower_has_thermal_vision(owner_index: int) -> bool:
	return owner_index >= 0 and owner_index < towers.size() and bool(towers[owner_index].get("thermal_vision", false))

func destroy_armored_balloon(index: int) -> void:
	if index < 0 or index >= balloons.size():
		return
	var destroyed_distance: float = balloons[index].distance
	var was_camouflaged: bool = balloons[index].get("camouflaged", false)
	var was_regenerative: bool = balloons[index].get("regenerative", false)
	balloons.remove_at(index)
	for other in projectiles:
		if other.target > index:
			other.target -= 1
	for split_index in range(3):
		spawn_balloon_of_tier(7, destroyed_distance + (split_index - 1) * 18.0, was_camouflaged, was_regenerative)

func destroy_magic_shield_balloon(index: int) -> void:
	if index < 0 or index >= balloons.size():
		return
	var destroyed_distance: float = balloons[index].distance
	var was_camouflaged: bool = balloons[index].get("camouflaged", false)
	var was_regenerative: bool = balloons[index].get("regenerative", false)
	balloons.remove_at(index)
	for other in projectiles:
		if other.target > index:
			other.target -= 1
	for split_index in range(3):
		spawn_balloon_of_tier(7, destroyed_distance + (split_index - 1) * 18.0, was_camouflaged, was_regenerative)

func destroy_moab(index: int) -> void:
	if index < 0 or index >= balloons.size():
		return
	var destroyed_distance: float = balloons[index].distance
	var was_camouflaged: bool = balloons[index].get("camouflaged", false)
	var was_regenerative: bool = balloons[index].get("regenerative", false)
	balloons.remove_at(index)
	for other in projectiles:
		if other.target > index:
			other.target -= 1
	for split_index in range(6):
		spawn_ceramic_nine_balloon(destroyed_distance + (split_index - 2.5) * 18.0, was_camouflaged, was_regenerative)
	for split_index in range(2):
		spawn_armored_balloon(destroyed_distance + (split_index + 4) * 20.0, was_camouflaged, was_regenerative)
		spawn_magic_shield_balloon(destroyed_distance - (split_index + 4) * 20.0, was_camouflaged, was_regenerative)

func point_on_path(distance: float) -> Vector2:
	var remaining := distance
	for i in range(path_lengths.size()):
		if remaining <= path_lengths[i]:
			return path[i].lerp(path[i + 1], remaining / path_lengths[i])
		remaining -= path_lengths[i]
	return path[path.size() - 1]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and game_sound:
		game_sound.play_effect("click", -14.0)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and (online_mode or solo_modern_mode):
		if debug_spawn_kind >= 0:
			debug_spawn_kind = -1
		elif placement_tower >= 0:
			placement_tower = -1
		else:
			inspected_tower_index = -1
		queue_redraw()
		return
	if event is InputEventMouseMotion:
		cursor_position = event.position
		if online_mode or solo_modern_mode:
			hover_tower = tower_button_at(cursor_position)
			debug_hover_balloon = debug_balloon_button_at(cursor_position)
			hover_upgrade_branch = -1
			if inspected_tower_index >= 0 and inspected_tower_index < towers.size():
				for branch in range(3):
					if inspected_upgrade_rect(branch).has_point(cursor_position):
						hover_upgrade_branch = branch
		queue_redraw()
	if event is InputEventMouseButton and event.pressed and online_mode and active_duel_tab == 1:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			balloon_scroll_row = max(0, balloon_scroll_row - 1)
			queue_redraw()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var rows := ceili(float(send_options().size()) / 3.0)
			balloon_scroll_row = mini(int(rows) - 2, balloon_scroll_row + 1)
			queue_redraw()
			return
	if event is InputEventMouseButton and event.pressed and online_mode and debug_mode and debug_panel_open and debug_tab == 1 and Rect2(1435, 345, 380, 345).has_point(event.position):
		var debug_rows: int = int(ceili(float(debug_balloon_options().size()) / 3.0))
		var max_debug_scroll: int = max(0, debug_rows - 4)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			debug_balloon_scroll_row = max(0, debug_balloon_scroll_row - 1)
			queue_redraw()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			debug_balloon_scroll_row = mini(max_debug_scroll, debug_balloon_scroll_row + 1)
			queue_redraw()
			return
	if event is InputEventMouseButton and event.pressed and solo_modern_mode and debug_mode and debug_panel_open and debug_tab == 1 and Rect2(205, 920, 920, 125).has_point(event.position):
		var solo_debug_rows: int = int(ceili(float(debug_balloon_options().size()) / 6.0))
		var solo_max_scroll: int = max(0, solo_debug_rows - 2)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			debug_balloon_scroll_row = max(0, debug_balloon_scroll_row - 1)
			queue_redraw()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			debug_balloon_scroll_row = mini(solo_max_scroll, debug_balloon_scroll_row + 1)
			queue_redraw()
			return
	if not mode_selected:
		if vs_intro_time > 0.0:
			return
		if profile_menu_open:
			handle_profile_input(event)
			return
		if sound_menu_open:
			handle_sound_menu_input(event)
			return
		if menu_music_select:
			handle_menu_music_input(event)
			return
		if map_select:
			handle_map_select_input(event)
			return
		if loadout_select:
			handle_loadout_input(event)
			return
		if online_lobby:
			handle_lobby_input(event)
			return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var menu_position: Vector2 = event.position / 1.5
			if profile_button_rect().has_point(menu_position):
				open_profile_menu()
			elif Rect2(250, 330, 230, 190).has_point(menu_position):
				solo_modern_mode = true
				multiplayer_mode = false
				open_map_select(false)
			elif Rect2(525, 330, 230, 190).has_point(menu_position):
				solo_modern_mode = false
				open_map_select(false)
				multiplayer_mode = true
			elif Rect2(800, 330, 230, 190).has_point(menu_position):
				online_lobby = true
			elif Rect2(390, 650, 240, 52).has_point(menu_position):
				menu_music_select = true
			elif Rect2(650, 650, 240, 52).has_point(menu_position):
				sound_menu_open = true
			queue_redraw()
		return
	if event is InputEventKey and event.pressed and (online_mode or solo_modern_mode) and editing_field == "debug_wave":
		if event.keycode == KEY_BACKSPACE:
			debug_wave_input = debug_wave_input.left(-1)
		elif event.ctrl_pressed and event.keycode == KEY_V:
			for character in DisplayServer.clipboard_get():
				if character.is_valid_int() and debug_wave_input.length() < 2:
					debug_wave_input += character
		elif event.unicode > 0:
			var typed_debug := char(event.unicode)
			if typed_debug.is_valid_int() and debug_wave_input.length() < 2:
				debug_wave_input += typed_debug
		queue_redraw()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE and (online_mode or solo_modern_mode):
			surrender_prompt = not surrender_prompt
			return
		# Atajos de las tres ramas mostradas en el panel de la torre seleccionada.
		# No se aplican mientras se edita el campo de oleada (gestionado arriba).
		if (online_mode or solo_modern_mode) and inspected_tower_index >= 0 and inspected_tower_index < towers.size():
			var upgrade_branch := -1
			if event.keycode == KEY_COMMA:
				upgrade_branch = 0
			elif event.keycode == KEY_PERIOD:
				upgrade_branch = 1
			elif event.keycode == KEY_MINUS:
				upgrade_branch = 2
			if upgrade_branch >= 0:
				upgrade_inspected_tower(upgrade_branch)
				queue_redraw()
				return
		if (online_mode or (mode_selected and not multiplayer_mode)) and event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var tower_slot: int = int(event.keycode - KEY_1)
			var available_towers := match_towers()
			if tower_slot < available_towers.size():
				active_duel_tab = 0
				placement_tower = available_towers[tower_slot]
				selected_tower = available_towers[tower_slot]
				queue_redraw()
		elif event.keycode == KEY_1:
			selected_tower = 0
		elif event.keycode == KEY_2:
			selected_tower = 1
		if event.keycode == KEY_SPACE and not online_mode: start_wave()
		if (game_over or won) and event.keycode == KEY_R: get_tree().reload_current_scene()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse: Vector2 = event.position
		if game_over or won:
			get_tree().reload_current_scene()
			return
		if online_mode or solo_modern_mode:
			if debug_button_rect().has_point(mouse):
				set_requested_debug_mode()
				return
			if debug_mode and debug_panel_open:
				if solo_modern_mode and handle_solo_debug_input(mouse):
					return
				var debug_mouse := mouse
				if Rect2(1440, 305, 180, 35).has_point(debug_mouse):
					debug_tab = 0
					debug_spawn_kind = -1
					debug_balloon_scroll_row = 0
					return
				if Rect2(1630, 305, 180, 35).has_point(debug_mouse):
					debug_tab = 1
					debug_balloon_scroll_row = 0
					return
				if debug_tab == 1:
					var debug_option := debug_balloon_button_at(debug_mouse)
					if debug_option >= 0:
						debug_spawn_kind = int(debug_balloon_options()[debug_option].kind)
						return
					if Rect2(1460, 700, 155, 42).has_point(debug_mouse):
						debug_spawn_camouflaged = not debug_spawn_camouflaged
						return
					if Rect2(1630, 700, 155, 42).has_point(debug_mouse):
						debug_spawn_regenerative = not debug_spawn_regenerative
						return
				if debug_tab == 0 and Rect2(1460, 355, 180, 50).has_point(debug_mouse):
					request_debug_pause_toggle()
					return
				if debug_tab == 0 and Rect2(1460, 425, 130, 50).has_point(debug_mouse):
					editing_field = "debug_wave"
					return
				if debug_tab == 0 and Rect2(1605, 425, 160, 50).has_point(debug_mouse):
					request_debug_wave(debug_wave_input.to_int())
					return
				if debug_tab == 0 and Rect2(1460, 495, 145, 50).has_point(debug_mouse):
					grant_debug_money()
					return
				if debug_tab == 0 and Rect2(1620, 495, 145, 50).has_point(debug_mouse):
					toggle_debug_invulnerability()
					return
				if pending_debug_wave >= 0:
					if Rect2(1460, 475, 140, 50).has_point(mouse):
						respond_debug_wave(true)
						return
					if Rect2(1615, 475, 150, 50).has_point(mouse):
						respond_debug_wave(false)
						return
			var online_speed_origin := Vector2(1740, 215)
			var online_speed_option := speed_option_at(mouse, online_speed_origin, 120.0, 38.0) if speed_menu_open else -1
			if online_speed_option >= 0:
				set_requested_game_speed(GAME_SPEEDS[online_speed_option])
				speed_menu_open = false
				return
			if Rect2(online_speed_origin, Vector2(120, 38)).has_point(mouse):
				speed_menu_open = not speed_menu_open
				return
			if speed_menu_open:
				speed_menu_open = false
			if Rect2(22, 790, 210, 52).has_point(mouse):
				active_duel_tab = 0
				queue_redraw()
				return
			if online_mode and Rect2(242, 790, 210, 52).has_point(mouse):
				active_duel_tab = 1
				queue_redraw()
				return
			if online_mode and active_duel_tab == 1:
				var send_option := balloon_send_button_at(mouse)
				if send_option >= 0:
					send_balloon_to_rival(send_option)
					return
			if inspected_tower_index >= 0:
				var menu_offset := inspected_menu_offset()
				var inspected_type: int = int(towers[inspected_tower_index].type) if inspected_tower_index < towers.size() else -1
				var can_choose_target := inspected_type != 5 and inspected_type != 6 and inspected_type != 8
				if can_choose_target and Rect2(Vector2(1195, 840) + menu_offset, Vector2(42, 36)).has_point(mouse):
					change_inspected_target_mode(-1)
					return
				if can_choose_target and Rect2(Vector2(1405, 840) + menu_offset, Vector2(42, 36)).has_point(mouse):
					change_inspected_target_mode(1)
					return
				if Rect2(Vector2(1300, 965) + menu_offset, Vector2(145, 58)).has_point(mouse):
					sell_inspected_tower()
					return
				if Rect2(Vector2(995, 905) + menu_offset, Vector2(450, 55)).has_point(mouse):
					upgrade_inspected_tower(clampi(int((mouse.x - 995.0 - menu_offset.x) / 150.0), 0, 2))
					return
				if Rect2(Vector2(1455, 790) + menu_offset, Vector2(55, 42)).has_point(mouse):
					inspected_tower_index = -1
					return
			if online_mode and surrender_prompt:
				if Rect2(820, 575, 130, 62).has_point(mouse):
					game_over = true
					rpc_report_defeat.rpc()
				if Rect2(970, 575, 180, 62).has_point(mouse):
					surrender_prompt = false
				return
			if online_mode and Rect2(1640, 850, 230, 62).has_point(mouse):
				surrender_prompt = true
				return
			if not online_mode or active_duel_tab == 0:
				var ability_kind := tower_ability_button_at(mouse)
				if ability_kind >= 0:
					activate_tower_ability(ability_kind)
					return
			var button_kind := tower_button_at(mouse)
			if button_kind >= 0:
				if money < TOWER_COSTS[button_kind]:
					game_sound.play_error_effect()
					return
				placement_tower = button_kind
				selected_tower = button_kind
				return
			var arena_rect := local_arena_rect()
			if arena_rect.has_point(mouse):
				var duel_position := (mouse - local_arena_origin()) / local_arena_scale()
				if debug_spawn_kind >= 0:
					var spawn_distance := debug_path_distance(duel_position)
					if spawn_distance >= 0.0:
						place_debug_balloon(spawn_distance)
					else:
						debug_spawn_kind = -1
					return
				if placement_tower >= 0:
					if can_place_tower(duel_position, placement_tower):
						place_tower(duel_position)
					else:
						placement_tower = -1
						game_sound.play_error_effect()
					return
				if collect_banana_at(duel_position):
					return
				var placed_index := tower_at_position(duel_position)
				if placed_index >= 0:
					inspected_tower_index = placed_index
					return
				if inspected_tower_index >= 0:
					inspected_tower_index = -1
					return
			if debug_spawn_kind >= 0:
				debug_spawn_kind = -1
			elif placement_tower >= 0:
				placement_tower = -1
			elif inspected_tower_index >= 0:
				inspected_tower_index = -1
			return
		var speed_origin := Vector2(18, 250)
		var speed_option := speed_option_at(mouse, speed_origin, 210.0, 52.0) if speed_menu_open else -1
		if speed_option >= 0:
			set_requested_game_speed(GAME_SPEEDS[speed_option])
			speed_menu_open = false
			return
		if Rect2(speed_origin, Vector2(210, 52)).has_point(mouse):
			speed_menu_open = not speed_menu_open
			return
		if speed_menu_open:
			speed_menu_open = false
		var solo_towers := match_towers()
		for slot in range(solo_towers.size()):
			if Rect2(18, 350 + slot * 76, 210, 68).has_point(mouse):
				selected_tower = solo_towers[slot]
				placement_tower = selected_tower
				return
		if multiplayer_mode and Rect2(18, 675, 210, 64).has_point(mouse):
			start_wave()
			return
		if Rect2(248, 0, WIDTH - 248, HEIGHT).has_point(mouse):
			var solo_position := mouse / 1.5
			if collect_banana_at(solo_position):
				return
			place_tower(solo_position)

func place_tower(position: Vector2) -> bool:
	if online_mode:
		var before_count := towers.size()
		place_tower_local(position, selected_tower)
		if towers.size() > before_count:
			rpc_place_rival_tower.rpc(position, selected_tower)
			inspected_tower_index = towers.size() - 1
			placement_tower = -1
			return true
		return false
	var previous_count := towers.size()
	place_tower_local(position, selected_tower)
	if towers.size() > previous_count:
		inspected_tower_index = towers.size() - 1
		placement_tower = -1
	return towers.size() > previous_count

func place_tower_local(position: Vector2, tower_kind: int) -> void:
	if not can_place_tower(position, tower_kind):
		game_sound.play_error_effect()
		return
	money -= TOWER_COSTS[tower_kind]
	game_sound.play_effect("place")
	money_popup_amount = TOWER_COSTS[tower_kind]
	money_popup_time = 1.0
	var config := tower_config(tower_kind)
	towers.append({
		"position": position, "range": config.range,
		"damage": config.damage, "damage_type": config.damage_type,
		"reload": config.reload, "action_rate": 1.0 / (8.0 if tower_kind == 5 else config.reload) if (tower_kind == 5 or config.reload > 0.0) else 0.0,
		"projectile_speed": config.projectile_speed,
		"projectile_range": config.projectile_range, "thermal_vision": config.thermal_vision,
		"cooldown": 0.0, "banana_timer": 0.0, "target_mode": 0, "target_modes": [0, 0, 0, 0, 0], "primary_branch": -1, "secondary_branch": -1, "branch_levels": [0, 0, 0], "pierce": 0, "dart_scale": 1.0, "burst": 1, "sources": 1, "overdrive_time": 0.0, "banana_value": 30, "banana_interval": 8.0, "heal_amount": 8, "chain_hits": 5, "explosion_radius": 68.0, "spike_count": 4, "damage_dealt": 0, "bloons_popped": 0, "effective_healing": 0, "banana_money_collected": 0, "color": TOWER_COLORS[tower_kind], "type": tower_kind, "cost": TOWER_COSTS[tower_kind]
	})
	if multiplayer_mode:
		active_player = 2 if active_player == 1 else 1

func can_place_tower(position: Vector2, tower_kind: int) -> bool:
	return PLAY_RECT.has_point(position) and money >= TOWER_COSTS[tower_kind] and not too_close_to_path(position) and not too_close_to_tower(position) and can_build_on_active_map(position, tower_kind)

func is_aquatic_tower(tower_kind: int) -> bool:
	return tower_kind == 6

func coral_shore_x(y: float) -> float:
	var shore := PackedVector2Array([Vector2(232, 0), Vector2(250, 65), Vector2(255, 183), Vector2(217, 253), Vector2(241, 310), Vector2(275, 382), Vector2(247, 438), Vector2(210, 507), Vector2(238, 577), Vector2(267, 650), Vector2(228, 720)])
	for index in range(shore.size() - 1):
		if y >= shore[index].y and y <= shore[index + 1].y:
			return lerpf(shore[index].x, shore[index + 1].x, inverse_lerp(shore[index].y, shore[index + 1].y, y))
	return shore[shore.size() - 1].x

func is_water_on_active_map(position: Vector2) -> bool:
	if active_map == 0:
		return position.x < coral_shore_x(position.y)
	if active_map == 2:
		return position.x < 120.0 or position.x > 1120.0
	return false

func can_build_on_active_map(position: Vector2, tower_kind: int) -> bool:
	if is_water_on_active_map(position) and not is_aquatic_tower(tower_kind):
		return false
	if active_map != 3:
		return true
	# Ruinas Celestes: only the three bright cloud-islands are solid ground.
	var cloud_a := Vector2(210, 220)
	var cloud_b := Vector2(1035, 520)
	var cloud_c := Vector2(560, 600)
	var in_cloud_a := pow((position.x - cloud_a.x) / 145.0, 2.0) + pow((position.y - cloud_a.y) / 105.0, 2.0) <= 1.0
	var in_cloud_b := pow((position.x - cloud_b.x) / 170.0, 2.0) + pow((position.y - cloud_b.y) / 115.0, 2.0) <= 1.0
	var in_cloud_c := pow((position.x - cloud_c.x) / 145.0, 2.0) + pow((position.y - cloud_c.y) / 100.0, 2.0) <= 1.0
	return in_cloud_a or in_cloud_b or in_cloud_c

func collect_banana_at(position: Vector2) -> bool:
	for i in range(bananas.size() - 1, -1, -1):
		if bananas[i].position.distance_to(position) <= 34.0:
			collect_banana_index(i)
			return true
	return false

func collect_banana_index(index: int) -> void:
	if index < 0 or index >= bananas.size():
		return
	money += bananas[index].value
	var owner_index: int = int(bananas[index].get("owner", -1))
	if owner_index >= 0 and owner_index < towers.size() and int(towers[owner_index].get("type", -1)) == 5:
		towers[owner_index].banana_money_collected = int(towers[owner_index].get("banana_money_collected", 0)) + int(bananas[index].value)
	banana_popup_position = bananas[index].position
	banana_popup_value = bananas[index].value
	banana_popup_time = 0.85
	bananas.remove_at(index)
	game_sound.play_effect("click", -10.0)

func tower_button_at(position: Vector2) -> int:
	var available := match_towers()
	for index in range(available.size()):
		if tower_button_rect(index).has_point(position):
			return available[index]
	return -1

func tower_ability_button_at(position: Vector2) -> int:
	var available := match_towers()
	for index in range(available.size()):
		if tower_ability_rect(index).has_point(position):
			return available[index]
	return -1

func tower_ability_rect(slot: int) -> Rect2:
	var tower_rect := tower_button_rect(slot)
	return Rect2(tower_rect.position + Vector2(0, tower_rect.size.y + 7), Vector2(tower_rect.size.x, 42))

func update_tower_ability_cooldowns(delta: float) -> void:
	if tower_ability_notice_time > 0.0:
		tower_ability_notice_time = maxf(0.0, tower_ability_notice_time - delta)
	for kind_variant in tower_ability_cooldowns.keys():
		var kind: int = int(kind_variant)
		tower_ability_cooldowns[kind] = maxf(0.0, float(tower_ability_cooldowns[kind]) - delta)

func activate_tower_ability(kind: int) -> void:
	var ability: Dictionary = TowerCatalogScript.ability_data(kind)
	var remaining: float = float(tower_ability_cooldowns.get(kind, 0.0))
	if remaining > 0.0:
		game_sound.play_error_effect()
		return
	var cooldown: float = float(ability.cooldown)
	if kind == 0:
		for tower in towers:
			if int(tower.get("type", -1)) == 0 and int(tower.get("branch_levels", [0, 0, 0])[0]) >= 4:
				cooldown = float(tower.get("ability_cooldown", 40.0))
				break
	tower_ability_cooldowns[kind] = cooldown
	tower_ability_notice = "%s activada" % str(ability.name)
	tower_ability_notice_time = 1.7
	# Punto de extensión: las futuras habilidades añaden aquí su efecto real.
	execute_tower_ability(kind)

func execute_tower_ability(_kind: int) -> void:
	if _kind != 0:
		return
	for tower_index in range(towers.size()):
		var tower: Dictionary = towers[tower_index]
		if int(tower.get("type", -1)) != 0 or int(tower.get("branch_levels", [0, 0, 0])[0]) < 4:
			continue
		if tower.get("dart_giant", false):
			tower.overdrive_time = 5.0
			return
		var target := choose_tower_target(tower)
		if target < 0:
			return
		var direction: Vector2 = (point_on_path(balloons[target].distance) - tower.position).normalized()
		projectiles.append({"id": next_projectile_id, "owner":tower_index, "position":tower.position, "target":target, "target_position":point_on_path(balloons[target].distance), "damage":5, "damage_type":"physical", "speed":430.0, "color":Color("f4d66d"), "direction":direction, "kind":0, "remaining":600.0, "hit_ids":[], "pierce":999, "scale":3.0})
		next_projectile_id += 1
		return

func match_towers() -> Array[int]:
	var available: Array[int] = chosen_towers.duplicate()
	if random_tower >= 0:
		available.append(random_tower)
	return available

func tower_config(kind: int) -> Dictionary:
	return TowerCatalogScript.config(kind)

func tower_button_rect(kind: int) -> Rect2:
	if solo_modern_mode:
		return Rect2(1200 + (kind % 2) * 200, 280 + (kind / 2) * 210, 190, 155)
	return Rect2(22 + kind * 210, 850, 195, 150)

func inspected_menu_offset() -> Vector2:
	return Vector2(210, -110) if solo_modern_mode else Vector2.ZERO

func debug_button_rect() -> Rect2:
	return Rect2(20, 850, 170, 58) if solo_modern_mode else Rect2(1600, 215, 120, 38)

func inspected_upgrade_rect(branch: int) -> Rect2:
	return Rect2(Vector2(995 + branch * 150, 905) + inspected_menu_offset(), Vector2(145, 55))

func local_arena_origin() -> Vector2:
	return SOLO_ARENA_ORIGIN if solo_modern_mode else Vector2(0, 270)

func local_arena_scale() -> Vector2:
	return SOLO_ARENA_SCALE if solo_modern_mode else Vector2(0.75, 0.75)

func local_arena_rect() -> Rect2:
	var scale := local_arena_scale()
	return Rect2(local_arena_origin(), Vector2(1280.0 * scale.x, 720.0 * scale.y))

func balloon_send_button_at(position: Vector2) -> int:
	for option_index in range(send_options().size()):
		if balloon_send_rect(option_index).has_point(position):
			return option_index
	return -1

func send_options() -> Array[Dictionary]:
	return [
		{"tier": 1, "count": 1, "cost": 40, "benefit": 1, "unlock": 0, "label": "Explorador"},
		{"tier": 2, "count": 1, "cost": 65, "benefit": 2, "unlock": 3, "label": "Doble"},
		{"tier": 3, "count": 1, "cost": 110, "benefit": 3, "unlock": 6, "label": "Pesado"},
		{"tier": 3, "count": 3, "cost": 90, "benefit": 4, "unlock": 9, "label": "Trío veloz"},
		{"tier": 5, "count": 2, "cost": 140, "benefit": 6, "unlock": 14, "label": "Dúo élite"},
		{"tier": 4, "count": 4, "cost": 210, "benefit": 8, "unlock": 18, "label": "Escuadrón"},
		{"tier": 12, "count": 1, "cost": 620, "benefit": -35, "unlock": 38, "label": "MOAB", "moab": true},
		{"tier": 6, "count": 1, "cost": 240, "benefit": 10, "unlock": 20, "label": "Divisor"},
		{"tier": 7, "count": 1, "cost": 290, "benefit": 12, "unlock": 24, "label": "Relámpago"},
		{"tier": 8, "count": 1, "cost": 340, "benefit": 15, "unlock": 26, "label": "Doble 7"},
		{"tier": 9, "count": 1, "cost": 520, "benefit": 22, "unlock": 30, "label": "Fiesta feliz"},
		{"tier": 9, "count": 1, "cost": 540, "benefit": 23, "unlock": 32, "label": "Coraza", "ceramic": true},
		{"tier": 8, "count": 1, "cost": 460, "benefit": 18, "unlock": 27, "label": "Blindado", "armored": true},
		{"tier": 8, "count": 1, "cost": 470, "benefit": 18, "unlock": 29, "label": "Escudo mágico", "magic_shield": true}
	]

func balloon_send_rect(option_index: int) -> Rect2:
	return Rect2(22 + (option_index % 3) * 230, 850 + (option_index / 3 - balloon_scroll_row) * 108, 215, 98)

func tower_at_position(position: Vector2) -> int:
	for index in range(towers.size() - 1, -1, -1):
		if towers[index].position.distance_to(position) <= 42.0:
			return index
	return -1

func sell_inspected_tower() -> void:
	if inspected_tower_index < 0 or inspected_tower_index >= towers.size():
		inspected_tower_index = -1
		return
	var refund: int = int(round(float(towers[inspected_tower_index].get("cost", 0)) * 0.6))
	money += refund
	towers.remove_at(inspected_tower_index)
	inspected_tower_index = -1
	game_sound.play_money_effect()

func upgrade_inspected_tower(branch: int) -> void:
	if inspected_tower_index < 0 or inspected_tower_index >= towers.size():
		return
	if branch < 0 or branch >= 3:
		return
	var tower: Dictionary = towers[inspected_tower_index]
	var primary: int = int(tower.get("primary_branch", -1))
	var secondary: int = int(tower.get("secondary_branch", -1))
	var levels: Array = tower.get("branch_levels", []).duplicate()
	while levels.size() < 3:
		levels.append(0)
	if levels.size() > 3:
		levels.resize(3)
	tower.branch_levels = levels
	var level: int = int(levels[branch])
	var used_branches := 0
	for branch_level in levels:
		if int(branch_level) > 0:
			used_branches += 1
	# Before a main branch exists, either of two branches can be explored.
	# The third is blocked only once two different paths have upgrades.
	if level == 0 and used_branches >= 2:
		return
	if primary >= 0 and branch != primary:
		if secondary >= 0 and branch != secondary:
			return
		if secondary < 0:
			secondary = branch
			tower.secondary_branch = branch
	var max_level: int = 5 if branch == primary else 3 if primary < 0 else 2
	if level >= max_level:
		return
	var branches: Array = TowerCatalogScript.upgrade_branches(int(tower.type))
	if branch >= branches.size() or not branches[branch].has("levels"):
		return
	var branch_upgrades: Array = branches[branch].levels
	if level < 0 or level >= branch_upgrades.size():
		return
	var upgrade: Dictionary = branch_upgrades[level]
	var ultimate_key := "%d_%d" % [int(tower.type), branch]
	if bool(upgrade.get("final", false)) and ultimate_tower_types.has(ultimate_key):
		return
	var cost: int = int(upgrade.get("cost", 0))
	if money < cost:
		game_sound.play_error_effect()
		return
	money -= cost
	money_popup_amount = cost
	money_popup_time = 1.0
	levels[branch] = level + 1
	tower.branch_levels = levels
	# The first branch reaching its third upgrade becomes the main path; the
	# other explored path remains available only through its second upgrade.
	if primary < 0 and int(levels[branch]) >= 3:
		tower.primary_branch = branch
		for other_branch in range(3):
			if other_branch != branch and int(levels[other_branch]) > 0:
				tower.secondary_branch = other_branch
				break
	tower.cost = int(tower.get("cost", 0)) + cost
	tower.damage += int(upgrade.get("damage", 0))
	tower.range += float(upgrade.get("range", 0.0))
	tower.projectile_range += float(upgrade.get("projectile_range", 0.0))
	tower.explosion_radius = float(tower.get("explosion_radius", 68.0)) + float(upgrade.get("explosion", 0.0))
	tower.chain_hits = int(tower.get("chain_hits", 5)) + int(upgrade.get("chain", 0))
	tower.banana_value = int(tower.get("banana_value", 30)) + int(upgrade.get("banana_value", 0))
	var previous_banana_interval: float = float(tower.get("banana_interval", 8.0))
	tower.banana_interval = maxf(2.0, previous_banana_interval + float(upgrade.get("banana_interval", 0.0)))
	if int(tower.type) == 5 and previous_banana_interval > 0.0:
		# Conserva el progreso proporcional del ciclo actual al acelerar la producción.
		tower.banana_timer = clampf(float(tower.get("banana_timer", 0.0)) * float(tower.banana_interval) / previous_banana_interval, 0.0, float(tower.banana_interval))
		tower.action_rate = 1.0 / float(tower.banana_interval)
	tower.heal_amount = int(tower.get("heal_amount", 8)) + int(upgrade.get("heal", 0))
	tower.spike_count = int(tower.get("spike_count", 4)) + int(upgrade.get("spike_count", 0))
	if upgrade.has("pierce"): tower.pierce = int(upgrade.pierce)
	if upgrade.has("dart_scale"): tower.dart_scale = float(upgrade.dart_scale)
	if upgrade.has("burst"): tower.burst = int(upgrade.burst)
	if upgrade.has("sources"): tower.sources = int(upgrade.sources)
	if upgrade.has("thermal_vision"): tower.thermal_vision = bool(upgrade.thermal_vision)
	if upgrade.has("projectile_speed_mult"): tower.projectile_speed *= float(upgrade.projectile_speed_mult)
	for feature in ["giant_ability", "dart_giant", "mecha", "fire", "split", "child_split", "homing", "kingdom", "ability_cooldown"]:
		if upgrade.has(feature): tower[feature] = upgrade[feature]
	if int(tower.type) != 5 and (upgrade.has("reload_mult") or upgrade.has("attack_rate_mult")):
		var previous_reload: float = float(tower.reload)
		var previous_rate: float = float(tower.get("action_rate", 1.0 / previous_reload if previous_reload > 0.0 else 0.0))
		var rate_multiplier: float = float(upgrade.get("attack_rate_mult", 1.0 / float(upgrade.get("reload_mult", 1.0))))
		tower.action_rate = previous_rate * rate_multiplier
		if float(tower.action_rate) > 0.0:
			tower.reload = 1.0 / float(tower.action_rate)
		# En la Médica, el ritmo es velocidad de casteo: el enfriamiento actual
		# también se acorta proporcionalmente para que la mejora tenga efecto inmediato.
		if int(tower.type) == 6 and previous_reload > 0.0:
			tower.cooldown *= float(tower.reload) / previous_reload
	var is_ultimate := bool(upgrade.get("final", false))
	if is_ultimate:
		ultimate_tower_types[ultimate_key] = true
	upgrade_effects.append({"position": tower.position, "time": 2.0 if is_ultimate else 0.9, "duration": 2.0 if is_ultimate else 0.9, "ultimate": is_ultimate, "color": TOWER_COLORS[int(tower.type)], "title": str(upgrade.name)})
	if is_ultimate:
		game_sound.play_ultimate_upgrade_effect()
	else:
		game_sound.play_upgrade_effect()

func update_upgrade_effects(delta: float) -> void:
	for index in range(upgrade_effects.size() - 1, -1, -1):
		upgrade_effects[index].time -= delta
		if upgrade_effects[index].time <= 0.0:
			upgrade_effects.remove_at(index)

func update_explosion_effects(delta: float) -> void:
	for index in range(explosion_effects.size() - 1, -1, -1):
		explosion_effects[index].time -= delta
		if explosion_effects[index].time <= 0.0:
			explosion_effects.remove_at(index)

func change_inspected_target_mode(direction: int) -> void:
	if inspected_tower_index < 0 or inspected_tower_index >= towers.size():
		return
	towers[inspected_tower_index].target_mode = posmod(int(towers[inspected_tower_index].get("target_mode", 0)) + direction, 4)
	game_sound.play_effect("click", -12.0)

func send_balloon_to_rival(option_index: int) -> void:
	var options := send_options()
	if option_index < 0 or option_index >= options.size():
		return
	var option: Dictionary = options[option_index]
	if send_cooldown > 0.0:
		game_sound.play_error_effect()
		return
	if wave < option.unlock or money < option.cost:
		game_sound.play_error_effect()
		return
	money -= option.cost
	money_popup_amount = option.cost
	money_popup_time = 1.0
	beneficios += option.benefit
	var weight: float = float(option.count * option.tier)
	if option.get("ceramic", false): weight += 10.0
	if option.get("armored", false) or option.get("magic_shield", false): weight += 13.0
	if option.get("moab", false): weight = 40.0
	send_cooldown = clampf(0.1 + weight * 0.0725, 0.1, 3.0)
	game_sound.play_effect("send")
	rpc_receive_sent_balloon.rpc(option.tier, option.count, option.get("moab", false), option.get("armored", false), option.get("magic_shield", false), option.get("ceramic", false))

@rpc("any_peer", "reliable")
func rpc_receive_sent_balloon(tier: int, count: int, is_moab := false, is_armored := false, is_magic_shield := false, is_ceramic := false) -> void:
	for i in range(clampi(count, 1, 5)):
		if is_moab:
			spawn_moab(-float(i) * 110.0)
		elif is_armored:
			spawn_armored_balloon(-float(i) * 100.0)
		elif is_magic_shield:
			spawn_magic_shield_balloon(-float(i) * 100.0)
		elif is_ceramic:
			spawn_ceramic_nine_balloon(-float(i) * 100.0)
		else:
			spawn_balloon_of_tier(clampi(tier, 1, 9), -float(i) * 70.0)

func set_requested_game_speed(new_speed: float) -> void:
	if not is_valid_game_speed(new_speed):
		return
	if online_mode:
		local_speed_vote = new_speed
		if multiplayer.is_server():
			rpc_show_rival_speed_vote.rpc(new_speed)
			try_apply_online_speed_vote()
		else:
			rpc_request_online_speed_vote.rpc_id(1, new_speed)
	else:
		gameplay_speed = new_speed

func is_valid_game_speed(speed: float) -> bool:
	for allowed_speed in GAME_SPEEDS:
		if is_equal_approx(speed, float(allowed_speed)):
			return true
	return false

func speed_label(speed: float) -> String:
	return "x%.2f" % speed if speed < 1.0 else "x%d" % int(speed)

@rpc("any_peer", "reliable")
func rpc_request_game_speed(new_speed: float) -> void:
	if multiplayer.is_server():
		rpc_set_game_speed.rpc(new_speed)

@rpc("any_peer", "reliable")
func rpc_request_online_speed_vote(target_vote: float) -> void:
	if multiplayer.is_server() and is_valid_game_speed(target_vote):
		rival_speed_vote = target_vote
		try_apply_online_speed_vote()

@rpc("any_peer", "reliable")
func rpc_show_rival_speed_vote(target_vote: float) -> void:
	if is_valid_game_speed(target_vote):
		rival_speed_vote = target_vote

func try_apply_online_speed_vote() -> void:
	if multiplayer.is_server() and local_speed_vote > 0.0 and is_equal_approx(local_speed_vote, rival_speed_vote):
		rpc_set_game_speed.rpc(local_speed_vote)

@rpc("any_peer", "call_local", "reliable")
func rpc_set_game_speed(new_speed: float) -> void:
	if is_valid_game_speed(new_speed):
		gameplay_speed = new_speed
	local_speed_vote = 0.0
	rival_speed_vote = 0.0

func set_requested_debug_mode() -> void:
	debug_panel_open = not debug_panel_open
	if debug_panel_open:
		# El panel individual no comparte estado temporal con una partida en línea.
		debug_tab = 0
		debug_balloon_scroll_row = 0
		debug_hover_balloon = -1
		debug_spawn_kind = -1
		editing_field = ""
	queue_redraw()

@rpc("any_peer", "reliable")
func rpc_request_debug_toggle(enabled: bool) -> void:
	if multiplayer.is_server():
		rpc_set_debug_mode.rpc(enabled)

@rpc("any_peer", "reliable")
func rpc_request_debug_vote(target_vote: int) -> void:
	if multiplayer.is_server():
		rival_debug_vote = clampi(target_vote, 1, 2)
		try_apply_debug_vote()

@rpc("any_peer", "reliable")
func rpc_show_rival_debug_vote(target_vote: int) -> void:
	rival_debug_vote = clampi(target_vote, 1, 2)

func try_apply_debug_vote() -> void:
	if multiplayer.is_server() and local_debug_vote > 0 and local_debug_vote == rival_debug_vote:
		rpc_set_debug_mode.rpc(local_debug_vote == 1)

@rpc("any_peer", "call_local", "reliable")
func rpc_set_debug_mode(enabled: bool) -> void:
	debug_mode = enabled
	debug_panel_open = enabled
	debug_paused = false
	if not enabled:
		debug_invulnerable = false
	local_debug_vote = 0
	rival_debug_vote = 0
	local_pause_vote = 0
	rival_pause_vote = 0
	debug_wave_input = ""
	editing_field = ""

func request_debug_pause_toggle() -> void:
	if not debug_mode:
		return
	if solo_modern_mode:
		rpc_set_debug_pause(not debug_paused)
		return
	if multiplayer.is_server():
		rpc_set_debug_pause.rpc(not debug_paused)
	else:
		rpc_request_debug_pause_toggle.rpc_id(1, not debug_paused)

@rpc("any_peer", "reliable")
func rpc_request_debug_pause_toggle(paused: bool) -> void:
	if multiplayer.is_server() and debug_mode:
		rpc_set_debug_pause.rpc(paused)

@rpc("any_peer", "reliable")
func rpc_request_pause_vote(target_vote: int) -> void:
	if multiplayer.is_server():
		rival_pause_vote = clampi(target_vote, 1, 2)
		try_apply_pause_vote()

@rpc("any_peer", "reliable")
func rpc_show_rival_pause_vote(target_vote: int) -> void:
	rival_pause_vote = clampi(target_vote, 1, 2)

func try_apply_pause_vote() -> void:
	if multiplayer.is_server() and local_pause_vote > 0 and local_pause_vote == rival_pause_vote:
		rpc_set_debug_pause.rpc(local_pause_vote == 1)

@rpc("any_peer", "call_local", "reliable")
func rpc_set_debug_pause(paused: bool) -> void:
	debug_paused = paused
	local_pause_vote = 0
	rival_pause_vote = 0
	if game_sound:
		game_sound.play_debug_effect("pause" if paused else "resume")

func grant_debug_money() -> void:
	if not debug_mode:
		return
	money += 10000
	if game_sound:
		game_sound.play_money_effect()

func toggle_debug_invulnerability() -> void:
	if not debug_mode:
		return
	debug_invulnerable = not debug_invulnerable
	if game_sound:
		game_sound.play_debug_effect("resume" if debug_invulnerable else "pause")

func debug_balloon_options() -> Array[Dictionary]:
	return [
		{"label":"Nivel 1", "kind":1, "tier":1, "speed":"Normal", "life":"1", "layers":"1", "leak":1, "waves":"1+"},
		{"label":"Nivel 2", "kind":2, "tier":2, "speed":"Normal+", "life":"2", "layers":"2", "leak":2, "waves":"3+"},
		{"label":"Nivel 3", "kind":3, "tier":3, "speed":"Media", "life":"3", "layers":"3", "leak":3, "waves":"4+"},
		{"label":"Nivel 4", "kind":4, "tier":4, "speed":"Media+", "life":"4", "layers":"4", "leak":4, "waves":"7+"},
		{"label":"Nivel 5", "kind":5, "tier":5, "speed":"Rápida", "life":"5", "layers":"5", "leak":5, "waves":"10+"},
		{"label":"Nivel 6", "kind":6, "tier":6, "speed":"Rápida", "life":"6", "layers":"6", "leak":6, "waves":"15+"},
		{"label":"Nivel 7", "kind":7, "tier":7, "speed":"Muy rápida", "life":"7", "layers":"7", "leak":7, "waves":"18+"},
		{"label":"Nivel 8", "kind":8, "tier":8, "speed":"Media", "life":"8", "layers":"8", "leak":8, "waves":"21+"},
		{"label":"Nivel 9", "kind":9, "tier":9, "speed":"Rápida", "life":"9", "layers":"9", "leak":9, "waves":"24+"},
		{"label":"Cerámica", "kind":95, "tier":9, "speed":"Nivel 9", "life":"13 + 9", "layers":"9,5", "leak":9, "waves":"28+"},
		{"label":"Blindado", "kind":81, "tier":8, "speed":"Nivel 2", "life":"32 físico", "layers":"Blindaje", "leak":18, "waves":"23+"},
		{"label":"Escudo mágico", "kind":82, "tier":8, "speed":"Nivel 2", "life":"32 mágico", "layers":"Escudo", "leak":18, "waves":"25+"},
		{"label":"MOAB", "kind":100, "tier":10, "speed":"Lenta", "life":"100", "layers":"Dirigible", "leak":140, "waves":"34+"}
	]

func debug_balloon_button_rect(index: int) -> Rect2:
	return Rect2(1445 + (index % 3) * 125, 365 + (index / 3 - debug_balloon_scroll_row) * 78, 115, 68)

func debug_balloon_color(option: Dictionary) -> Color:
	if int(option.get("kind", -1)) == 100:
		return Color("3f83ba")
	var color_index := clampi(int(option.get("tier", 1)), 0, TOWER_COLORS.size() - 1)
	return TOWER_COLORS[color_index]

func debug_balloon_button_at(position: Vector2) -> int:
	if not debug_mode or debug_tab != 1:
		return -1
	for index in range(debug_balloon_options().size()):
		var rect := debug_balloon_button_rect(index)
		if Rect2(1440, 350, 375, 335).intersects(rect) and rect.has_point(position):
			return index
	return -1

func debug_path_distance(position: Vector2) -> float:
	var total := 0.0
	var best_distance := INF
	var best_path_distance := 0.0
	for index in range(path.size() - 1):
		var point := Geometry2D.get_closest_point_to_segment(position, path[index], path[index + 1])
		var distance := point.distance_to(position)
		if distance < best_distance:
			best_distance = distance
			best_path_distance = total + path[index].distance_to(point)
		total += path[index].distance_to(path[index + 1])
	return best_path_distance if best_distance <= 30.0 else -1.0

func place_debug_balloon(path_distance: float) -> void:
	if debug_spawn_kind < 0 or path_distance < 0.0:
		return
	var regenerative := debug_spawn_regenerative and debug_spawn_kind != 100
	match debug_spawn_kind:
		95: spawn_ceramic_nine_balloon(path_distance, debug_spawn_camouflaged, regenerative)
		81: spawn_armored_balloon(path_distance, debug_spawn_camouflaged, regenerative)
		82: spawn_magic_shield_balloon(path_distance, debug_spawn_camouflaged, regenerative)
		100: spawn_moab(path_distance, debug_spawn_camouflaged, false)
		_: spawn_balloon_of_tier(debug_spawn_kind, path_distance, debug_spawn_camouflaged, regenerative)

func request_debug_wave(target_wave: int) -> void:
	if not debug_mode or target_wave < 1 or target_wave > 99:
		return
	if solo_modern_mode:
		rpc_apply_debug_wave(target_wave)
		return
	if multiplayer.is_server():
		rpc_apply_debug_wave.rpc(target_wave)
	else:
		rpc_request_direct_debug_wave.rpc_id(1, target_wave)

@rpc("any_peer", "reliable")
func rpc_request_direct_debug_wave(target_wave: int) -> void:
	if multiplayer.is_server() and debug_mode:
		rpc_apply_debug_wave.rpc(clampi(target_wave, 1, 99))

@rpc("any_peer", "reliable")
func rpc_request_debug_wave(target_wave: int) -> void:
	if multiplayer.is_server() and debug_mode:
		pending_debug_wave = clampi(target_wave, 1, 99)

@rpc("any_peer", "reliable")
func rpc_show_debug_wave_request(target_wave: int) -> void:
	pending_debug_wave = clampi(target_wave, 1, 99)

func respond_debug_wave(accepted: bool) -> void:
	if pending_debug_wave < 0:
		return
	var target_wave := pending_debug_wave
	if multiplayer.is_server():
		if accepted:
			rpc_apply_debug_wave.rpc(target_wave)
		else:
			rpc_clear_debug_wave_request.rpc()
	else:
		rpc_answer_debug_wave.rpc_id(1, target_wave, accepted)

@rpc("any_peer", "reliable")
func rpc_answer_debug_wave(target_wave: int, accepted: bool) -> void:
	if not multiplayer.is_server():
		return
	if accepted:
		rpc_apply_debug_wave.rpc(clampi(target_wave, 1, 99))
	else:
		rpc_clear_debug_wave_request.rpc()

@rpc("any_peer", "call_local", "reliable")
func rpc_apply_debug_wave(target_wave: int) -> void:
	wave = clampi(target_wave, 1, 99) - 1
	wave_active = false
	spawn_left = 0
	spawn_timer = 0.0
	balloons.clear()
	projectiles.clear()
	lightning_effects.clear()
	sword_swipes.clear()
	spikes.clear()
	local_wave_finished = false
	rival_wave_finished = false
	online_wave_start_timer = -1.0
	outgoing_debug_wave = -1
	pending_debug_wave = -1
	debug_wave_input = ""
	editing_field = ""
	if game_sound:
		game_sound.play_debug_effect("wave_jump")
	start_wave_local()

@rpc("any_peer", "call_local", "reliable")
func rpc_clear_debug_wave_request() -> void:
	outgoing_debug_wave = -1
	pending_debug_wave = -1

@rpc("any_peer", "unreliable")
func rpc_update_rival(remote_lives: int, remote_money: int, remote_beneficios: int, remote_wave: int, remote_towers: Array, remote_balloons: Array, remote_projectiles_data: Array, remote_lightning: Array, remote_bananas_data: Array, remote_swipes: Array, remote_spikes_data: Array, remote_lost: bool) -> void:
	rival_lives = remote_lives
	rival_money = remote_money
	rival_beneficios = remote_beneficios
	rival_wave = remote_wave
	rival_towers = remote_towers
	rival_balloons = remote_balloons
	play_new_rival_tower_sounds(remote_projectiles_data, remote_lightning, remote_swipes)
	rival_projectiles = RemotePredictionScript.merge_projectiles(rival_projectiles, remote_projectiles_data)
	rival_lightning_effects = remote_lightning
	# Remote bananas never show the owner's magnet movement. They disappear
	# the moment their owner starts collecting them.
	rival_bananas = []
	for remote_banana in remote_bananas_data:
		if not remote_banana.get("collecting", false):
			rival_bananas.append(remote_banana)
	rival_sword_swipes = remote_swipes
	rival_spikes = remote_spikes_data
	rival_defeated = remote_lost
	if remote_lost and not game_over:
		won = true

func play_new_rival_tower_sounds(remote_projectiles_data: Array, remote_lightning: Array, remote_swipes: Array) -> void:
	if not game_sound:
		return
	for projectile in remote_projectiles_data:
		var projectile_id: int = int(projectile.get("id", -1))
		if projectile_id < 0 or heard_rival_projectile_ids.has(projectile_id):
			continue
		heard_rival_projectile_ids[projectile_id] = true
		if int(projectile.get("kind", 0)) == 4:
			game_sound.play_mystic_arrow_effect()
		else:
			game_sound.play_effect("dart", -15.0)
	for effect in remote_lightning:
		var effect_id: int = int(effect.get("id", -1))
		if effect_id >= 0 and not heard_rival_effect_ids.has("lightning_%d" % effect_id):
			heard_rival_effect_ids["lightning_%d" % effect_id] = true
			game_sound.play_lightning_cast_effect()
	for swipe in remote_swipes:
		var swipe_id: int = int(swipe.get("id", -1))
		if swipe_id >= 0 and not heard_rival_effect_ids.has("sword_%d" % swipe_id):
			heard_rival_effect_ids["sword_%d" % swipe_id] = true
			game_sound.play_pirate_sword_sweep()

@rpc("any_peer", "reliable")
func rpc_report_defeat() -> void:
	if not game_over:
		won = true

@rpc("any_peer", "reliable")
func rpc_place_rival_tower(position: Vector2, tower_kind: int) -> void:
	var config := tower_config(tower_kind)
	rival_towers.append({
		"position": position, "range": config.range,
		"damage": config.damage, "damage_type": config.damage_type,
		"reload": config.reload, "action_rate": 1.0 / (8.0 if tower_kind == 5 else config.reload) if (tower_kind == 5 or config.reload > 0.0) else 0.0,
		"projectile_speed": config.projectile_speed,
		"projectile_range": config.projectile_range, "thermal_vision": config.thermal_vision,
		"cooldown": 0.0, "banana_timer": 0.0, "target_mode": 0, "upgrade_level": 0, "banana_value": 30, "banana_interval": 8.0, "heal_amount": 8, "chain_hits": 5, "explosion_radius": 68.0, "spike_count": 4, "color": TOWER_COLORS[tower_kind], "type": tower_kind
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
		if vs_intro_time > 0.0:
			draw_vs_intro()
			return
		if profile_menu_open:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.5, 1.5))
			draw_profile_menu()
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			return
		if sound_menu_open:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.5, 1.5))
			draw_sound_menu()
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			return
		if menu_music_select:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.5, 1.5))
			draw_menu_music_select()
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			return
		if map_select:
			draw_map_select()
			return
		if loadout_select:
			draw_loadout_select()
			return
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.5, 1.5))
		if online_lobby:
			draw_online_lobby()
		else:
			draw_mode_select()
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if online_mode:
		draw_online_duel()
		return
	if solo_modern_mode:
		draw_solo_modern()
		return
	# El escenario y todos los objetos de juego comparten la misma escala 16:9.
	# Antes solo se ampliaba el mapa, por lo que las rutas no coincidían con él.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.5, 1.5))
	draw_texture_rect(current_map_texture(), Rect2(0, 0, 1280, 720), false)
	for tower in towers:
		var tower_texture = tower_texture_for(tower.type)
		draw_texture_rect(tower_texture, Rect2(tower.position - Vector2(34, 38), Vector2(68, 68)), false)
	draw_spikes(spikes)
	for balloon in balloons:
		draw_balloon(point_on_path(balloon.distance), balloon)
	for projectile in projectiles:
		draw_dart(projectile.position, projectile.color, projectile.get("direction", Vector2.RIGHT), projectile.kind, float(projectile.get("scale", 1.0)))
	draw_solo_bananas()
	draw_sword_swipes(Vector2.ZERO, Vector2.ONE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(0, 0, 248, HEIGHT), Color("102536"))
	draw_line(Vector2(248, 0), Vector2(248, HEIGHT), Color("72d2c8"), 2.0)
	draw_hud()
	# A friendly map guardian makes the island feel inhabited.
	draw_texture_rect(GUARDIAN_TEXTURE, Rect2(1130, 42, 70, 70), false)
	draw_texture_rect(REEF_MEDIC_TEXTURE, Rect2(1040, 92, 62, 62), false)
	if online_mode:
		draw_duel_status()
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
	draw_speed_selector(Vector2(18, 250), 210.0, 52.0)
	var available := match_towers()
	for slot in range(available.size()):
		var kind: int = available[slot]
		draw_tower_card(Rect2(18, 350 + slot * 76, 210, 68), kind, "%d · %s" % [slot + 1, TOWER_NAMES[kind]], "$%d" % TOWER_COSTS[kind])
	var button_color := Color("4bba83") if not wave_active else Color("355b70")
	draw_style_box(make_box(button_color, 10), Rect2(18, 675, 210, 64))
	var wave_button_text := "OLEADAS AUTOMÁTICAS" if not multiplayer_mode else "INICIAR OLEADA" if not wave_active else "OLEADA ACTIVA"
	draw_centered(wave_button_text, Vector2(123, 714), 15, Color.WHITE)

func draw_tower_card(rect: Rect2, kind: int, title: String, subtitle: String) -> void:
	var active := kind == selected_tower
	draw_style_box(make_box(Color("31546c") if active else Color("203c50"), 9), rect)
	var card_texture = tower_texture_for(kind)
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

func speed_option_at(position: Vector2, origin: Vector2, width: float, button_height: float) -> int:
	for index in range(GAME_SPEEDS.size()):
		if Rect2(origin + Vector2(0, button_height + 4 + index * 40), Vector2(width, 38)).has_point(position):
			return index
	return -1

func draw_speed_selector(origin: Vector2, width: float, height: float) -> void:
	var active_color := Color("b56c38") if not is_equal_approx(gameplay_speed, 1.0) else Color("294a60")
	draw_style_box(make_box(active_color, 9), Rect2(origin, Vector2(width, height)))
	draw_centered("VELOCIDAD  %s" % speed_label(gameplay_speed), origin + Vector2(width * 0.5, height * 0.65), 17, Color.WHITE)
	if not speed_menu_open:
		return
	for index in range(GAME_SPEEDS.size()):
		var speed: float = GAME_SPEEDS[index]
		var rect := Rect2(origin + Vector2(0, height + 4 + index * 40), Vector2(width, 38))
		var selected := is_equal_approx(gameplay_speed, speed)
		draw_style_box(make_box(Color("3f986c") if selected else Color("294a60"), 7), rect)
		draw_centered(speed_label(speed), rect.get_center() + Vector2(0, 6), 16, Color.WHITE)

func draw_balloon(position: Vector2, balloon: Dictionary) -> void:
	if balloon.get("regenerative", false):
		var heart_radius := (13.0 + float(balloon.get("tier", 1)) * 2.0) * 1.55
		if balloon.get("moab", false):
			heart_radius = 64.0
		elif balloon.get("armored", false) or balloon.get("magic_shield", false) or balloon.get("ceramic_shell", false):
			heart_radius = 48.0
		draw_regenerative_heart(position, balloon, heart_radius)
		draw_camouflage_pattern(position, balloon, heart_radius)
		return
	if balloon.get("magic_shield", false):
		var shield_ratio: float = float(balloon.get("shield_hp", 0)) / 32.0
		draw_circle(position, 34, Color(0.30, 0.40, 1.0, 0.26))
		draw_circle(position, 29, Color(0.55, 0.35, 0.95, 0.45))
		draw_circle(position, 21, Color("3e4ca0"))
		draw_arc(position, 29, 0.0, TAU, 24, Color("b8b5ff"), 3.0)
		draw_rect(Rect2(position + Vector2(-28, -40), Vector2(56, 6)), Color("263544"))
		draw_rect(Rect2(position + Vector2(-28, -40), Vector2(56 * shield_ratio, 6)), Color("b9a7ff"))
		draw_regenerative_heart(position, balloon, 24.0)
		draw_camouflage_pattern(position, balloon, 30.0)
		return
	if balloon.get("armored", false):
		var armor_ratio: float = float(balloon.get("armor_hp", 0)) / 32.0
		draw_style_box(make_box(Color("202b35"), 12), Rect2(position - Vector2(32, 27), Vector2(64, 54)))
		draw_style_box(make_box(Color("778b98"), 10), Rect2(position - Vector2(27, 22), Vector2(54, 44)))
		draw_line(position + Vector2(-18, -10), position + Vector2(18, 10), Color("c9d8df"), 4.0)
		draw_line(position + Vector2(-18, 10), position + Vector2(18, -10), Color("c9d8df"), 4.0)
		draw_rect(Rect2(position + Vector2(-28, -38), Vector2(56, 6)), Color("263544"))
		draw_rect(Rect2(position + Vector2(-28, -38), Vector2(56 * armor_ratio, 6)), Color("b7d9e6"))
		draw_regenerative_heart(position, balloon, 24.0)
		draw_camouflage_pattern(position, balloon, 29.0)
		return
	if balloon.get("moab", false):
		var integrity := float(balloon.get("moab_hp", 100)) / 100.0
		var moab_stage: int = int(balloon.get("moab_stage", 0))
		var moab_texture = MOAB_TEXTURE if moab_stage == 0 else MOAB_DAMAGED_TEXTURE if moab_stage == 1 else MOAB_BROKEN_TEXTURE
		draw_texture_rect(moab_texture, Rect2(position - Vector2(52, 35), Vector2(104, 70)), false, Color(1.0, 1.0, 1.0, 0.55 + integrity * 0.45))
		draw_rect(Rect2(position + Vector2(-32, -15), Vector2(64 * integrity, 6)), Color("d9f4ff"))
		draw_regenerative_heart(position, balloon, 34.0)
		draw_camouflage_pattern(position, balloon, 42.0)
		return
	# Index 0 is unused so a balloon's tier maps directly to its colour.
	var colors := [Color("ef5e62"), Color("478fe4"), Color("f5d35d"), Color("a97cdd"), Color("7bd4bf"), Color("ee8f54"), Color("773b68"), Color("f5f7ff"), Color("33435f"), Color("f09fdb")]
	var tier_index := clampi(int(balloon.tier), 0, colors.size() - 1)
	var color: Color = colors[tier_index]
	draw_circle(position, 15 + balloon.tier * 2, Color("263544"))
	draw_circle(position + Vector2(0, -2), 13 + balloon.tier * 2, color)
	if balloon.tier == 9:
		draw_circle(position + Vector2(-7, -5), 3.0, Color("263544"))
		draw_circle(position + Vector2(7, -5), 3.0, Color("263544"))
		draw_arc(position + Vector2(0, 2), 10.0, 0.15, PI - 0.15, 10, Color("263544"), 2.5)
	if balloon.get("ceramic_shell", false):
		var shell_stage: int = int(balloon.get("shell_stage", 0))
		var shell_alpha: float = [0.88, 0.60, 0.32, 0.0][shell_stage]
		draw_circle(position, 37, Color(0.86, 0.78, 0.66, shell_alpha))
		draw_arc(position, 36, 0.0, TAU, 18, Color(0.45, 0.34, 0.28, shell_alpha), 3.0)
		if shell_stage >= 1:
			draw_line(position + Vector2(-28, -22), position + Vector2(-6, 5), Color(0.35, 0.27, 0.23, shell_alpha), 3.0)
		if shell_stage >= 2:
			draw_line(position + Vector2(25, -18), position + Vector2(5, 19), Color(0.35, 0.27, 0.23, shell_alpha), 3.0)
	draw_line(position + Vector2(0, 13), position + Vector2(0, 25), Color.WHITE, 1.5)
	draw_regenerative_heart(position, balloon, 13.0 + balloon.tier * 2.0)
	draw_camouflage_pattern(position, balloon, 14.0 + balloon.tier * 2.0)

func draw_camouflage_pattern(position: Vector2, balloon: Dictionary, radius: float) -> void:
	if not balloon.get("camouflaged", false):
		return
	# Keeps the base balloon recognisable while making camouflage obvious.
	draw_arc(position, radius + 3.0, 0.0, TAU, 20, Color(0.12, 0.20, 0.14, 0.58), 2.0)
	draw_circle(position + Vector2(-radius * 0.34, -radius * 0.22), radius * 0.25, Color(0.26, 0.38, 0.20, 0.43))
	draw_circle(position + Vector2(radius * 0.28, -radius * 0.05), radius * 0.20, Color(0.55, 0.48, 0.27, 0.45))
	draw_circle(position + Vector2(-radius * 0.05, radius * 0.31), radius * 0.18, Color(0.16, 0.29, 0.20, 0.46))

func draw_regenerative_heart(position: Vector2, balloon: Dictionary, radius: float) -> void:
	if not balloon.get("regenerative", false):
		return
	var tier_colors := [Color("ef5e62"), Color("478fe4"), Color("f5d35d"), Color("a97cdd"), Color("7bd4bf"), Color("ee8f54"), Color("773b68"), Color("f5f7ff"), Color("33435f"), Color("f09fdb")]
	var tier: int = clampi(int(balloon.get("tier", 1)), 1, tier_colors.size() - 1)
	var heart_color: Color = tier_colors[tier]
	if balloon.get("armored", false):
		heart_color = Color("778b98")
	elif balloon.get("magic_shield", false):
		heart_color = Color("744cb4")
	elif balloon.get("ceramic_shell", false):
		heart_color = Color("d6b89a")
	elif balloon.get("moab", false):
		heart_color = Color("3f83ba")
	var outline := heart_color.darkened(0.58)
	draw_circle(position + Vector2(-radius * 0.28, -radius * 0.18), radius * 0.34, outline)
	draw_circle(position + Vector2(radius * 0.28, -radius * 0.18), radius * 0.34, outline)
	draw_colored_polygon(PackedVector2Array([position + Vector2(-radius * 0.60, -radius * 0.10), position + Vector2(radius * 0.60, -radius * 0.10), position + Vector2(0, radius * 0.72)]), outline)
	draw_circle(position + Vector2(-radius * 0.28, -radius * 0.18), radius * 0.27, heart_color)
	draw_circle(position + Vector2(radius * 0.28, -radius * 0.18), radius * 0.27, heart_color)
	draw_colored_polygon(PackedVector2Array([position + Vector2(-radius * 0.48, -radius * 0.10), position + Vector2(radius * 0.48, -radius * 0.10), position + Vector2(0, radius * 0.57)]), heart_color)
	if balloon.get("armored", false):
		draw_line(position + Vector2(-radius * 0.43, -radius * 0.25), position + Vector2(radius * 0.35, radius * 0.37), Color("d4e2e8"), 3.0)
		draw_line(position + Vector2(-radius * 0.36, radius * 0.34), position + Vector2(radius * 0.40, -radius * 0.28), Color("d4e2e8"), 3.0)
	elif balloon.get("magic_shield", false):
		draw_arc(position, radius * 0.54, 0.0, TAU, 18, Color("c9baff"), 2.5)
	elif balloon.get("ceramic_shell", false):
		draw_line(position + Vector2(-radius * 0.42, -radius * 0.28), position + Vector2(radius * 0.05, radius * 0.42), Color("755648"), 2.5)
		draw_line(position + Vector2(radius * 0.35, -radius * 0.20), position + Vector2(-radius * 0.12, radius * 0.45), Color("755648"), 2.5)
	elif balloon.get("moab", false) or tier == 9:
		draw_circle(position + Vector2(-radius * 0.19, -radius * 0.22), radius * 0.08, outline)
		draw_circle(position + Vector2(radius * 0.19, -radius * 0.22), radius * 0.08, outline)
		draw_arc(position + Vector2(0, radius * 0.06), radius * 0.25, 0.15, PI - 0.15, 10, outline, 2.0)
	else:
		draw_circle(position + Vector2(-radius * 0.18, -radius * 0.30), radius * 0.07, Color.WHITE)

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
	draw_profile_button()
	draw_mode_card(Rect2(250, 330, 230, 190), Color("398cc0"), "INDIVIDUAL", "Defiende Coral Bend\na tu propio ritmo", "1 jugador")
	draw_mode_card(Rect2(525, 330, 230, 190), Color("b967a0"), "CO-OP LOCAL", "Cooperativo local:\nalterna turnos", "2 jugadores")
	draw_mode_card(Rect2(800, 330, 230, 190), Color("ef884e"), "EN LINEA 1 VS 1", "Crea una sala o\nunete a tu rival", "2 jugadores")
	draw_centered("Haz clic en un modo para comenzar", Vector2(640, 610), 18, Color("bdd1de"))
	draw_style_box(make_box(Color("31546c"), 10), Rect2(390, 650, 240, 52))
	draw_centered("MÚSICA DEL MENÚ", Vector2(510, 683), 17, Color.WHITE)
	draw_style_box(make_box(Color("7859a0"), 10), Rect2(650, 650, 240, 52))
	draw_centered("SONIDO", Vector2(770, 683), 17, Color.WHITE)

func profile_button_rect() -> Rect2:
	return Rect2(990, 24, 255, 66)

func profile_avatar_texture(avatar: int):
	var portraits := [DART_RANGER_TEXTURE, BOOMERANG_SCOUT_TEXTURE, BOMBARDIER_TEXTURE, LIGHTNING_MAGE_TEXTURE, MYSTIC_ARCHER_TEXTURE, BANANA_FARMER_TEXTURE, REEF_MEDIC_TEXTURE, PIRATE_TEXTURE, PATHCUTTER_TEXTURE]
	return PROFILE_DEFAULT_TEXTURE if avatar < 0 or avatar >= portraits.size() else portraits[avatar]

func draw_profile_button() -> void:
	var rect := profile_button_rect()
	draw_style_box(make_box(Color("23485e"), 13), rect)
	draw_circle(rect.position + Vector2(35, 33), 26, Color("72d2c8"))
	draw_texture_rect(profile_avatar_texture(profile_avatar), Rect2(rect.position + Vector2(10, 8), Vector2(50, 50)), false)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(74, 39), profile_name, HORIZONTAL_ALIGNMENT_LEFT, 155, 21, Color.WHITE)

func draw_vs_intro() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	for index in range(15):
		var pulse := 0.12 + 0.07 * sin(vs_intro_spin * 4.0 + index)
		draw_circle(Vector2(80 + index * 132, 110 + (index % 4) * 250), 86, Color(0.12, 0.34, 0.48, pulse))
	draw_centered("ENFRENTAMIENTO", Vector2(960, 115), 38, Color("f4d66d"))
	draw_vs_profile(Vector2(385, 505), profile_name, profile_avatar, "ANFITRIÓN" if multiplayer.is_server() else "JUGADOR UNIDO", Color("72d2c8"))
	draw_vs_profile(Vector2(1535, 505), rival_profile_name if not rival_profile_name.is_empty() else "Rival", rival_profile_avatar, "JUGADOR UNIDO" if multiplayer.is_server() else "ANFITRIÓN", Color("ffaaa0"))
	var center := Vector2(960, 505)
	var spark := 0.55 + 0.35 * sin(vs_intro_spin * 13.0)
	draw_circle(center, 142, Color(0.15, 0.25, 0.44, 0.88))
	for arc_index in range(5):
		var start := vs_intro_spin * (3.2 + arc_index * 0.27) + arc_index * TAU / 5.0
		var radius := 154.0 + sin(vs_intro_spin * 8.0 + arc_index) * 12.0
		draw_arc(center, radius, start, start + 0.85, 14, Color(0.42, 0.86, 1.0, spark), 4.0)
		draw_arc(center, radius - 11.0, start + 0.18, start + 0.55, 10, Color(0.92, 0.96, 1.0, spark), 2.0)
	draw_centered("VS", center + Vector2(0, 27), 74, Color.WHITE)
	draw_centered("PREPARANDO EL DUELO...", Vector2(960, 835), 22, Color("d9eef4"))

func draw_vs_profile(center: Vector2, display_name: String, avatar: int, role: String, accent: Color) -> void:
	var card := Rect2(center - Vector2(245, 230), Vector2(490, 460))
	draw_style_box(make_box(Color("173c54"), 18), card)
	draw_rect(Rect2(card.position, Vector2(card.size.x, 9)), accent)
	draw_circle(center + Vector2(0, -48), 122, accent.darkened(0.55))
	draw_texture_rect(profile_avatar_texture(avatar), Rect2(center + Vector2(-105, -153), Vector2(210, 210)), false)
	draw_centered(display_name, center + Vector2(0, 118), 31, Color.WHITE)
	draw_centered(role, center + Vector2(0, 163), 19, accent)

func profile_avatar_rect() -> Rect2:
	return Rect2(245, 285, 205, 205)

func draw_profile_menu() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	if profile_picker_open:
		draw_profile_picker(font)
		return
	draw_centered("PERSONALIZA TU PERFIL", Vector2(640, 115), 40, Color("72d2c8"))
	draw_style_box(make_box(Color("173c54"), 16), Rect2(145, 185, 990, 430))
	var avatar_rect := profile_avatar_rect()
	draw_circle(avatar_rect.get_center(), 108, Color("31546c"))
	draw_texture_rect(profile_avatar_texture(pending_profile_avatar), avatar_rect, false)
	if profile_avatar_hovered:
		draw_rect(avatar_rect, Color(0.10, 0.10, 0.13, 0.42))
		draw_centered("PINCEL", avatar_rect.get_center() + Vector2(0, 9), 20, Color.WHITE)
	draw_string(font, Vector2(510, 295), "NOMBRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("bdd1de"))
	draw_style_box(make_box(Color("31546c") if editing_field == "profile_name" else Color("294a60"), 9), Rect2(510, 315, 455, 62))
	draw_string(font, Vector2(532, 355), pending_profile_name + ("|" if editing_field == "profile_name" else ""), HORIZONTAL_ALIGNMENT_LEFT, 410, 25, Color.WHITE)
	draw_string(font, Vector2(510, 415), "Máximo 12 caracteres", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("bdd1de"))
	if not profile_status.is_empty():
		draw_string(font, Vector2(510, 455), profile_status, HORIZONTAL_ALIGNMENT_LEFT, 455, 16, Color("f4d66d"))
	draw_style_box(make_box(Color("4b9b78"), 11), Rect2(510, 505, 280, 64))
	draw_centered("⟳  ACTUALIZAR", Vector2(650, 545), 20, Color.WHITE)
	draw_style_box(make_box(Color("294a60"), 9), Rect2(820, 505, 145, 64))
	draw_centered("VOLVER", Vector2(892, 545), 18, Color.WHITE)

func draw_profile_picker(font: Font) -> void:
	draw_centered("ELIGE TU IMAGEN DE PERFIL", Vector2(640, 100), 38, Color("72d2c8"))
	draw_style_box(make_box(Color("173c54"), 16), Rect2(100, 155, 1080, 490))
	draw_texture_rect(profile_avatar_texture(pending_profile_avatar), Rect2(155, 245, 245, 245), false)
	draw_string(font, Vector2(155, 535), "VISTA PREVIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("f4d66d"))
	for index in range(10):
		var avatar := index - 1
		var rect := Rect2(470 + (index % 5) * 125, 220 + (index / 5) * 190, 105, 145)
		draw_style_box(make_box(Color("4b7d9e") if avatar == pending_profile_avatar else Color("294a60"), 10), rect)
		draw_texture_rect(profile_avatar_texture(avatar), Rect2(rect.position + Vector2(12, 10), Vector2(81, 81)), false)
		draw_centered("DEFECTO" if avatar < 0 else TOWER_NAMES[avatar], Vector2(rect.get_center().x, rect.position.y + 120), 12, Color.WHITE)
	draw_style_box(make_box(Color("294a60"), 9), Rect2(540, 670, 200, 48))
	draw_centered("VOLVER", Vector2(640, 701), 17, Color.WHITE)

func open_profile_menu() -> void:
	pending_profile_name = profile_name
	pending_profile_avatar = profile_avatar
	profile_status = ""
	profile_menu_open = true
	profile_picker_open = false
	editing_field = ""

func apply_profile_changes() -> void:
	var candidate := pending_profile_name.strip_edges().left(12)
	if candidate.is_empty():
		profile_status = "Escribe un nombre para el perfil."
		return
	profile_name = candidate
	profile_avatar = pending_profile_avatar
	var settings := ConfigFile.new()
	settings.load("user://balloon_frontier.cfg")
	settings.set_value("profile", "name", profile_name)
	settings.set_value("profile", "avatar", profile_avatar)
	settings.save("user://balloon_frontier.cfg")
	profile_status = "Perfil actualizado."
	editing_field = ""

func handle_profile_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if profile_picker_open:
			profile_picker_open = false
		else:
			profile_menu_open = false
		editing_field = ""
		return
	if not profile_picker_open and event is InputEventKey and event.pressed and editing_field == "profile_name":
		if event.keycode == KEY_BACKSPACE:
			pending_profile_name = pending_profile_name.left(-1)
		elif event.ctrl_pressed and event.keycode == KEY_V:
			for character in DisplayServer.clipboard_get():
				if pending_profile_name.length() < 12 and character != "\n" and character != "\r":
					pending_profile_name += character
		elif event.keycode == KEY_ENTER:
			apply_profile_changes()
		elif event.unicode > 0 and pending_profile_name.length() < 12:
			pending_profile_name += char(event.unicode)
		queue_redraw()
		return
	if event is InputEventMouseMotion:
		var hover_position: Vector2 = event.position / 1.5
		profile_avatar_hovered = not profile_picker_open and profile_avatar_rect().has_point(hover_position)
		queue_redraw()
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var mouse: Vector2 = event.position / 1.5
	if profile_picker_open:
		for index in range(10):
			var avatar := index - 1
			if Rect2(470 + (index % 5) * 125, 220 + (index / 5) * 190, 105, 145).has_point(mouse):
				pending_profile_avatar = avatar
				profile_picker_open = false
				return
		if Rect2(540, 670, 200, 48).has_point(mouse):
			profile_picker_open = false
		return
	if profile_avatar_rect().has_point(mouse):
		profile_picker_open = true
		profile_avatar_hovered = false
		return
	if Rect2(510, 315, 455, 62).has_point(mouse):
		editing_field = "profile_name"
		return
	if Rect2(510, 505, 280, 64).has_point(mouse):
		apply_profile_changes()
		return
	if Rect2(820, 505, 145, 64).has_point(mouse):
		profile_menu_open = false
		editing_field = ""

func draw_sound_slider(label: String, percent: int, position: Vector2, accent: Color) -> void:
	var font := ThemeDB.fallback_font
	var track := Rect2(position, Vector2(580, 22))
	draw_string(font, position + Vector2(0, -18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	draw_style_box(make_box(Color("263c50"), 10), track)
	var fill_width := track.size.x * float(percent) / 100.0
	if fill_width > 0.0:
		draw_style_box(make_box(accent, 10), Rect2(track.position, Vector2(fill_width, track.size.y)))
	var knob_x := track.position.x + fill_width
	draw_circle(Vector2(knob_x, track.get_center().y), 15, Color.WHITE)
	draw_circle(Vector2(knob_x, track.get_center().y), 9, accent)
	draw_string(font, Vector2(track.end.x + 28, track.position.y + 18), "%d%%" % percent, HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("f4d66d"))

func draw_sound_menu() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_centered("SONIDO", Vector2(640, 170), 44, Color("72d2c8"))
	draw_centered("Ajusta el volumen general de cada tipo de sonido", Vector2(640, 220), 19, Color("d9eef4"))
	draw_style_box(make_box(Color("173c54"), 16), Rect2(280, 275, 720, 280))
	draw_sound_slider("MÚSICA", game_sound.music_volume_percent, Vector2(350, 350), Color("65b9d1"))
	draw_sound_slider("EFECTOS DE SONIDO", game_sound.effects_volume_percent, Vector2(350, 465), Color("d99055"))
	draw_centered("Haz clic o arrastra cada barra para cambiar su porcentaje", Vector2(640, 600), 16, Color("bdd1de"))
	draw_style_box(make_box(Color("294a60"), 9), Rect2(545, 650, 190, 50))
	draw_centered("VOLVER", Vector2(640, 683), 17, Color.WHITE)

func draw_menu_music_select() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_centered("MÚSICA DEL MENÚ", Vector2(640, 160), 40, Color("72d2c8"))
	draw_centered("Elige la canción que sonará al volver al inicio", Vector2(640, 205), 18, Color("d9eef4"))
	for index in range(GameSoundScript.MENU_TRACK_NAMES.size()):
		var rect := Rect2(390, 270 + index * 85, 500, 66)
		draw_style_box(make_box(Color("4b7d9e") if index == game_sound.menu_track else Color("1d4055"), 11), rect)
		draw_string(font, rect.position + Vector2(24, 41), "%d. %s" % [index + 1, GameSoundScript.MENU_TRACK_NAMES[index]], HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color.WHITE)
	draw_style_box(make_box(Color("294a60"), 9), Rect2(545, 670, 190, 50))
	draw_centered("VOLVER", Vector2(640, 703), 17, Color.WHITE)

func handle_menu_music_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		menu_music_select = false
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var mouse: Vector2 = event.position / 1.5
	for index in range(GameSoundScript.MENU_TRACK_NAMES.size()):
		if Rect2(390, 270 + index * 85, 500, 66).has_point(mouse):
			game_sound.set_menu_track(index)
			save_menu_music_track(index)
			return
	if Rect2(545, 670, 190, 50).has_point(mouse):
		menu_music_select = false

func set_sound_slider_value(kind: String, mouse_x: float) -> void:
	var percent := clampi(roundi((mouse_x - 350.0) / 580.0 * 100.0), 0, 100)
	if kind == "music":
		game_sound.set_music_volume(percent)
	else:
		game_sound.set_effects_volume(percent)
	save_sound_volumes()
	queue_redraw()

func handle_sound_menu_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		sound_menu_open = false
		sound_slider_drag = ""
		return
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		var mouse := mouse_button.position / 1.5
		if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
			if Rect2(350, 330, 580, 62).has_point(mouse):
				sound_slider_drag = "music"
				set_sound_slider_value(sound_slider_drag, mouse.x)
				return
			if Rect2(350, 445, 580, 62).has_point(mouse):
				sound_slider_drag = "effects"
				set_sound_slider_value(sound_slider_drag, mouse.x)
				return
			if Rect2(545, 650, 190, 50).has_point(mouse):
				sound_menu_open = false
				sound_slider_drag = ""
		elif mouse_button.button_index == MOUSE_BUTTON_LEFT:
			sound_slider_drag = ""
		return
	if event is InputEventMouseMotion and not sound_slider_drag.is_empty():
		var motion := event as InputEventMouseMotion
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			set_sound_slider_value(sound_slider_drag, motion.position.x / 1.5)
		else:
			sound_slider_drag = ""

func save_sound_volumes() -> void:
	save_audio_preferences()

func save_menu_music_track(_track: int) -> void:
	save_audio_preferences()

func save_audio_preferences() -> void:
	var settings := ConfigFile.new()
	settings.load("user://balloon_frontier.cfg")
	settings.set_value("audio", "menu_track", game_sound.menu_track)
	settings.set_value("audio", "music_volume", game_sound.music_volume_percent)
	settings.set_value("audio", "effects_volume", game_sound.effects_volume_percent)
	settings.save("user://balloon_frontier.cfg")

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
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		online_lobby = false
		editing_field = ""
		queue_redraw()
		return
	if event is InputEventKey and event.pressed and not editing_field.is_empty():
		if event.keycode == KEY_BACKSPACE:
			if editing_field == "ip": lobby_ip = lobby_ip.left(-1)
			else: lobby_port = lobby_port.left(-1)
		elif event.ctrl_pressed and event.keycode == KEY_V:
			var pasted := DisplayServer.clipboard_get()
			for character in pasted:
				if editing_field == "ip" and (character == "." or character.is_valid_int()): lobby_ip += character
				if editing_field == "port" and character.is_valid_int(): lobby_port += character
		elif event.unicode > 0:
			var typed := char(event.unicode)
			if editing_field == "ip" and (typed == "." or typed.is_valid_int()): lobby_ip += typed
			if editing_field == "port" and typed.is_valid_int(): lobby_port += typed
		queue_redraw()
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var lobby_position: Vector2 = event.position / 1.5
	if Rect2(400, 370, 480, 48).has_point(lobby_position):
		editing_field = "ip"
	elif Rect2(400, 425, 480, 48).has_point(lobby_position):
		editing_field = "port"
	elif Rect2(400, 500, 220, 62).has_point(lobby_position):
		create_online_room()
	elif Rect2(660, 500, 220, 62).has_point(lobby_position):
		join_online_room()
	elif Rect2(545, 630, 190, 46).has_point(lobby_position):
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
	var settings := ConfigFile.new()
	settings.load("user://balloon_frontier.cfg")
	settings.set_value("online", "last_ip", lobby_ip)
	settings.save("user://balloon_frontier.cfg")
	network_peer = ENetMultiplayerPeer.new()
	var result := network_peer.create_client(lobby_ip, port_value)
	if result != OK:
		lobby_status = "No se pudo iniciar la conexión (%s)." % error_string(result)
		return
	multiplayer.multiplayer_peer = network_peer
	multiplayer.connected_to_server.connect(_on_online_connected)
	multiplayer.connection_failed.connect(_on_online_connection_failed)
	lobby_status = "Conectando con %s:%d..." % [lobby_ip, port_value]

func _on_online_peer_connected(peer_id: int) -> void:
	rpc_receive_rival_profile.rpc_id(peer_id, profile_name, profile_avatar)
	launch_online_match()

func _on_online_connected() -> void:
	rpc_receive_rival_profile.rpc_id(1, profile_name, profile_avatar)
	launch_online_match()

func _on_online_connection_failed() -> void:
	lobby_status = "No se pudo conectar. Revisa IP, puerto y firewall."

@rpc("any_peer", "reliable")
func rpc_receive_rival_profile(remote_name: String, remote_avatar: int) -> void:
	rival_profile_name = remote_name.left(12)
	rival_profile_avatar = clampi(remote_avatar, -1, 8)

func launch_online_match() -> void:
	online_lobby = false
	online_mode = true
	multiplayer_mode = false
	editing_field = ""
	vs_intro_time = 3.0
	vs_intro_spin = 0.0
	if game_sound:
		game_sound.play_vs_intro_effect()

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
	draw_string(font, rect.position + Vector2(14, 39), value + ("|" if focused else ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

func draw_duel_status() -> void:
	var font := ThemeDB.fallback_font
	draw_style_box(make_box(Color("1b5268"), 10), Rect2(286, 18, 260, 88))
	draw_style_box(make_box(Color("6a3545"), 10), Rect2(570, 18, 260, 88))
	draw_string(font, Vector2(305, 48), "TU FRENTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("8ce1f1"))
	draw_string(font, Vector2(305, 80), "♥ %d   $ %d" % [lives, money], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(font, Vector2(589, 48), "FRENTE RIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffb0a8"))
	draw_string(font, Vector2(589, 80), "♥ %d   $ %d" % [rival_lives, rival_money], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func draw_solo_modern() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_solo_arena()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_bananas()
	draw_local_lightning()
	draw_explosion_effects(SOLO_ARENA_ORIGIN, SOLO_ARENA_SCALE)
	draw_upgrade_effects(SOLO_ARENA_ORIGIN, SOLO_ARENA_SCALE)
	draw_placement_preview()
	draw_debug_balloon_preview()
	draw_inspected_tower_highlight()
	var font := ThemeDB.fallback_font
	draw_style_box(make_box(Color(0.05, 0.18, 0.25, 0.92), 12), Rect2(30, 34, 690, 120))
	draw_string(font, Vector2(60, 82), "DEFENSA INDIVIDUAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("8ce1f1"))
	draw_string(font, Vector2(60, 126), "VIDAS %d  ·  $ %d" % [lives, money], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	draw_match_profile_badge(Rect2(620, 48, 72, 72), profile_name, profile_avatar, Color("72d2c8"), true)
	draw_rect(Rect2(60, 178, 610, 18), Color("263544"))
	draw_rect(Rect2(60, 178, 610.0 * lives / 150.0, 18), Color("65d98a"))
	draw_string(font, Vector2(60, 233), "BENEFICIOS +$%d / 5 s" % beneficios, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("8ce1f1"))
	draw_match_timer()
	draw_style_box(make_box(Color("8a5db6"), 9), debug_button_rect())
	draw_centered("DEBUG", debug_button_rect().get_center() + Vector2(0, 6), 17, Color.WHITE)
	draw_speed_selector(Vector2(1740, 215), 120.0, 38.0)
	if debug_mode and debug_panel_open:
		draw_debug_controls(font)
	if debug_paused:
		draw_style_box(make_box(Color(0.20, 0.09, 0.32, 0.92), 12), Rect2(690, 450, 540, 100))
		draw_centered("PARTIDA PAUSADA · MODO DEBUG", Vector2(960, 510), 28, Color("f4d66d"))
	draw_style_box(make_box(Color("31546c"), 10), Rect2(1190, 230, 410, 42))
	draw_centered("COMPRAR TORRES", Vector2(1395, 258), 17, Color.WHITE)
	var available := match_towers()
	for slot in range(available.size()):
		draw_tower_button(tower_button_rect(slot), available[slot], slot)
		draw_tower_ability_button(tower_ability_rect(slot), available[slot])
	draw_tower_ability_notice()
	draw_tower_tooltip()
	draw_inspected_tower_menu()

func draw_solo_arena() -> void:
	draw_set_transform(SOLO_ARENA_ORIGIN, 0.0, SOLO_ARENA_SCALE)
	draw_texture_rect(current_map_texture(), Rect2(0, 0, 1280, 720), false)
	for tower in towers:
		draw_texture_rect(tower_texture_for(tower.type), Rect2(tower.position - Vector2(34, 38), Vector2(68, 68)), false)
	for balloon in balloons:
		draw_balloon(point_on_path(balloon.distance), balloon)
	for projectile in projectiles:
		draw_dart(projectile.position, projectile.color, projectile.get("direction", Vector2.RIGHT), projectile.kind, float(projectile.get("scale", 1.0)))
	draw_spikes(spikes)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_online_duel() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_duel_arena(Vector2(0, 270), towers, balloons, projectiles)
	draw_duel_arena(Vector2(960, 270), rival_towers, rival_balloons, rival_projectiles)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_bananas()
	draw_rival_bananas()
	draw_local_lightning()
	draw_explosion_effects(Vector2(0, 270), Vector2(0.75, 0.75))
	draw_remote_lightning()
	draw_sword_swipes(Vector2(960, 270), Vector2(0.75, 0.75), rival_sword_swipes)
	draw_spikes_at(Vector2(960, 270), rival_spikes)
	draw_upgrade_effects(Vector2(0, 270))
	draw_placement_preview()
	draw_debug_balloon_preview()
	draw_inspected_tower_highlight()
	draw_rect(Rect2(956, 0, 8, HEIGHT), Color("f4d66d"))
	draw_style_box(make_box(Color(0.05, 0.18, 0.25, 0.92), 12), Rect2(30, 34, 690, 120))
	draw_style_box(make_box(Color(0.30, 0.10, 0.16, 0.92), 12), Rect2(1200, 34, 690, 120))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(60, 82), "TU FRENTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("8ce1f1"))
	draw_string(font, Vector2(60, 126), "VIDAS %d  ·  $ %d" % [lives, money], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	draw_match_profile_badge(Rect2(620, 48, 72, 72), profile_name, profile_avatar, Color("72d2c8"), true)
	draw_rect(Rect2(60, 178, 610, 18), Color("263544"))
	draw_rect(Rect2(60, 178, 610.0 * lives / 150.0, 18), Color("65d98a"))
	draw_string(font, Vector2(60, 233), "BENEFICIOS +$%d / 5 s" % beneficios, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("8ce1f1"))
	if money_popup_time > 0.0:
		var popup_alpha: float = clampf(money_popup_time / 0.75, 0.0, 1.0)
		var popup_y: float = 160.0 - (1.0 - popup_alpha) * 35.0
		var money_prefix := "VIDAS %d  ·  " % lives
		var money_text := "$ %d" % money
		var popup_text := "- $ %d" % money_popup_amount
		var money_x := 60.0 + font.get_string_size(money_prefix, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x
		var popup_x := money_x + (font.get_string_size(money_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x - font.get_string_size(popup_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x) * 0.5
		draw_string(font, Vector2(popup_x, popup_y), popup_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color(1.0, 0.32, 0.32, popup_alpha))
	draw_string(font, Vector2(1230, 82), "FRENTE RIVAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("ffb0a8"))
	draw_string(font, Vector2(1230, 126), "VIDAS %d" % rival_lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
	draw_match_profile_badge(Rect2(1798, 48, 72, 72), rival_profile_name if not rival_profile_name.is_empty() else "Rival", rival_profile_avatar, Color("ffaaa0"), true)
	draw_rect(Rect2(1230, 178, 610, 18), Color("263544"))
	draw_rect(Rect2(1230, 178, 610.0 * rival_lives / 150.0, 18), Color("ef7676"))
	draw_match_timer()
	draw_style_box(make_box(Color("8a5db6"), 9), Rect2(1600, 215, 120, 38))
	draw_centered("DEBUG", Vector2(1660, 242), 17, Color.WHITE)
	draw_speed_selector(Vector2(1740, 215), 120.0, 38.0)
	if online_mode and rival_speed_vote > 0.0:
		draw_style_box(make_box(Color("76543a"), 9), Rect2(1060, 215, 500, 38))
		draw_centered("EL RIVAL QUIERE %s" % speed_label(rival_speed_vote), Vector2(1310, 242), 16, Color.WHITE)
	elif online_mode and local_speed_vote > 0.0:
		draw_style_box(make_box(Color("31546c"), 9), Rect2(1060, 215, 500, 38))
		draw_centered("ESPERANDO AL RIVAL PARA %s" % speed_label(local_speed_vote), Vector2(1310, 242), 16, Color.WHITE)
	if rival_debug_vote > 0:
		draw_style_box(make_box(Color("76543a"), 9), Rect2(1360, 258, 500, 34))
		draw_centered("EL RIVAL QUIERE %s EL MODO DEBUG" % ("ACTIVAR" if rival_debug_vote == 1 else "DESACTIVAR"), Vector2(1610, 281), 15, Color.WHITE)
	elif local_debug_vote > 0:
		draw_style_box(make_box(Color("31546c"), 9), Rect2(1360, 258, 500, 34))
		draw_centered("ESPERANDO AL RIVAL PARA %s DEBUG" % ("ACTIVAR" if local_debug_vote == 1 else "DESACTIVAR"), Vector2(1610, 281), 15, Color.WHITE)
	if debug_mode and debug_panel_open:
		draw_debug_controls(font)
	if debug_paused:
		draw_style_box(make_box(Color(0.20, 0.09, 0.32, 0.92), 12), Rect2(690, 450, 540, 100))
		draw_centered("PARTIDA PAUSADA · MODO DEBUG", Vector2(960, 510), 28, Color("f4d66d"))
	draw_duel_tabs(font)
	if active_duel_tab == 0:
		var available := match_towers()
		for slot in range(available.size()):
			draw_tower_button(tower_button_rect(slot), available[slot], slot)
			draw_tower_ability_button(tower_ability_rect(slot), available[slot])
		draw_tower_ability_notice()
		draw_tower_tooltip()
	else:
		draw_balloon_send_buttons(font)
	draw_inspected_tower_menu()
	draw_style_box(make_box(Color("843d45"), 10), Rect2(1640, 850, 230, 62))
	draw_string(font, Vector2(1680, 890), "RENDIRSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	if surrender_prompt:
		draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color(0.02, 0.06, 0.1, 0.7))
		draw_style_box(make_box(Color("1d4055"), 16), Rect2(690, 400, 540, 270))
		draw_centered("¿SEGURO QUE QUIERES RENDIRTE?", Vector2(960, 475), 28, Color.WHITE)
		draw_style_box(make_box(Color("b94a4a"), 10), Rect2(820, 575, 130, 62))
		draw_style_box(make_box(Color("3f93bb"), 10), Rect2(970, 575, 180, 62))
		draw_centered("SÍ", Vector2(885, 615), 20, Color.WHITE)
		draw_centered("SEGUIR", Vector2(1060, 615), 20, Color.WHITE)
	if game_over or won:
		draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color(0.03, 0.08, 0.13, 0.78))
		draw_centered("¡GANASTE EL DUELO!" if won else "TU FRENTE CAYO", Vector2(960, 500), 56, Color("f8d36a") if won else Color("ff8d8d"))
		draw_centered("Haz clic para volver a empezar", Vector2(960, 570), 28, Color.WHITE)

func draw_debug_controls(font: Font) -> void:
	if solo_modern_mode:
		draw_solo_debug_controls(font)
		return
	var panel := Rect2(1430, 300, 390, 450)
	draw_style_box(make_box(Color(0.10, 0.08, 0.20, 0.96), 12), panel)
	draw_style_box(make_box(Color("7859a0") if debug_tab == 0 else Color("2b2940"), 8), Rect2(1440, 305, 180, 35))
	draw_style_box(make_box(Color("7859a0") if debug_tab == 1 else Color("2b2940"), 8), Rect2(1630, 305, 180, 35))
	draw_centered("CONTROL", Vector2(1530, 329), 15, Color.WHITE)
	draw_centered("GENERAR GLOBOS", Vector2(1720, 329), 14, Color.WHITE)
	if debug_tab == 1:
		draw_debug_balloon_generator(font)
		return
	var pause_color := Color("c27a46") if not debug_paused else Color("4b9b78")
	draw_style_box(make_box(pause_color, 9), Rect2(1460, 355, 180, 50))
	draw_centered("PAUSAR" if not debug_paused else "REANUDAR", Vector2(1550, 387), 17, Color.WHITE)
	draw_string(font, Vector2(1460, 418), "Avanzar a oleada", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
	draw_style_box(make_box(Color("31546c") if editing_field == "debug_wave" else Color("294a60"), 8), Rect2(1460, 425, 130, 50))
	draw_string(font, Vector2(1476, 457), debug_wave_input + ("|" if editing_field == "debug_wave" else ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_style_box(make_box(Color("4b7d9e") if debug_wave_input.to_int() >= 1 else Color("355b70"), 8), Rect2(1605, 425, 160, 50))
	draw_centered("AVANZAR", Vector2(1685, 457), 16, Color.WHITE)
	draw_style_box(make_box(Color("b68243"), 8), Rect2(1460, 495, 145, 50))
	draw_style_box(make_box(Color("4b9b78") if debug_invulnerable else Color("6a3545"), 8), Rect2(1620, 495, 145, 50))
	draw_centered("+$10000", Vector2(1532, 527), 17, Color.WHITE)
	draw_centered("INMUNE" if debug_invulnerable else "INMUNIDAD", Vector2(1692, 527), 15, Color.WHITE)

func draw_debug_balloon_generator(font: Font) -> void:
	var options := debug_balloon_options()
	for index in range(options.size()):
		var option: Dictionary = options[index]
		var rect := debug_balloon_button_rect(index)
		if not Rect2(1440, 350, 375, 335).intersects(rect):
			continue
		var selected := int(option.kind) == debug_spawn_kind
		var hovered := index == debug_hover_balloon
		draw_style_box(make_box(Color("73516f") if selected else Color("4a6175") if hovered else Color("293f51"), 8), rect)
		draw_circle(rect.position + Vector2(25, 28), 17, debug_balloon_color(option))
		draw_string(font, rect.position + Vector2(48, 25), str(option.label), HORIZONTAL_ALIGNMENT_LEFT, 62, 13, Color.WHITE)
		draw_string(font, rect.position + Vector2(48, 47), "♥%s · %s" % [option.life, option.speed], HORIZONTAL_ALIGNMENT_LEFT, 62, 11, Color("d9eef4"))
	var debug_rows: int = int(ceili(float(options.size()) / 3.0))
	if debug_rows > 4:
		draw_string(font, Vector2(1790, 365), "▲", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE if debug_balloon_scroll_row > 0 else Color("657080"))
		draw_string(font, Vector2(1790, 670), "▼", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE if debug_balloon_scroll_row < debug_rows - 4 else Color("657080"))
	draw_style_box(make_box(Color("4b9b78") if debug_spawn_camouflaged else Color("33445a"), 8), Rect2(1460, 700, 155, 42))
	draw_style_box(make_box(Color("b45c76") if debug_spawn_regenerative else Color("33445a"), 8), Rect2(1630, 700, 155, 42))
	draw_centered("✓ CAMUFLAJE" if debug_spawn_camouflaged else "CAMUFLAJE", Vector2(1537, 727), 13, Color.WHITE)
	draw_centered("✓ REGENERATIVO" if debug_spawn_regenerative else "REGENERATIVO", Vector2(1707, 727), 13, Color.WHITE)
	if debug_hover_balloon >= 0 and debug_hover_balloon < options.size():
		var info: Dictionary = options[debug_hover_balloon]
		var tooltip := Rect2(970, 570, 440, 170)
		draw_style_box(make_box(Color(0.05, 0.12, 0.18, 0.96), 10), tooltip)
		draw_string(font, tooltip.position + Vector2(18, 29), str(info.label), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
		draw_string(font, tooltip.position + Vector2(18, 58), "Velocidad: %s · Daño frontera: %d" % [info.speed, info.leak], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
		draw_string(font, tooltip.position + Vector2(18, 84), "Vida: %s · Capas: %s" % [info.life, info.layers], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
		draw_string(font, tooltip.position + Vector2(18, 110), "Aparece desde oleada %s" % info.waves, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("f4d66d"))
		draw_string(font, tooltip.position + Vector2(18, 141), "Camuflado: %s · Regenerativo: %s" % ["sí" if debug_spawn_camouflaged else "no", "sí" if debug_spawn_regenerative and int(info.kind) != 100 else "no"], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("bdd1de"))

func solo_debug_balloon_rect(index: int) -> Rect2:
	return Rect2(220 + (index % 6) * 150, 930 + (index / 6 - debug_balloon_scroll_row) * 62, 140, 54)

func draw_solo_debug_controls(font: Font) -> void:
	draw_style_box(make_box(Color(0.10, 0.08, 0.20, 0.97), 12), Rect2(205, 840, 1695, 210))
	draw_style_box(make_box(Color("7859a0") if debug_tab == 0 else Color("2b2940"), 8), Rect2(215, 850, 175, 36))
	draw_style_box(make_box(Color("7859a0") if debug_tab == 1 else Color("2b2940"), 8), Rect2(400, 850, 175, 36))
	draw_centered("CONTROL", Vector2(302, 874), 16, Color.WHITE)
	draw_centered("GENERAR GLOBOS", Vector2(487, 874), 15, Color.WHITE)
	if debug_tab == 0:
		draw_style_box(make_box(Color("c27a46") if not debug_paused else Color("4b9b78"), 9), Rect2(600, 850, 155, 42))
		draw_centered("PAUSAR" if not debug_paused else "REANUDAR", Vector2(677, 877), 16, Color.WHITE)
		draw_string(font, Vector2(775, 867), "OLEADA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d9eef4"))
		draw_style_box(make_box(Color("31546c") if editing_field == "debug_wave" else Color("294a60"), 8), Rect2(850, 850, 92, 42))
		draw_string(font, Vector2(865, 878), debug_wave_input + ("|" if editing_field == "debug_wave" else ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
		draw_style_box(make_box(Color("4b7d9e"), 8), Rect2(952, 850, 125, 42))
		draw_centered("AVANZAR", Vector2(1014, 877), 15, Color.WHITE)
		draw_style_box(make_box(Color("b68243"), 8), Rect2(1090, 850, 145, 42))
		draw_centered("+$10000", Vector2(1162, 877), 15, Color.WHITE)
		draw_style_box(make_box(Color("4b9b78") if debug_invulnerable else Color("6a3545"), 8), Rect2(1245, 850, 145, 42))
		draw_centered("INMUNE" if debug_invulnerable else "INMUNIDAD", Vector2(1317, 877), 14, Color.WHITE)
		return
	var options := debug_balloon_options()
	for index in range(options.size()):
		var rect := solo_debug_balloon_rect(index)
		if not Rect2(215, 920, 920, 125).intersects(rect):
			continue
		var option: Dictionary = options[index]
		draw_style_box(make_box(Color("73516f") if int(option.kind) == debug_spawn_kind else Color("293f51"), 7), rect)
		draw_circle(rect.position + Vector2(19, 27), 14, debug_balloon_color(option))
		draw_string(font, rect.position + Vector2(38, 23), str(option.label), HORIZONTAL_ALIGNMENT_LEFT, 96, 13, Color.WHITE)
		draw_string(font, rect.position + Vector2(38, 42), "♥%s" % option.life, HORIZONTAL_ALIGNMENT_LEFT, 90, 11, Color("d9eef4"))
	draw_style_box(make_box(Color("4b9b78") if debug_spawn_camouflaged else Color("33445a"), 8), Rect2(1150, 930, 155, 54))
	draw_style_box(make_box(Color("b45c76") if debug_spawn_regenerative else Color("33445a"), 8), Rect2(1320, 930, 155, 54))
	draw_centered("CAMUFLAJE", Vector2(1227, 963), 13, Color.WHITE)
	draw_centered("REGENERATIVO", Vector2(1397, 963), 13, Color.WHITE)

func handle_solo_debug_input(mouse: Vector2) -> bool:
	if not Rect2(205, 840, 1695, 210).has_point(mouse):
		return false
	if Rect2(215, 850, 175, 36).has_point(mouse):
		debug_tab = 0
		return true
	if Rect2(400, 850, 175, 36).has_point(mouse):
		debug_tab = 1
		return true
	if debug_tab == 0:
		if Rect2(600, 850, 155, 42).has_point(mouse): request_debug_pause_toggle()
		elif Rect2(850, 850, 92, 42).has_point(mouse): editing_field = "debug_wave"
		elif Rect2(952, 850, 125, 42).has_point(mouse): request_debug_wave(debug_wave_input.to_int())
		elif Rect2(1090, 850, 145, 42).has_point(mouse): grant_debug_money()
		elif Rect2(1245, 850, 145, 42).has_point(mouse): toggle_debug_invulnerability()
		return true
	for index in range(debug_balloon_options().size()):
		var balloon_rect := solo_debug_balloon_rect(index)
		if Rect2(215, 920, 920, 125).intersects(balloon_rect) and balloon_rect.has_point(mouse):
			debug_spawn_kind = int(debug_balloon_options()[index].kind)
			return true
	if Rect2(1150, 930, 155, 54).has_point(mouse): debug_spawn_camouflaged = not debug_spawn_camouflaged
	elif Rect2(1320, 930, 155, 54).has_point(mouse): debug_spawn_regenerative = not debug_spawn_regenerative
	return true

func draw_debug_balloon_preview() -> void:
	if not debug_mode or debug_spawn_kind < 0:
		return
	var arena_rect := local_arena_rect()
	if not arena_rect.has_point(cursor_position):
		return
	var arena_origin := local_arena_origin()
	var arena_scale := local_arena_scale()
	var position := (cursor_position - arena_origin) / arena_scale
	var valid := debug_path_distance(position) >= 0.0
	var preview: Dictionary = {"tier": clampi(debug_spawn_kind, 1, 9), "camouflaged": debug_spawn_camouflaged, "regenerative": debug_spawn_regenerative}
	if debug_spawn_kind == 95:
		preview = {"tier":9, "ceramic_shell":true, "shell_stage":0, "camouflaged":debug_spawn_camouflaged, "regenerative":debug_spawn_regenerative}
	elif debug_spawn_kind == 81:
		preview = {"tier":8, "armored":true, "armor_hp":32, "camouflaged":debug_spawn_camouflaged, "regenerative":debug_spawn_regenerative}
	elif debug_spawn_kind == 82:
		preview = {"tier":8, "magic_shield":true, "shield_hp":32, "camouflaged":debug_spawn_camouflaged, "regenerative":debug_spawn_regenerative}
	elif debug_spawn_kind == 100:
		preview = {"tier":100, "moab":true, "moab_hp":100, "moab_stage":0, "camouflaged":debug_spawn_camouflaged}
	draw_set_transform(arena_origin, 0.0, arena_scale)
	draw_balloon(position, preview)
	if not valid:
		# Fuera del camino no se puede soltar: el rojo solo aparece en ese caso.
		draw_circle(position, 31.0, Color(1.0, 0.10, 0.10, 0.45))
		draw_arc(position, 34.0, 0.0, TAU, 24, Color(1.0, 0.42, 0.42, 0.95), 2.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_duel_arena(origin: Vector2, arena_towers: Array, arena_balloons: Array, arena_projectiles: Array) -> void:
	draw_set_transform(origin, 0.0, Vector2(0.75, 0.75))
	draw_texture_rect(current_map_texture(), Rect2(0, 0, 1280, 720), false)
	for tower in arena_towers:
		var tower_texture = tower_texture_for(tower.type)
		draw_texture_rect(tower_texture, Rect2(tower.position - Vector2(34, 38), Vector2(68, 68)), false)
	for balloon in arena_balloons:
		draw_balloon(point_on_path(balloon.distance), balloon)
	for projectile in arena_projectiles:
		draw_dart(projectile.position, projectile.color, projectile.get("direction", Vector2.RIGHT), projectile.kind, float(projectile.get("scale", 1.0)))
	if arena_towers == towers:
		draw_spikes(spikes)
	if arena_towers == towers:
		draw_sword_swipes(origin, Vector2(0.75, 0.75))

func draw_upgrade_effects(origin: Vector2, scale := Vector2(0.75, 0.75)) -> void:
	if upgrade_effects.is_empty():
		return
	var font := ThemeDB.fallback_font
	draw_set_transform(origin, 0.0, scale)
	for effect in upgrade_effects:
		var duration: float = float(effect.get("duration", 0.9))
		var alpha: float = clampf(float(effect.time) / duration, 0.0, 1.0)
		var radius := 42.0 + (1.0 - alpha) * 55.0
		var ring_color: Color = effect.color
		ring_color.a = alpha
		draw_arc(effect.position, radius, 0.0, TAU, 28, ring_color, 4.0)
		if effect.get("ultimate", false):
			var pulse := 1.0 - alpha
			var gold := Color(1.0, 0.78, 0.20, alpha)
			draw_circle(effect.position, 56.0 + pulse * 64.0, Color(1.0, 0.72, 0.16, alpha * 0.13))
			draw_arc(effect.position, 70.0 + pulse * 145.0, 0.0, TAU, 42, gold, 5.0)
			for ray in range(12):
				var ray_angle := ray * TAU / 12.0 + pulse * 3.0
				var inner: Vector2 = effect.position + Vector2(cos(ray_angle), sin(ray_angle)) * (34.0 + pulse * 25.0)
				var outer: Vector2 = effect.position + Vector2(cos(ray_angle), sin(ray_angle)) * (92.0 + pulse * 145.0)
				draw_line(inner, outer, Color(1.0, 0.86, 0.38, alpha * 0.72), 3.0)
			draw_centered("MEJORA DEFINITIVA", effect.position + Vector2(0, -150.0 - pulse * 35.0), 23, gold)
		for star in range(6):
			var angle := star * TAU / 6.0 + (1.0 - alpha) * 2.0
			draw_circle(effect.position + Vector2(cos(angle), sin(angle)) * radius, 4.0, Color(1.0, 0.92, 0.45, alpha))
		draw_centered(str(effect.title), effect.position + Vector2(0, -radius - 12), 18, Color(1.0, 1.0, 1.0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_explosion_effects(origin: Vector2, scale: Vector2) -> void:
	if explosion_effects.is_empty():
		return
	draw_set_transform(origin, 0.0, scale)
	for effect in explosion_effects:
		var alpha: float = clampf(float(effect.time) / 0.32, 0.0, 1.0)
		# El anillo representa de forma precisa el área real que recibe el daño.
		var radius: float = float(effect.radius)
		var position: Vector2 = effect.position
		var pulse_radius := radius * (0.82 + (1.0 - alpha) * 0.18)
		draw_circle(position, pulse_radius, Color(1.0, 0.46, 0.12, alpha * 0.10))
		draw_arc(position, pulse_radius, 0.0, TAU, 32, Color(1.0, 0.72, 0.32, alpha * 0.62), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_tower_upgrade_decorations(tower: Dictionary) -> void:
	var levels: Array = tower.get("branch_levels", [0, 0, 0])
	var power: int = int(levels[0])
	var range_level: int = int(levels[1])
	var rhythm: int = int(levels[2])
	if power <= 0 and range_level <= 0 and rhythm <= 0:
		return
	var position: Vector2 = tower.position
	if power > 0:
		var glow_radius := 38.0 + power * 4.0
		draw_arc(position, glow_radius, 0.15, PI - 0.15, 18, Color(1.0, 0.73, 0.25, 0.45), 2.0 + power * 0.4)
		if int(tower.type) == 4:
			# Mystic Archer: a visibly larger gilded bow for the power path.
			var bow_size := 34.0 + power * 7.0
			draw_arc(position + Vector2(-8, 0), bow_size, -PI * 0.62, PI * 0.62, 22, Color("f4d66d"), 3.0 + power * 0.6)
			draw_line(position + Vector2(-8, -bow_size), position + Vector2(-8, bow_size), Color("e7f7ff"), 1.5)
			for gem in range(power):
				draw_circle(position + Vector2(15 + gem * 7, -25), 2.5, Color("b99aff"))
	if range_level > 0:
		draw_arc(position, 42.0 + range_level * 3.0, 0.0, TAU, 26, Color(0.35, 0.85, 1.0, 0.24), 1.5)
	if rhythm > 0:
		for mark in range(rhythm):
			var angle: float = float(mark) * TAU / float(maxi(1, rhythm)) - PI * 0.5
			draw_circle(position + Vector2(cos(angle), sin(angle)) * (36.0 + rhythm * 2.0), 2.4, Color(0.55, 1.0, 0.72, 0.72))

func draw_dart(position: Vector2, color: Color, direction: Vector2, kind := 0, scale := 1.0) -> void:
	if kind == 1:
		draw_texture_rect(BOOMERANG_PROJECTILE_TEXTURE, Rect2(position - Vector2(16, 16), Vector2(32, 32)), false)
		return
	if kind == 2:
		draw_texture_rect(BOMB_PROJECTILE_TEXTURE, Rect2(position - Vector2(18, 18), Vector2(36, 36)), false)
		return
	var tip := position + direction * 12.0 * scale
	var tail := position - direction * 12.0 * scale
	draw_line(tail, tip, Color("263544"), 5.0 * scale)
	draw_line(tail, tip, color, 2.5 * scale)
	draw_circle(tip, 3.5 * scale, Color.WHITE)

func draw_sword_swipes(origin: Vector2, scale: Vector2, swipe_list := sword_swipes) -> void:
	if swipe_list.is_empty():
		return
	draw_set_transform(origin, 0.0, scale)
	for swipe in swipe_list:
		var alpha: float = clampf(float(swipe.time) / 0.32, 0.0, 1.0)
		draw_arc(swipe.position, 90.0, swipe.angle - PI * 0.5, swipe.angle + PI * 0.5, 22, Color(1.0, 0.88, 0.55, alpha), 8.0)
		draw_arc(swipe.position, 76.0, swipe.angle - PI * 0.5, swipe.angle + PI * 0.5, 22, Color(1.0, 1.0, 1.0, alpha), 2.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_spikes(spike_list: Array) -> void:
	for spike in spike_list:
		var point: Vector2 = spike.position
		# Tres púas solapadas con base oscura y puntas claras, más legibles que un triángulo plano.
		for offset in [Vector2(-6, 3), Vector2(6, 3), Vector2(0, 0)]:
			var base_width := 5.0 if offset.x == 0.0 else 4.0
			var height := 18.0 if offset.x == 0.0 else 14.0
			var points := PackedVector2Array([point + offset + Vector2(-base_width, 7), point + offset + Vector2(0, -height), point + offset + Vector2(base_width, 7)])
			draw_colored_polygon(points, Color("d9e6ec"))
			draw_polyline(PackedVector2Array([points[0], points[1], points[2]]), Color("344b59"), 2.0)
			draw_line(point + offset + Vector2(-base_width * 0.35, 4), point + offset + Vector2(0, -height + 3), Color("ffffff"), 1.25)

func draw_spikes_at(origin: Vector2, spike_list: Array) -> void:
	draw_set_transform(origin, 0.0, Vector2(0.75, 0.75))
	draw_spikes(spike_list)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_solo_bananas() -> void:
	# Called while the individual arena already uses its 1.5x world transform.
	for banana in bananas:
		draw_banana_asset(banana.position, int(banana.get("brown_stage", 0)))

func draw_bananas() -> void:
	draw_banana_group(Vector2(0, 270), bananas)
	# Local pickup text is only drawn on our own arena.
	draw_set_transform(Vector2(0, 270), 0.0, Vector2(0.75, 0.75))
	if banana_popup_time > 0.0:
		var font := ThemeDB.fallback_font
		var popup_alpha: float = clampf(banana_popup_time / 0.65, 0.0, 1.0)
		var popup_position := banana_popup_position + Vector2(0, -42.0 * (1.0 - popup_alpha))
		draw_string(font, popup_position, "+$%d" % banana_popup_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(1.0, 0.88, 0.25, popup_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_rival_bananas() -> void:
	draw_banana_group(Vector2(960, 270), rival_bananas)

func draw_banana_group(origin: Vector2, banana_list: Array) -> void:
	draw_set_transform(origin, 0.0, Vector2(0.75, 0.75))
	for banana in banana_list:
		draw_banana_asset(banana.position, int(banana.get("brown_stage", 0)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_banana_asset(position: Vector2, brown_stage: int) -> void:
	# Curved peel silhouette: recognisable as a banana even at the small game scale.
	var stage := clampi(brown_stage, 0, 3)
	var peel_colors := [Color("f9d64a"), Color("c6a444"), Color("94703c"), Color("5d412a")]
	var highlight_colors := [Color("fff3a0"), Color("e6ca78"), Color("b58b54"), Color("79563a")]
	var outline_colors := [Color("73522a"), Color("634728"), Color("4b3526"), Color("30231e")]
	var peel: Color = peel_colors[stage]
	var outline: Color = outline_colors[stage]
	var curve := PackedVector2Array([
		position + Vector2(-15, -11), position + Vector2(-14, -3),
		position + Vector2(-10, 5), position + Vector2(-3, 10),
		position + Vector2(5, 11), position + Vector2(12, 7),
		position + Vector2(17, 0), position + Vector2(18, -6)
	])
	draw_polyline(curve, outline, 15.0, true)
	draw_polyline(curve, peel, 10.0, true)
	draw_polyline(PackedVector2Array([position + Vector2(-12, -5), position + Vector2(-8, 3), position + Vector2(-2, 7), position + Vector2(5, 8), position + Vector2(11, 4)]), highlight_colors[stage], 2.4, true)
	# Stem and dark tip make the fruit direction clear; both darken with age.
	draw_line(position + Vector2(-15, -11), position + Vector2(-19, -16), outline, 5.0, true)
	draw_line(position + Vector2(-18, -16), position + Vector2(-21, -16), Color("3a2b20"), 4.0, true)
	draw_circle(position + Vector2(18, -6), 3.3, Color("3a2b20"))

func current_map_texture():
	return MapCatalogScript.TEXTURES[clampi(active_map, 0, MapCatalogScript.TEXTURES.size() - 1)]

func rebuild_path_for_active_map() -> void:
	path = MapCatalogScript.path_for(active_map)
	path_lengths.clear()
	path_total = 1.0
	for i in range(path.size() - 1):
		path_lengths.append(path[i].distance_to(path[i + 1]))
		path_total += path_lengths[i]

func open_map_select(is_online: bool) -> void:
	mode_selected = false
	map_select = true
	online_mode = is_online
	selected_map_vote = -1
	rival_map_vote = -1
	map_ready = false
	rival_map_ready = false
	map_reveal_time = 0.0
	map_coin_time = 0.0
	map_roulette_time = 0.0
	map_resolution_label = ""

func map_card_rect(index: int) -> Rect2:
	return Rect2(115 + (index % 2) * 865, 275 + (index / 2) * 245, 825, 210)

func map_random_rect() -> Rect2:
	return Rect2(700, 775, 520, 86)

func map_ready_rect() -> Rect2:
	return Rect2(760, 900, 400, 76)

func handle_map_select_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and map_reveal_time <= 0.0:
		map_select = false
		online_lobby = online_mode
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if map_reveal_time > 0.0:
		return
	var mouse: Vector2 = event.position
	if Rect2(40, 970, 180, 62).has_point(mouse):
		map_select = false
		online_lobby = online_mode
		return
	for index in range(MapCatalogScript.NAMES.size()):
		if map_card_rect(index).has_point(mouse) and not map_ready:
			selected_map_vote = index
			queue_redraw()
			return
	if map_random_rect().has_point(mouse) and not map_ready:
		selected_map_vote = MapCatalogScript.NAMES.size()
		queue_redraw()
		return
	if map_ready_rect().has_point(mouse) and selected_map_vote >= 0 and not map_ready:
		map_ready = true
		if online_mode:
			if multiplayer.is_server():
				rpc_map_ready_indicator.rpc()
				try_resolve_map_vote()
			else:
				rpc_submit_map_vote.rpc_id(1, selected_map_vote)
		else:
			if selected_map_vote == MapCatalogScript.NAMES.size():
				begin_map_roulette(rng.randi_range(0, MapCatalogScript.NAMES.size() - 1))
			else:
				begin_map_reveal(selected_map_vote, "MAPA ELEGIDO")
		queue_redraw()

@rpc("any_peer", "reliable")
func rpc_submit_map_vote(vote: int) -> void:
	if not multiplayer.is_server():
		return
	rival_map_vote = clampi(vote, 0, MapCatalogScript.NAMES.size())
	rival_map_ready = true
	try_resolve_map_vote()

@rpc("any_peer", "reliable")
func rpc_map_ready_indicator() -> void:
	rival_map_ready = true

func try_resolve_map_vote() -> void:
	if not multiplayer.is_server() or not map_ready or not rival_map_ready:
		return
	var random_vote := MapCatalogScript.NAMES.size()
	var result := selected_map_vote
	var resolution := "MAPA ELEGIDO"
	if selected_map_vote == random_vote and rival_map_vote == random_vote:
		result = rng.randi_range(0, random_vote - 1)
		rpc_start_map_roulette.rpc(result)
		return
	elif selected_map_vote == random_vote:
		result = rival_map_vote
		resolution = "VOTO RIVAL"
	elif rival_map_vote == random_vote:
		resolution = "TU VOTO"
	elif selected_map_vote != rival_map_vote:
		var heads := rng.randi_range(0, 1) == 0
		rpc_start_map_coin_toss.rpc(selected_map_vote, rival_map_vote, heads)
		return
	rpc_begin_map_reveal.rpc(result, resolution)

@rpc("any_peer", "call_local", "reliable")
func rpc_begin_map_reveal(map_index: int, resolution: String) -> void:
	begin_map_reveal(map_index, resolution)

@rpc("any_peer", "call_local", "reliable")
func rpc_start_map_coin_toss(host_vote: int, join_vote: int, heads: bool) -> void:
	map_coin_host_vote = clampi(host_vote, 0, MapCatalogScript.NAMES.size() - 1)
	map_coin_join_vote = clampi(join_vote, 0, MapCatalogScript.NAMES.size() - 1)
	map_coin_heads = heads
	map_coin_time = 2.35
	map_coin_spin = 0.0
	if game_sound:
		game_sound.play_coin_toss_effect()

@rpc("any_peer", "call_local", "reliable")
func rpc_start_map_roulette(map_index: int) -> void:
	begin_map_roulette(map_index)

func begin_map_roulette(map_index: int) -> void:
	map_roulette_result = clampi(map_index, 0, MapCatalogScript.NAMES.size() - 1)
	map_roulette_time = 2.6
	map_roulette_spin = 0.0
	if game_sound:
		game_sound.play_roulette_effect(map_roulette_time)

func begin_map_reveal(map_index: int, resolution: String) -> void:
	active_map = clampi(map_index, 0, MapCatalogScript.NAMES.size() - 1)
	rebuild_path_for_active_map()
	map_resolution_label = resolution
	map_reveal_time = 2.7
	map_resolution_spin = 0.0
	if game_sound:
		game_sound.play_map_reveal_effect()

func update_map_selection(delta: float) -> void:
	if map_coin_time > 0.0:
		map_coin_time -= delta
		map_coin_spin += delta
		if map_coin_time <= 0.0:
			var chosen_map := map_coin_host_vote if map_coin_heads else map_coin_join_vote
			begin_map_reveal(chosen_map, "CARA · MAPA DEL ANFITRION" if map_coin_heads else "CRUZ · MAPA DEL JUGADOR UNIDO")
		return
	if map_roulette_time > 0.0:
		map_roulette_time -= delta
		map_roulette_spin += delta
		if map_roulette_time <= 0.0:
			begin_map_reveal(map_roulette_result, "RULETA DE MAPAS")
		return
	if map_reveal_time <= 0.0:
		return
	map_reveal_time -= delta
	map_resolution_spin += delta
	if map_reveal_time <= 0.0:
		map_select = false
		open_loadout_select(online_mode)

func draw_map_select() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	if map_coin_time > 0.0:
		draw_map_coin_toss()
		return
	if map_roulette_time > 0.0:
		draw_map_roulette()
		return
	if map_reveal_time > 0.0:
		draw_map_reveal()
		return
	var font := ThemeDB.fallback_font
	draw_centered("ELIGE EL MAPA", Vector2(960, 105), 46, Color("72d2c8"))
	draw_centered("Vota tu campo de batalla" if online_mode else "Selecciona el campo de batalla", Vector2(960, 155), 22, Color("d9eef4"))
	for index in range(MapCatalogScript.NAMES.size()):
		var rect := map_card_rect(index)
		var selected := selected_map_vote == index
		draw_style_box(make_box(Color("31546c") if selected else Color("1d4055"), 16), rect)
		draw_texture_rect(MapCatalogScript.TEXTURES[index], Rect2(rect.position + Vector2(15, 15), Vector2(300, 180)), false)
		draw_string(font, rect.position + Vector2(345, 78), MapCatalogScript.NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, 410, 29, Color.WHITE)
		draw_string(font, rect.position + Vector2(345, 120), "Ruta única · Defensa vertical", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("bdd1de"))
		draw_string(font, rect.position + Vector2(345, 165), "ELEGIDO" if selected else "Clic para votar", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f4d66d") if selected else Color("9ebfcf"))
	var random_selected := selected_map_vote == MapCatalogScript.NAMES.size()
	draw_style_box(make_box(Color("72559a") if random_selected else Color("3a3152"), 14), map_random_rect())
	draw_centered("MAPA ALEATORIO  ·  %s" % ("ELEGIDO" if random_selected else "Clic para elegir"), Vector2(960, 830), 25, Color.WHITE)
	var ready_enabled := selected_map_vote >= 0
	draw_style_box(make_box(Color("4bba83") if ready_enabled else Color("355b70"), 12), map_ready_rect())
	draw_centered("LISTO" if not map_ready else "ESPERANDO RIVAL", Vector2(960, 948), 26, Color.WHITE)
	if online_mode:
		draw_centered("Rival listo" if rival_map_ready else "El rival aún está votando", Vector2(960, 1000), 19, Color("f4d66d"))
	draw_style_box(make_box(Color("294a60"), 10), Rect2(40, 970, 180, 62))
	draw_string(font, Vector2(84, 1010), "VOLVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

func draw_map_reveal() -> void:
	var pulse := 1.0 + sin(map_resolution_spin * 8.0) * 0.025
	var size := Vector2(1100, 620) * pulse
	var rect := Rect2(Vector2(960, 480) - size / 2.0, size)
	draw_centered(map_resolution_label, Vector2(960, 125), 28, Color("f4d66d"))
	draw_texture_rect(current_map_texture(), rect, false)
	draw_style_box(make_box(Color(0.03, 0.08, 0.13, 0.88), 14), Rect2(610, 810, 700, 105))
	draw_centered(MapCatalogScript.NAMES[active_map], Vector2(960, 875), 42, Color.WHITE)

func draw_map_coin_toss() -> void:
	var landing := map_coin_time < 0.55
	var face_is_heads := map_coin_heads if landing else sin(map_coin_spin * 19.0) >= 0.0
	var width_scale := 1.0 if landing else maxf(0.14, absf(cos(map_coin_spin * 19.0)))
	var local_vote := map_coin_host_vote if multiplayer.is_server() else map_coin_join_vote
	var rival_vote := map_coin_join_vote if multiplayer.is_server() else map_coin_host_vote
	draw_centered("LANZAMIENTO DE MONEDA", Vector2(960, 150), 42, Color("f4d66d"))
	draw_centered("Cara: mapa del anfitrión · Cruz: mapa del jugador unido", Vector2(960, 205), 20, Color("d9eef4"))
	draw_map_coin_vote_card(Rect2(70, 315, 570, 330), local_vote, "TU MAPA", Color("72d2c8"))
	draw_map_coin_vote_card(Rect2(1280, 315, 570, 330), rival_vote, "MAPA RIVAL", Color("ffaaa0"))
	draw_set_transform(Vector2(960, 470), 0.0, Vector2(width_scale, 1.0))
	draw_circle(Vector2.ZERO, 145.0, Color("f4c75d"))
	draw_circle(Vector2.ZERO, 128.0, Color("d99235"))
	draw_circle(Vector2.ZERO, 111.0, Color("f8d77a"))
	if width_scale > 0.28:
		if face_is_heads:
			# Anverso: un rostro grabado en la moneda.
			draw_circle(Vector2(-38, -22), 12, Color("6a4523"))
			draw_circle(Vector2(38, -22), 12, Color("6a4523"))
			draw_circle(Vector2(-38, -22), 4, Color("f8d77a"))
			draw_circle(Vector2(38, -22), 4, Color("f8d77a"))
			draw_arc(Vector2(0, 8), 52, 0.18, PI - 0.18, 18, Color("6a4523"), 9.0)
			draw_line(Vector2(-58, -62), Vector2(0, -78), Color("6a4523"), 8.0)
			draw_line(Vector2(0, -78), Vector2(58, -62), Color("6a4523"), 8.0)
		else:
			# Reverso: una cruz naval grabada.
			draw_line(Vector2(0, -72), Vector2(0, 72), Color("6a4523"), 19.0)
			draw_line(Vector2(-58, -20), Vector2(58, -20), Color("6a4523"), 19.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if landing:
		draw_centered("%s · %s" % ["CARA" if map_coin_heads else "CRUZ", MapCatalogScript.NAMES[map_coin_host_vote if map_coin_heads else map_coin_join_vote]], Vector2(960, 720), 28, Color.WHITE)

func draw_map_coin_vote_card(rect: Rect2, map_index: int, label: String, accent: Color) -> void:
	var safe_index := clampi(map_index, 0, MapCatalogScript.NAMES.size() - 1)
	draw_style_box(make_box(Color("18354a"), 14), rect)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8)), accent)
	draw_centered(label, Vector2(rect.get_center().x, rect.position.y + 37), 20, accent)
	draw_texture_rect(MapCatalogScript.TEXTURES[safe_index], Rect2(rect.position + Vector2(22, 58), Vector2(rect.size.x - 44, 205)), false)
	draw_centered(MapCatalogScript.NAMES[safe_index], Vector2(rect.get_center().x, rect.end.y - 30), 24, Color.WHITE)

func draw_map_roulette() -> void:
	var landing := map_roulette_time < 0.55
	var display_index := map_roulette_result if landing else int(floor(map_roulette_spin * 11.0)) % MapCatalogScript.NAMES.size()
	draw_centered("RULETA DE MAPAS", Vector2(960, 135), 44, Color("f4d66d"))
	draw_centered("El mapa aleatorio decidirá el campo de batalla", Vector2(960, 190), 20, Color("d9eef4"))
	for index in range(MapCatalogScript.NAMES.size()):
		var angle := -PI * 0.5 + index * TAU / MapCatalogScript.NAMES.size()
		var center := Vector2(960, 490) + Vector2(cos(angle), sin(angle)) * 225.0
		var selected := index == display_index
		draw_style_box(make_box(Color("486d91") if selected else Color("1d4055"), 13), Rect2(center - Vector2(150, 105), Vector2(300, 210)))
		draw_texture_rect(MapCatalogScript.TEXTURES[index], Rect2(center - Vector2(135, 86), Vector2(270, 150)), false)
		draw_centered(MapCatalogScript.NAMES[index], center + Vector2(0, 95), 18, Color("f4d66d") if selected else Color.WHITE)
	draw_circle(Vector2(960, 490), 58, Color("f4c75d"))
	draw_circle(Vector2(960, 490), 43, Color("d99235"))
	draw_centered("▼", Vector2(960, 267), 32, Color.WHITE)
	if landing:
		draw_centered("ELEGIDO: " + MapCatalogScript.NAMES[map_roulette_result], Vector2(960, 860), 30, Color.WHITE)

func open_loadout_select(is_online: bool) -> void:
	mode_selected = false
	loadout_select = true
	online_mode = is_online
	chosen_towers.clear()
	random_tower = -1
	roulette_display = -1
	roulette_time = 0.0
	roulette_rolls_left = 2
	all_random_roulette_time = 0.0
	all_random_reveal_time = 0.0
	all_random_slots = [-1, -1, -1, -1]
	all_random_results.clear()
	all_random_rolls_left = 3
	loadout_scroll_row = 0
	loadout_ready = false
	rival_ready = false

func handle_loadout_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hover_loadout_tower = loadout_tower_at(event.position)
		queue_redraw()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		loadout_select = false
		online_lobby = online_mode
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			loadout_scroll_row = max(0, loadout_scroll_row - 1)
			queue_redraw()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			loadout_scroll_row = mini(loadout_max_scroll_row(), loadout_scroll_row + 1)
			queue_redraw()
			return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if all_random_roulette_time > 0.0 or all_random_reveal_time > 0.0:
		return
	var design_position: Vector2 = event.position
	if Rect2(40, 950, 180, 62).has_point(design_position):
		loadout_select = false
		online_lobby = online_mode
		return
	for kind in range(TOWER_NAMES.size()):
		if Rect2(40, 270, 1360, 535).has_point(design_position) and loadout_card_rect(kind).has_point(design_position):
			if random_tower >= 0 or roulette_time > 0.0:
				return
			if kind in chosen_towers:
				chosen_towers.erase(kind)
			elif chosen_towers.size() < 3 and not loadout_ready:
				chosen_towers.append(kind)
			queue_redraw()
			return
	if Rect2(1480, 690, 300, 70).has_point(design_position) and roulette_rolls_left > 0 and roulette_time <= 0.0:
		start_roulette()
		queue_redraw()
		return
	if all_random_button_rect().has_point(design_position) and all_random_rolls_left > 0 and roulette_time <= 0.0 and not loadout_ready:
		start_all_random_roulette()
		queue_redraw()
		return
	if Rect2(760, 865, 400, 76).has_point(design_position) and chosen_towers.size() == 3 and random_tower >= 0:
		loadout_ready = true
		if online_mode:
			if multiplayer.is_server():
				rpc_rival_ready_indicator.rpc()
				try_start_online_match()
			else:
				rpc_loadout_ready.rpc_id(1)
		else:
			start_match_after_loadout()
		queue_redraw()

func start_roulette() -> void:
	if chosen_towers.size() < 3:
		return
	roulette_rolls_left -= 1
	roulette_time = 1.25
	roulette_tick = 0.0
	random_tower = -1
	if game_sound:
		game_sound.play_roulette_effect(roulette_time)

func update_roulette(delta: float) -> void:
	if all_random_roulette_time > 0.0:
		all_random_roulette_time -= delta
		all_random_roulette_tick -= delta
		if all_random_roulette_tick <= 0.0:
			all_random_roulette_tick = 0.07 + maxf(0.0, 1.75 - all_random_roulette_time) * 0.08
			all_random_slots = random_unique_towers(4)
		if all_random_roulette_time <= 0.0:
			all_random_slots = all_random_results.duplicate()
			chosen_towers.clear()
			for slot in range(3):
				chosen_towers.append(all_random_results[slot])
			random_tower = all_random_results[3]
			roulette_display = random_tower
			roulette_rolls_left = 1
			all_random_reveal_time = 1.0
			if game_sound:
				game_sound.play_loadout_complete_effect()
	elif all_random_reveal_time > 0.0:
		all_random_reveal_time -= delta
	if roulette_time <= 0.0:
		return
	roulette_time -= delta
	roulette_tick -= delta
	if roulette_tick <= 0.0:
		roulette_tick = 0.09 + max(0.0, 1.15 - roulette_time) * 0.09
		var options: Array[int] = []
		for kind in range(TOWER_NAMES.size()):
			if kind not in chosen_towers:
				options.append(kind)
		if not options.is_empty():
			roulette_display = options[rng.randi_range(0, options.size() - 1)]
	if roulette_time <= 0.0:
		random_tower = roulette_display

func random_unique_towers(count: int) -> Array[int]:
	var available: Array[int] = []
	for kind in range(TOWER_NAMES.size()):
		available.append(kind)
	var result: Array[int] = []
	for _slot in range(mini(count, available.size())):
		var pick := rng.randi_range(0, available.size() - 1)
		result.append(available[pick])
		available.remove_at(pick)
	return result

func start_all_random_roulette() -> void:
	if all_random_rolls_left <= 0:
		return
	all_random_rolls_left -= 1
	all_random_results = random_unique_towers(4)
	all_random_slots = random_unique_towers(4)
	all_random_roulette_time = 1.9
	all_random_roulette_tick = 0.0
	all_random_reveal_time = 0.0
	if game_sound:
		game_sound.play_roulette_effect(all_random_roulette_time)

@rpc("any_peer", "reliable")
func rpc_loadout_ready() -> void:
	if multiplayer.is_server():
		rival_ready = true
		try_start_online_match()

@rpc("any_peer", "reliable")
func rpc_rival_ready_indicator() -> void:
	rival_ready = true

func try_start_online_match() -> void:
	if loadout_ready and rival_ready:
		rpc_start_online_match.rpc()

@rpc("any_peer", "call_local", "reliable")
func rpc_start_online_match() -> void:
	start_match_after_loadout()

func start_match_after_loadout() -> void:
	loadout_select = false
	mode_selected = true
	match_elapsed = 0.0
	local_wave_finished = false
	rival_wave_finished = false
	if online_mode and multiplayer.is_server():
		online_wave_start_timer = 7.0
	elif not multiplayer_mode:
		auto_wave_timer = 7.0
	queue_redraw()

func draw_match_timer() -> void:
	var total_seconds := maxi(0, int(floor(match_elapsed)))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	var timer_text := "%02d:%02d" % [minutes, seconds]
	var rect := Rect2(820, 34, 280, 70)
	draw_style_box(make_box(Color(0.06, 0.12, 0.20, 0.94), 12), rect)
	draw_centered(timer_text, rect.get_center() + Vector2(0, 12), 34, Color("f4d66d"))
	var wave_rect := Rect2(850, 112, 220, 38)
	draw_style_box(make_box(Color(0.12, 0.25, 0.34, 0.94), 9), wave_rect)
	draw_centered("OLEADA %d" % wave, wave_rect.get_center() + Vector2(0, 6), 18, Color.WHITE)

func draw_match_profile_badge(rect: Rect2, display_name: String, avatar: int, accent: Color, name_on_left: bool) -> void:
	draw_circle(rect.get_center(), 39, accent.darkened(0.45))
	draw_texture_rect(profile_avatar_texture(avatar), rect, false)
	var name_rect := Rect2(rect.position.x - 170, rect.position.y + 20, 155, 30) if name_on_left else Rect2(rect.end.x + 15, rect.position.y + 20, 155, 30)
	draw_string(ThemeDB.fallback_font, name_rect.position, display_name, HORIZONTAL_ALIGNMENT_RIGHT if name_on_left else HORIZONTAL_ALIGNMENT_LEFT, name_rect.size.x, 20, accent)

func draw_loadout_select() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color("102536"))
	draw_centered("ELIGE 3 TORRES + 1 ALEATORIA", Vector2(960, 170), 42, Color("72d2c8"))
	draw_centered("%d / 3 seleccionadas · Ruleta: %d tiradas" % [chosen_towers.size(), roulette_rolls_left], Vector2(960, 225), 24, Color("d9eef4"))
	var font := ThemeDB.fallback_font
	draw_loadout_category_headers(font)
	for kind in range(TOWER_NAMES.size()):
		var rect := loadout_card_rect(kind)
		if not Rect2(40, 270, 1360, 535).intersects(rect):
			continue
		var selected := kind in chosen_towers
		draw_style_box(make_box(Color("31546c") if selected else Color("1d4055"), 16), rect)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 7)), TowerCatalogScript.category_color(kind))
		draw_texture_rect(tower_texture_for(kind), Rect2(rect.position + Vector2(24, 30), Vector2(125, 125)), false)
		draw_string(font, rect.position + Vector2(160, 75), TOWER_NAMES[kind], HORIZONTAL_ALIGNMENT_LEFT, 120, 20, Color.WHITE)
		draw_string(font, rect.position + Vector2(160, 112), "$ %d" % TOWER_COSTS[kind], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffd76a"))
		draw_string(font, rect.position + Vector2(24, 190), "Daño %d · Recarga %.2f s" % [tower_config(kind).damage, tower_config(kind).reload], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9eef4"))
		draw_string(font, rect.position + Vector2(24, 220), "Alcance %d" % tower_config(kind).range, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("bdd1de"))
		draw_tower_category_line(rect.position + Vector2(180, 220), kind, 12)
	if loadout_max_scroll_row() > 0:
		draw_style_box(make_box(Color("294a60"), 9), Rect2(1822, 430, 60, 116))
		draw_centered("▲", Vector2(1852, 460), 20, Color.WHITE)
		draw_centered("▼", Vector2(1852, 505), 20, Color.WHITE)
		draw_string(font, Vector2(1827, 534), "Rueda", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("bdd1de"))
	draw_random_slot(font)
	var all_random_enabled := roulette_time <= 0.0 and not loadout_ready and all_random_rolls_left > 0
	draw_style_box(make_box(Color("b06b9b") if all_random_enabled else Color("4c4160"), 10), all_random_button_rect())
	draw_centered("TODO ALEATORIO (%d)" % all_random_rolls_left, all_random_button_rect().get_center() + Vector2(0, 7), 19, Color.WHITE)
	var ready_color := Color("4bba83") if chosen_towers.size() == 3 and random_tower >= 0 else Color("355b70")
	draw_style_box(make_box(ready_color, 12), Rect2(760, 865, 400, 76))
	draw_centered("PREPARADO" if not loadout_ready else "ESPERANDO RIVAL", Vector2(960, 913), 25, Color.WHITE)
	if online_mode:
		draw_centered("Rival preparado" if rival_ready else "Esperando a que el rival elija sus torres", Vector2(960, 965), 19, Color("f4d66d"))
	draw_style_box(make_box(Color("294a60"), 10), Rect2(40, 950, 180, 62))
	draw_string(font, Vector2(84, 990), "VOLVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_centered("Esc: volver", Vector2(960, 1030), 17, Color("bdd1de"))
	draw_loadout_tower_tooltip()
	if all_random_roulette_time > 0.0 or all_random_reveal_time > 0.0:
		draw_all_random_roulette()

func draw_loadout_category_headers(font: Font) -> void:
	var names := ["TIRADORES", "VERSÁTILES", "CONTROLADORES", "APOYO"]
	var icons := ["⌖", "◆", "⌂", "+"]
	for category in range(4):
		var rect := Rect2(45 + category * 345, 250, 310, 28)
		var color: Color = TowerCatalogScript.CATEGORY_COLORS[category]
		draw_style_box(make_box(color.darkened(0.55), 7), rect)
		draw_string(font, rect.position + Vector2(14, 20), "%s  %s" % [icons[category], names[category]], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color.lightened(0.25))
		if category == 0:
			draw_string(font, rect.position + Vector2(182, 20), "Próximamente", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("d8b7b7"))

func draw_loadout_tower_tooltip() -> void:
	if hover_loadout_tower < 0 or hover_loadout_tower >= TOWER_NAMES.size():
		return
	var rect := Rect2(1430, 55, 440, 215)
	var descriptions := [
		"Dardos fiables para responder a cualquier amenaza.",
		"Una órbita perforante para golpear varias veces.",
		"Bombas de área ideales contra grupos.",
		"Rayos arcanos que saltan entre enemigos.",
		"Flechas místicas perforantes de largo alcance.",
		"Produce bananas para financiar tu defensa.",
		"Recupera vidas y mantiene tu frente estable.",
		"Un sable que barre globos a corta distancia.",
		"Siembra púas permanentes a lo largo del camino."
	]
	var kind := hover_loadout_tower
	draw_style_box(make_box(Color(0.06, 0.13, 0.19, 0.98), 12), rect)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 34), TOWER_NAMES[kind], HORIZONTAL_ALIGNMENT_LEFT, -1, 23, TOWER_COLORS[kind])
	draw_tower_category_line(rect.position + Vector2(18, 64), kind, 16)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 101), descriptions[kind], HORIZONTAL_ALIGNMENT_LEFT, 400, 16, Color("d9eef4"))
	var config := tower_config(kind)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 143), "Coste $%d · Daño %d · Alcance %d" % [TOWER_COSTS[kind], config.damage, config.range], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("ffd76a"))
	var action_text := "Recarga %.2f s" % config.reload if config.reload > 0.0 else "Generación especial"
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 173), action_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("bdd1de"))
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(18, 201), "Visión térmica: %s" % ("SÍ" if config.thermal_vision else "NO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f4d66d") if config.thermal_vision else Color("9ebfcf"))

func loadout_card_rect(kind: int) -> Rect2:
	var ordered_kinds := [0, 1, 2, 3, 4, 7, 8, 5, 6]
	var display_index: int = ordered_kinds.find(kind)
	var column: int = display_index % 4
	var row: int = display_index / 4
	return Rect2(45 + column * 345, 285 + (row - loadout_scroll_row) * 275, 310, 240)

func loadout_tower_at(position: Vector2) -> int:
	if not Rect2(40, 270, 1360, 535).has_point(position):
		return -1
	for kind in range(TOWER_NAMES.size()):
		if loadout_card_rect(kind).has_point(position):
			return kind
	return -1

func loadout_max_scroll_row() -> int:
	var rows := int(ceili(float(TOWER_NAMES.size()) / 4.0))
	return max(0, rows - 2)

func all_random_button_rect() -> Rect2:
	return Rect2(1430, 780, 390, 62)

func draw_all_random_roulette() -> void:
	draw_rect(Rect2(0, 0, WIDTH, HEIGHT), Color(0.02, 0.04, 0.10, 0.80))
	var panel := Rect2(330, 340, 1260, 390)
	draw_style_box(make_box(Color("182c42"), 18), panel)
	draw_centered("RULETA: TODAS LAS TORRES", Vector2(960, 410), 34, Color("f4d66d"))
	draw_centered("Cuatro torres distintas seleccionadas al azar", Vector2(960, 450), 18, Color("d9eef4"))
	for slot in range(4):
		var rect := Rect2(375 + slot * 300, 495, 255, 175)
		var kind: int = all_random_slots[slot] if slot < all_random_slots.size() else -1
		draw_style_box(make_box(Color("70518b") if all_random_roulette_time > 0.0 else Color("4b9b78"), 13), rect)
		draw_centered(str(slot + 1), rect.position + Vector2(24, 30), 16, Color("f4d66d"))
		if kind >= 0:
			draw_texture_rect(tower_texture_for(kind), Rect2(rect.position + Vector2(18, 43), Vector2(105, 105)), false)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(135, 86), TOWER_NAMES[kind], HORIZONTAL_ALIGNMENT_LEFT, 105, 19, Color.WHITE)
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(135, 120), "$ %d" % TOWER_COSTS[kind], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("ffd76a"))
	if all_random_reveal_time > 0.0:
		draw_centered("¡SELECCIÓN COMPLETA!", Vector2(960, 705), 24, Color("8ff0b1"))

func draw_random_slot(font: Font) -> void:
	var rect := Rect2(1430, 350, 390, 290)
	draw_style_box(make_box(Color("3a3152"), 16), rect)
	draw_string(font, rect.position + Vector2(25, 45), "4ª TORRE ALEATORIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("f4d66d"))
	if roulette_display >= 0:
		draw_texture_rect(tower_texture_for(roulette_display), Rect2(rect.position + Vector2(30, 72), Vector2(115, 115)), false)
		draw_string(font, rect.position + Vector2(165, 120), TOWER_NAMES[roulette_display], HORIZONTAL_ALIGNMENT_LEFT, 190, 21, Color.WHITE)
		draw_string(font, rect.position + Vector2(165, 156), "$ %d" % TOWER_COSTS[roulette_display], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffd76a"))
	else:
		draw_centered("?", rect.get_center() + Vector2(0, 12), 86, Color("9a7ee8"))
	var can_roll := chosen_towers.size() == 3 and roulette_rolls_left > 0 and roulette_time <= 0.0
	var button_color := Color("8a5db6") if can_roll else Color("4c4160")
	draw_style_box(make_box(button_color, 10), Rect2(1480, 690, 300, 70))
	draw_centered("ROLL (%d)" % roulette_rolls_left if chosen_towers.size() == 3 else "ELIGE 3 TORRES", Vector2(1630, 734), 24 if chosen_towers.size() == 3 else 18, Color.WHITE)

func draw_local_lightning() -> void:
	draw_lightning_effects(local_arena_origin(), lightning_effects, local_arena_scale())

func draw_remote_lightning() -> void:
	draw_lightning_effects(Vector2(960, 270), rival_lightning_effects)

func draw_lightning_effects(origin: Vector2, effects: Array, scale := Vector2(0.75, 0.75)) -> void:
	draw_set_transform(origin, 0.0, scale)
	for effect in effects:
		var points: Array = effect.points
		for i in range(points.size() - 1):
			draw_line(points[i], points[i + 1], Color("d8f5ff"), 5.0)
			draw_line(points[i], points[i + 1], Color("70cfff"), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_tower_button(rect: Rect2, kind: int, slot: int) -> void:
	var active := placement_tower == kind
	var hovered := hover_tower == kind
	var fill := Color("6f353d") if money < TOWER_COSTS[kind] else Color("31546c") if active else Color("294a60") if hovered else Color("1d4055")
	draw_style_box(make_box(fill, 12), rect)
	# Número del atajo de teclado, visible en la esquina superior izquierda.
	draw_style_box(make_box(Color("142b3b"), 7), Rect2(rect.position + Vector2(8, 8), Vector2(28, 28)))
	draw_centered(str(slot + 1), rect.position + Vector2(22, 31), 17, Color("ffd76a"))
	var tower_texture = tower_texture_for(kind)
	draw_texture_rect(tower_texture, Rect2(rect.position + Vector2((rect.size.x - 92) / 2.0, 10), Vector2(92, 92)), false)
	var font := ThemeDB.fallback_font
	var price_text := "$ %d" % TOWER_COSTS[kind]
	var price_width := font.get_string_size(price_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_string(font, rect.position + Vector2((rect.size.x - price_width) / 2.0, 125), price_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("ffd76a"))
	draw_string(font, rect.position + Vector2(32, 145), "Clic para colocar", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("bdd1de"))

func draw_tower_ability_button(rect: Rect2, kind: int) -> void:
	var ability: Dictionary = TowerCatalogScript.ability_data(kind)
	var remaining: float = float(tower_ability_cooldowns.get(kind, 0.0))
	var ready := remaining <= 0.0
	var fill := TowerCatalogScript.category_color(kind).darkened(0.32) if ready else Color("394653")
	draw_style_box(make_box(fill, 8), rect)
	var text := str(ability.name).to_upper() if ready else "ENFRIAMIENTO %.1f s" % remaining
	draw_centered(text, rect.get_center() + Vector2(0, 6), 13, Color.WHITE if ready else Color("c4ccd1"))

func draw_tower_ability_notice() -> void:
	if tower_ability_notice_time <= 0.0:
		return
	var alpha: float = clampf(tower_ability_notice_time / 0.5, 0.0, 1.0)
	var rect := Rect2(670, 225, 580, 42)
	draw_style_box(make_box(Color(0.14, 0.34, 0.42, 0.94 * alpha), 10), rect)
	draw_centered(tower_ability_notice + " · efecto futuro", rect.get_center() + Vector2(0, 6), 17, Color(0.85, 0.98, 1.0, alpha))

func draw_duel_tabs(font: Font) -> void:
	var char_color := Color("31546c") if active_duel_tab == 0 else Color("1d4055")
	var balloon_color := Color("31546c") if active_duel_tab == 1 else Color("1d4055")
	draw_style_box(make_box(char_color, 9), Rect2(22, 790, 210, 52))
	draw_style_box(make_box(balloon_color, 9), Rect2(242, 790, 210, 52))
	draw_string(font, Vector2(52, 823), "PERSONAJES", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
	draw_string(font, Vector2(264, 823), "ENVIAR GLOBOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)

func draw_balloon_send_buttons(font: Font) -> void:
	var options := send_options()
	var colors := [Color.WHITE, Color("478fe4"), Color("f5d35d"), Color("a97cdd"), Color("7bd4bf"), Color("ee8f54"), Color("773b68"), Color("f5f7ff"), Color("33435f"), Color("f09fdb")]
	var visible_area := Rect2(18, 845, 700, 220)
	for index in range(options.size()):
		var option: Dictionary = options[index]
		var rect := balloon_send_rect(index)
		if not visible_area.intersects(rect):
			continue
		var unlocked: bool = wave >= option.unlock
		var fill := Color("4c515a") if send_cooldown > 0.0 else Color("6f353d") if unlocked and money < option.cost else Color("1d4055") if unlocked else Color("4c515a")
		draw_style_box(make_box(fill, 10), rect)
		var icon_color: Color = Color("d6b89a") if option.get("ceramic", false) else Color("9a7ee8") if option.get("magic_shield", false) else Color("778b98") if option.get("armored", false) else Color("3f83ba") if option.get("moab", false) else colors[clampi(option.tier, 1, colors.size() - 1)]
		if not unlocked: icon_color = icon_color.darkened(0.65)
		draw_circle(rect.position + Vector2(38, 45), 24, icon_color)
		draw_string(font, rect.position + Vector2(72, 31), option.label, HORIZONTAL_ALIGNMENT_LEFT, 130, 15, Color.WHITE if unlocked else Color("b2b6bb"))
		draw_string(font, rect.position + Vector2(72, 57), "%d × nivel %d · $%d" % [option.count, option.tier, option.cost], HORIZONTAL_ALIGNMENT_LEFT, 135, 14, Color("ffd76a") if unlocked else Color("a4a4a4"))
		var benefit_color := Color("ff8d8d") if option.benefit < 0 and unlocked else Color("8ce1f1") if unlocked else Color("9ca0a4")
		var benefit_text := "%+d beneficios" % int(option.benefit)
		draw_string(font, rect.position + Vector2(72, 82), benefit_text, HORIZONTAL_ALIGNMENT_LEFT, 135, 13, benefit_color)
		if not unlocked:
			draw_circle(rect.position + Vector2(38, 45), 14, Color("30343a"))
			draw_string(font, rect.position + Vector2(31, 52), "🔒", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
			draw_string(font, rect.position + Vector2(12, 94), "Oleada %d" % option.unlock, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("d4d4d4"))
		elif send_cooldown > 0.0:
			draw_string(font, rect.position + Vector2(12, 94), "Enfriamiento %.1f s" % send_cooldown, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("d4d4d4"))
	var rows := ceili(float(options.size()) / 3.0)
	if rows > 2:
		draw_style_box(make_box(Color("294a60"), 8), Rect2(724, 875, 70, 82))
		draw_centered("▲", Vector2(759, 902), 20, Color.WHITE)
		draw_centered("▼", Vector2(759, 938), 20, Color.WHITE)
		draw_string(font, Vector2(728, 956), "Rueda", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("bdd1de"))

func draw_inspected_tower_menu() -> void:
	if inspected_tower_index < 0 or inspected_tower_index >= towers.size() or not (online_mode or solo_modern_mode):
		return
	var tower: Dictionary = towers[inspected_tower_index]
	var kind: int = clampi(int(tower.get("type", 0)), 0, TOWER_NAMES.size() - 1)
	var font := ThemeDB.fallback_font
	var menu_offset := inspected_menu_offset()
	var panel := Rect2(Vector2(970, 760) + menu_offset, Vector2(540, 270))
	draw_style_box(make_box(Color(0.06, 0.14, 0.20, 0.97), 14), panel)
	draw_texture_rect(tower_texture_for(kind), Rect2(Vector2(995, 790) + menu_offset, Vector2(88, 88)), false)
	draw_string(font, panel.position + Vector2(125, 110), "Visión térmica: %s" % ("SÍ" if tower.get("thermal_vision", false) else "NO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f4d66d") if tower.get("thermal_vision", false) else Color("9ebfcf"))
	draw_string(font, Vector2(1100, 810) + menu_offset, TOWER_NAMES[kind], HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color.WHITE)
	draw_tower_category_line(Vector2(1100, 786) + menu_offset, kind, 15)
	var primary_stat := "Daño %d" % tower.damage
	if kind == 6:
		primary_stat = "Curación %d" % int(tower.get("heal_amount", 8))
	elif kind == 5:
		primary_stat = "Banana $%d" % int(tower.get("banana_value", 30))
	var timing_label := "Velocidad de ataque"
	if kind == 6:
		timing_label = "Velocidad de casteo"
	elif kind == 5 or kind == 8:
		timing_label = "Generación"
	var timing_rate: float = float(tower.get("action_rate", 1.0 / float(tower.get("reload", 1.0)) if float(tower.get("reload", 0.0)) > 0.0 else 0.0))
	draw_string(font, Vector2(1100, 842) + menu_offset, "%s · Alcance %d · %s %.2f/s" % [primary_stat, tower.range, timing_label, timing_rate], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("bdd1de"))
	if kind != 5 and kind != 6 and kind != 8:
		var target_modes := ["PRIMERO", "ÚLTIMO", "MÁS FUERTE", "MÁS DÉBIL"]
		var target_mode: int = int(tower.get("target_mode", 0))
		draw_string(font, Vector2(995, 877) + menu_offset, "OBJETIVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9ebfcf"))
		draw_style_box(make_box(Color("294a60"), 8), Rect2(Vector2(1195, 840) + menu_offset, Vector2(42, 36)))
		draw_style_box(make_box(Color("294a60"), 8), Rect2(Vector2(1405, 840) + menu_offset, Vector2(42, 36)))
		draw_string(font, Vector2(1208, 867) + menu_offset, "‹", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color.WHITE)
		draw_string(font, Vector2(1418, 867) + menu_offset, "›", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color.WHITE)
		draw_centered(target_modes[target_mode], Vector2(1321, 866) + menu_offset, 17, Color("f4d66d"))
	draw_string(font, Vector2(995, 896) + menu_offset, "Daño total: %d   ·   Globos explotados: %d" % [int(tower.get("damage_dealt", 0)), int(tower.get("bloons_popped", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
	if kind == 6 or kind == 5:
		draw_rect(Rect2(Vector2(990, 875) + menu_offset, Vector2(500, 30)), Color(0.06, 0.14, 0.20, 1.0))
		var support_stat := "Curación total: %d" % int(tower.get("effective_healing", 0)) if kind == 6 else "Dinero recogido: $%d" % int(tower.get("banana_money_collected", 0))
		draw_string(font, Vector2(995, 896) + menu_offset, support_stat, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("d9eef4"))
	var branches: Array = TowerCatalogScript.upgrade_branches(kind)
	var levels: Array = tower.get("branch_levels", [0, 0, 0])
	var primary_branch: int = int(tower.get("primary_branch", -1))
	var secondary_branch: int = int(tower.get("secondary_branch", -1))
	var used_branches := 0
	for branch_level in levels:
		if int(branch_level) > 0:
			used_branches += 1
	for branch in range(3):
		var rect := inspected_upgrade_rect(branch)
		var level: int = int(levels[branch])
		var role := "PRINCIPAL" if branch == primary_branch else "SECUNDARIA" if branch == secondary_branch else "ELEGIR"
		var max_level: int = 5 if branch == primary_branch else 2 if branch == secondary_branch else 3
		var next_cost := 0
		if level < mini(max_level, branches[branch].levels.size()):
			next_cost = int(branches[branch].levels[level].get("cost", 0))
		var maxed := level >= max_level
		var secondary_limited := maxed and branch == secondary_branch
		var locked := not maxed and ((level == 0 and used_branches >= 2) or (primary_branch >= 0 and branch != primary_branch and secondary_branch >= 0 and branch != secondary_branch))
		var color := Color("50352b") if secondary_limited else Color("d1a83b") if maxed else Color("4c515a") if locked else Color("6f353d") if next_cost > money else Color("3f986c")
		draw_style_box(make_box(color, 8), rect)
		if maxed and not secondary_limited:
			draw_arc(rect.get_center(), 27.0, 0.0, TAU, 20, Color("fff1a3"), 2.0)
		draw_centered(str(branches[branch].name), rect.get_center() + Vector2(0, -8), 15, Color.WHITE)
		draw_centered("Límite Alcanzado" if secondary_limited else "Máximo Nivel" if maxed else "🔒 BLOQUEADA" if locked else "%s %d/%d" % [role, level, max_level], rect.get_center() + Vector2(0, 14), 12, Color("d8b49e") if secondary_limited else Color("fff1a3") if maxed else Color("d9eef4"))
	if hover_upgrade_branch >= 0 and hover_upgrade_branch < branches.size():
		var hover_level: int = int(levels[hover_upgrade_branch])
		if hover_level < branches[hover_upgrade_branch].levels.size():
			var preview: Dictionary = branches[hover_upgrade_branch].levels[hover_level]
			var tip := Rect2(Vector2(970, 680) + menu_offset, Vector2(500, 72))
			draw_style_box(make_box(Color(0.05, 0.12, 0.18, 0.97), 10), tip)
			draw_string(font, tip.position + Vector2(16, 25), "%s · $%d" % [str(preview.get("name", "Mejora")), int(preview.get("cost", 0))], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffd76a"))
			draw_string(font, tip.position + Vector2(16, 52), str(preview.get("description", "Mejora de torre")), HORIZONTAL_ALIGNMENT_LEFT, 470, 15, Color.WHITE)
	var refund: int = int(round(float(tower.get("cost", 0)) * 0.6))
	draw_style_box(make_box(Color("843d45"), 9), Rect2(Vector2(1300, 965) + menu_offset, Vector2(145, 58)))
	draw_string(font, Vector2(1320, 1001) + menu_offset, "VENDER $%d" % refund, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	draw_string(font, Vector2(1470, 819) + menu_offset, "×", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)

func draw_tower_category_line(position: Vector2, kind: int, size := 16) -> void:
	var category_color: Color = TowerCatalogScript.category_color(kind)
	draw_circle(position + Vector2(9, -6), 10, category_color.darkened(0.25))
	draw_centered(TowerCatalogScript.category_icon(kind), position + Vector2(9, 0), size, Color.WHITE)
	draw_string(ThemeDB.fallback_font, position + Vector2(24, 0), TowerCatalogScript.category_name(kind), HORIZONTAL_ALIGNMENT_LEFT, -1, size, category_color)

func draw_tower_tooltip() -> void:
	if hover_tower < 0:
		return
	var rect := Rect2(1610, 550, 290, 210) if solo_modern_mode else Rect2(970, 820, 480, 210)
	draw_style_box(make_box(Color(0.07, 0.14, 0.20, 0.96), 12), rect)
	var font := ThemeDB.fallback_font
	var config := tower_config(hover_tower)
	var damage: int = config.damage
	var attack_speed := "%.2f s" % config.reload
	var range_value := "%d" % config.range
	draw_tower_category_line(rect.position + Vector2(20, 189), hover_tower, 16)
	draw_string(font, rect.position + Vector2(20, 34), TOWER_NAMES[hover_tower], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, TOWER_COLORS[hover_tower])
	draw_string(font, rect.position + Vector2(20, 67), "Coste: $ %d   ·   Daño: %d" % [TOWER_COSTS[hover_tower], damage], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, rect.position + Vector2(20, 96), "Velocidad de ataque: %s" % attack_speed, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, rect.position + Vector2(20, 125), "Alcance: %s" % range_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("bdd1de"))
	draw_string(font, rect.position + Vector2(20, 154), "Visión térmica: %s" % ("SÍ" if config.thermal_vision else "NO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f4d66d") if config.thermal_vision else Color("9ebfcf"))

func draw_placement_preview() -> void:
	if placement_tower < 0 or not local_arena_rect().has_point(cursor_position):
		return
	var preview_position := (cursor_position - local_arena_origin()) / local_arena_scale()
	var is_valid := can_place_tower(preview_position, placement_tower)
	var tint := Color(1.0, 1.0, 1.0, 0.55) if is_valid else Color(1.0, 0.28, 0.28, 0.62)
	var texture = tower_texture_for(placement_tower)
	draw_set_transform(local_arena_origin(), 0.0, local_arena_scale())
	draw_circle(preview_position, tower_config(placement_tower).range, Color(0.35, 0.75, 1.0, 0.13) if is_valid else Color(1.0, 0.25, 0.25, 0.15))
	draw_texture_rect(texture, Rect2(preview_position - Vector2(34, 34), Vector2(68, 68)), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_inspected_tower_highlight() -> void:
	if inspected_tower_index < 0 or inspected_tower_index >= towers.size() or not (online_mode or solo_modern_mode):
		return
	var tower: Dictionary = towers[inspected_tower_index]
	draw_set_transform(local_arena_origin(), 0.0, local_arena_scale())
	draw_circle(tower.position, tower.range, Color(0.68, 0.70, 0.75, 0.16))
	draw_arc(tower.position, tower.range, 0.0, TAU, 48, Color(0.82, 0.85, 0.90, 0.58), 2.5)
	draw_arc(tower.position, 43.0, 0.0, TAU, 28, Color("f4d66d"), 3.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func tower_texture_for(kind: int):
	var textures := [DART_RANGER_TEXTURE, BOOMERANG_SCOUT_TEXTURE, BOMBARDIER_TEXTURE, LIGHTNING_MAGE_TEXTURE, MYSTIC_ARCHER_TEXTURE, BANANA_FARMER_TEXTURE, REEF_MEDIC_TEXTURE, PIRATE_TEXTURE, PATHCUTTER_TEXTURE]
	return textures[kind]
