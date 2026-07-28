class_name GameSound
extends Node

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

func set_music(new_mode: String) -> void:
	if music_mode == new_mode:
		return
	music_mode = new_mode
	music_time = 0.0
	if new_mode == "game":
		game_track = randi_range(0, 2)
	if not music_player:
		music_player = AudioStreamPlayer.new()
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = 22050.0
		stream.buffer_length = 0.4
		music_player.stream = stream
		music_player.volume_db = -11.0
		add_child(music_player)
		music_player.play()
		music_playback = music_player.get_stream_playback()

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
	var beat: float = [0.42, 0.36, 0.48][game_track] if upbeat else 0.86
	var step := int(floor(time / beat))
	var chord: float
	var melody_note: float
	match game_track:
		1:
			chord = [0.0, 7.0, 5.0, 3.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [19.0, 16.0, 14.0, 21.0][step % 4]
		2:
			chord = [0.0, 3.0, 8.0, 5.0][int(floor(float(step) / 4.0)) % 4]
			melody_note = [12.0, 15.0, 19.0, 22.0][step % 4]
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
	player.volume_db = volume_db
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
