class_name GameSound
extends Node

const MENU_TRACK_NAMES := ["Brisa de Coral", "Café del Arrecife", "Atardecer Dorado", "Bahía de Neón"]

const STREAMS := {
	"click": preload("res://assets/audio/ui_click.wav"),
	"place": preload("res://assets/audio/place_tower.wav"),
	"dart": preload("res://assets/audio/dart.wav"),
	"impact": preload("res://assets/audio/impact.wav"),
	"metal": preload("res://assets/audio/impact.wav"),
	"saber": preload("res://assets/audio/dart.wav"),
	"ceramic_hit": preload("res://assets/audio/impact.wav"),
	"ceramic_break": preload("res://assets/audio/impact.wav"),
	"balloon_break": preload("res://assets/audio/impact.wav"),
	"send": preload("res://assets/audio/send_balloon.wav"),
	"win": preload("res://assets/audio/win.wav"),
	"lose": preload("res://assets/audio/impact.wav")
}

var music_player: AudioStreamPlayer
var music_playback: AudioStreamGeneratorPlayback
var music_mode := ""
var music_time := 0.0
var game_track := 0
var menu_track := 0
var music_volume_percent := 100
var effects_volume_percent := 100

func volume_offset(percent: int) -> float:
	return linear_to_db(maxf(0.001, float(clampi(percent, 0, 100)) / 100.0))

func set_music_volume(percent: int) -> void:
	music_volume_percent = clampi(percent, 0, 100)
	if music_player:
		music_player.volume_db = -11.0 + volume_offset(music_volume_percent)

func set_effects_volume(percent: int) -> void:
	effects_volume_percent = clampi(percent, 0, 100)

func effects_volume_offset() -> float:
	return volume_offset(effects_volume_percent)

func set_music(new_mode: String) -> void:
	if music_mode == new_mode:
		return
	music_mode = new_mode
	music_time = 0.0
	if new_mode == "game":
		game_track = randi_range(0, 5)
	if not music_player:
		music_player = AudioStreamPlayer.new()
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = 22050.0
		stream.buffer_length = 0.4
		music_player.stream = stream
		music_player.volume_db = -11.0 + volume_offset(music_volume_percent)
		add_child(music_player)
		music_player.play()
		music_playback = music_player.get_stream_playback()

func set_menu_track(track: int) -> void:
	menu_track = posmod(track, MENU_TRACK_NAMES.size())
	if music_mode == "menu":
		music_time = 0.0

func _process(delta: float) -> void:
	if not music_playback:
		return
	var frames := music_playback.get_frames_available()
	for _frame in range(frames):
		var sample := make_music_sample(music_time)
		music_playback.push_frame(Vector2(sample, sample))
		music_time += 1.0 / 22050.0

func make_music_sample(time: float) -> float:
	var upbeat := music_mode == "game"
	var track: int = game_track if upbeat else menu_track
	var beat: float = [0.42, 0.36, 0.48, 0.32, 0.40, 0.29][track] if upbeat else [0.86, 0.72, 0.94, 0.66][track]
	var step := int(floor(time / beat))
	var chord: float
	var melody_note: float
	match track:
		1:
			chord = [0.0, 7.0, 5.0, 3.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [19.0, 16.0, 14.0, 21.0][step % 4]
		2:
			chord = [0.0, 3.0, 8.0, 5.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [12.0, 15.0, 19.0, 22.0][step % 4]
		3:
			# Fast swing with bright brass-like syncopation.
			chord = [0.0, 10.0, 5.0, 7.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [16.0, 19.0, 14.0, 21.0][step % 4]
		4:
			# Bouncy walking-bass groove.
			chord = [0.0, 4.0, 7.0, 2.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [12.0, 17.0, 20.0, 15.0][step % 4]
		5:
			# Up-tempo club-jazz turnaround.
			chord = [0.0, 3.0, 6.0, 9.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [19.0, 14.0, 22.0, 17.0][step % 4]
		_:
			chord = [0.0, 5.0, 3.0, 7.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [12.0, 16.0, 19.0, 16.0][step % 4]
	var root := 130.81 * pow(2.0, chord / 12.0)
	var pad := sin(TAU * root * time) * 0.12 + sin(TAU * root * 1.5 * time) * 0.045
	var pulse_phase := fposmod(time, beat) / beat
	var pulse_env := pow(maxf(0.0, 1.0 - pulse_phase), 5.0)
	var melody := sin(TAU * root * pow(2.0, melody_note / 12.0) * time) * pulse_env * (0.13 if upbeat else 0.055)
	var bass := sin(TAU * root * 0.5 * time) * (0.11 if upbeat else 0.07)
	return clampf(pad + melody + bass, -0.34, 0.34)

func play_effect(effect: String, volume_db := -8.0) -> void:
	if not STREAMS.has(effect):
		return
	var player := AudioStreamPlayer.new()
	player.stream = STREAMS[effect]
	player.volume_db = volume_db + effects_volume_offset()
	if effect == "metal":
		# A sharper, higher metallic variant of the impact sample.
		player.pitch_scale = 1.65
	elif effect == "saber":
		# Bright electric slash used by magic shields.
		player.pitch_scale = 1.9
	elif effect == "lose":
		player.pitch_scale = 0.55
	elif effect == "ceramic_hit":
		player.pitch_scale = 1.18
	elif effect == "ceramic_break":
		player.pitch_scale = 0.78
	elif effect == "balloon_break":
		player.pitch_scale = 0.92
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func play_debug_effect(effect: String) -> void:
	# Short synthesized cues keep debug actions recognisable without sharing a
	# gameplay sound: pause falls, resume rises and wave-jump is a three-note cue.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.45
	player.stream = stream
	player.volume_db = -4.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.24 if effect == "wave_jump" else 0.16
	var frames := int(duration * stream.mix_rate)
	for frame in range(frames):
		var time := float(frame) / stream.mix_rate
		var progress := time / duration
		var frequency := 240.0
		if effect == "pause":
			frequency = lerpf(520.0, 240.0, progress)
		elif effect == "resume":
			frequency = lerpf(280.0, 680.0, progress)
		elif effect == "wave_jump":
			frequency = [330.0, 440.0, 660.0][mini(2, int(progress * 3.0))]
		var envelope := sin(PI * clampf(progress, 0.0, 1.0))
		var sample := sin(TAU * frequency * time) * envelope * 0.32
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_money_effect() -> void:
	# Bright double chime for a completed tower sale.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.35
	player.stream = stream
	player.volume_db = -5.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.20
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var note := 1046.5 if time < 0.09 else 1318.5
		var local_time := fposmod(time, 0.10)
		var envelope := exp(-local_time * 28.0)
		var sample := (sin(TAU * note * time) + sin(TAU * note * 2.0 * time) * 0.22) * envelope * 0.26
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_upgrade_effect() -> void:
	# Bright ascending arpeggio for a tower upgrade purchase.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.42
	player.stream = stream
	player.volume_db = -4.5 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.27
	var notes := [440.0, 554.37, 659.25]
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var segment := mini(2, int(time / 0.09))
		var local_time := fposmod(time, 0.09)
		var envelope := exp(-local_time * 21.0)
		var sample := (sin(TAU * notes[segment] * time) + sin(TAU * notes[segment] * 2.0 * time) * 0.16) * envelope * 0.28
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_ultimate_upgrade_effect() -> void:
	# Fanfarria ascendente con una campana final para una mejora definitiva.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.70
	player.stream = stream
	player.volume_db = -2.5 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.62
	var notes := [523.25, 659.25, 783.99, 1046.5]
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var note_index := mini(3, int(time / 0.12))
		var local_time := fposmod(time, 0.12)
		var envelope := exp(-local_time * 12.0)
		var note: float = float(notes[note_index])
		var fanfare := sin(TAU * note * time) + sin(TAU * note * 1.5 * time) * 0.22
		var bell := sin(TAU * 2093.0 * time) * 0.28 if time > 0.36 else 0.0
		var final_fade := 1.0 if time < 0.42 else exp(-(time - 0.42) * 6.0)
		var sample := (fanfare * 0.30 * envelope + bell) * final_fade
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.10).timeout.connect(player.queue_free)

func play_error_effect() -> void:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.22
	player.stream = stream
	player.volume_db = -7.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.13
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var envelope := exp(-time * 18.0)
		var sample := (sin(TAU * 135.0 * time) + sin(TAU * 178.0 * time) * 0.35) * envelope * 0.32
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.06).timeout.connect(player.queue_free)

func play_explosion_effect() -> void:
	# Cuerpo grave y chispa corta para las bombas del bombardero.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.30
	player.stream = stream
	player.volume_db = -4.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.24
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var envelope := exp(-time * 15.0)
		var rumble := sin(TAU * lerpf(115.0, 48.0, time / duration) * time)
		var crackle := sin(TAU * 860.0 * time) * exp(-time * 34.0)
		var sample := (rumble * 0.40 + crackle * 0.18) * envelope
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_coin_toss_effect() -> void:
	# Tintineo metÃ¡lico ascendente con un golpe final para el lanzamiento de moneda.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.55
	player.stream = stream
	player.volume_db = -5.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.46
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var ping_time := fposmod(time, 0.105)
		var ping_env := exp(-ping_time * 33.0)
		var spin_frequency := lerpf(980.0, 1480.0, time / duration)
		var ring := sin(TAU * spin_frequency * time) * ping_env
		var shimmer := sin(TAU * spin_frequency * 2.37 * time) * ping_env * 0.24
		var landing := sin(TAU * 180.0 * time) * exp(-(time - 0.36) * 26.0) * 0.38 if time > 0.36 else 0.0
		playback.push_frame(Vector2((ring + shimmer + landing) * 0.22, (ring + shimmer + landing) * 0.22))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_roulette_effect(duration := 1.25) -> void:
	# Pulsos de una ruleta que se van espaciando y terminan con un clic de selecciÃ³n.
	var safe_duration := maxf(0.4, duration)
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = safe_duration + 0.15
	player.stream = stream
	player.volume_db = -7.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	for frame in range(int(safe_duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var progress := time / safe_duration
		var interval := lerpf(0.055, 0.22, progress)
		var tick_time := fposmod(time, interval)
		var envelope := exp(-tick_time * 105.0)
		var frequency := lerpf(1180.0, 620.0, progress)
		var tick := (sin(TAU * frequency * time) + sin(TAU * frequency * 2.0 * time) * 0.18) * envelope
		var final_click := sin(TAU * 175.0 * time) * exp(-(time - safe_duration + 0.08) * 36.0) * 0.45 if time > safe_duration - 0.08 else 0.0
		playback.push_frame(Vector2((tick * 0.20 + final_click) * 0.9, (tick * 0.20 + final_click) * 0.9))
	get_tree().create_timer(safe_duration + 0.08).timeout.connect(player.queue_free)

func play_map_reveal_effect() -> void:
	# Acorde luminoso y una campana final para presentar el campo elegido.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.65
	player.stream = stream
	player.volume_db = -4.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.52
	var notes := [523.25, 659.25, 783.99]
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var chord := 0.0
		for note in notes:
			chord += sin(TAU * note * time) * 0.10
		var swell := sin(PI * clampf(time / 0.22, 0.0, 1.0)) if time < 0.22 else exp(-(time - 0.22) * 3.8)
		var bell := sin(TAU * 1567.98 * time) * exp(-(time - 0.19) * 7.5) * 0.20 if time > 0.19 else 0.0
		var sample := (chord * swell + bell) * 0.78
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_loadout_complete_effect() -> void:
	# ConfirmaciÃ³n clara para la selecciÃ³n completa de cuatro torres.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.52
	player.stream = stream
	player.volume_db = -3.5 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.38
	var notes := [659.25, 783.99, 987.77]
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var note_index := mini(2, int(time / 0.105))
		var note: float = notes[note_index]
		var local_time := fposmod(time, 0.105)
		var envelope := exp(-local_time * 19.0)
		var sample := (sin(TAU * note * time) + sin(TAU * note * 2.0 * time) * 0.15) * envelope * 0.30
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_pirate_sword_sweep() -> void:
	# Un silbido de aire con un toque metÃ¡lico para el barrido amplio del pirata.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.32
	player.stream = stream
	player.volume_db = -6.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.24
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var progress := time / duration
		var sweep_frequency := lerpf(280.0, 1520.0, progress)
		var envelope := sin(PI * progress) * exp(-progress * 0.55)
		var whoosh := sin(TAU * sweep_frequency * time) * envelope
		var steel := sin(TAU * 2350.0 * time) * exp(-time * 24.0) * 0.16
		playback.push_frame(Vector2((whoosh * 0.24 + steel) * 0.80, (whoosh * 0.24 + steel) * 0.80))
	get_tree().create_timer(duration + 0.06).timeout.connect(player.queue_free)

func play_wave_start_effect() -> void:
	# Llamada ascendente tipo trompeta corta para anunciar una nueva oleada.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.58
	player.stream = stream
	player.volume_db = -4.5 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.42
	var notes := [392.0, 523.25, 659.25]
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var note_index := mini(2, int(time / 0.12))
		var local_time := fposmod(time, 0.12)
		var envelope := exp(-local_time * 10.0)
		var note: float = notes[note_index]
		var brass := sin(TAU * note * time) + sin(TAU * note * 2.0 * time) * 0.20 + sin(TAU * note * 3.0 * time) * 0.08
		playback.push_frame(Vector2(brass * envelope * 0.19, brass * envelope * 0.19))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_vs_intro_effect() -> void:
	# Descarga grave con chispas agudas para crear tensiÃ³n antes del duelo.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.9
	player.stream = stream
	player.volume_db = -4.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.72
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var envelope := exp(-time * 3.4)
		var rumble := sin(TAU * lerpf(82.0, 45.0, time / duration) * time) * 0.34
		var crackle_gate := sin(TAU * 17.0 * time) > 0.68
		var crackle := (sin(TAU * 1850.0 * time) + sin(TAU * 2630.0 * time) * 0.45) * 0.18 if crackle_gate else 0.0
		var strike := sin(TAU * 510.0 * time) * exp(-time * 13.0) * 0.35
		var sample := (rumble + crackle + strike) * envelope
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.08).timeout.connect(player.queue_free)

func play_heal_effect() -> void:
	# Dos tonos limpios ascendentes, suaves para no cansar durante curaciones repetidas.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.30
	player.stream = stream
	player.volume_db = -9.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.20
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var note := 698.46 if time < 0.09 else 1046.5
		var local_time := fposmod(time, 0.10)
		var envelope := exp(-local_time * 23.0)
		var sample := (sin(TAU * note * time) + sin(TAU * note * 1.5 * time) * 0.18) * envelope * 0.22
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.06).timeout.connect(player.queue_free)

func play_lightning_cast_effect() -> void:
	# Chisporroteo de alta frecuencia con una descarga inicial para el rayo del mago.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.34
	player.stream = stream
	player.volume_db = -8.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.24
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var envelope := exp(-time * 11.0)
		var crackle_gate := sin(TAU * 31.0 * time) > 0.30
		var crackle := (sin(TAU * 1680.0 * time) + sin(TAU * 2470.0 * time) * 0.42) * 0.20 if crackle_gate else 0.0
		var zap := sin(TAU * lerpf(980.0, 380.0, time / duration) * time) * exp(-time * 22.0) * 0.28
		var sample := (crackle + zap) * envelope
		playback.push_frame(Vector2(sample, sample))
	get_tree().create_timer(duration + 0.06).timeout.connect(player.queue_free)

func play_mystic_arrow_effect() -> void:
	# Silbido etéreo ascendente con un brillo cristalino de flecha élfica.
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.38
	player.stream = stream
	player.volume_db = -9.0 + effects_volume_offset()
	add_child(player)
	player.play()
	var playback := player.get_stream_playback()
	var duration := 0.27
	for frame in range(int(duration * stream.mix_rate)):
		var time := float(frame) / stream.mix_rate
		var progress := time / duration
		var frequency := lerpf(540.0, 1440.0, progress)
		var envelope := sin(PI * progress) * exp(-progress * 0.65)
		var whistle := sin(TAU * frequency * time) * envelope * 0.20
		var chime := sin(TAU * 1980.0 * time) * exp(-time * 13.0) * 0.12
		playback.push_frame(Vector2(whistle + chime, whistle + chime))
	get_tree().create_timer(duration + 0.06).timeout.connect(player.queue_free)
