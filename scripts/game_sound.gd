class_name GameSound
extends Node

const STREAMS := {
	"click": preload("res://assets/audio/ui_click.wav"),
	"place": preload("res://assets/audio/place_tower.wav"),
	"dart": preload("res://assets/audio/dart.wav"),
	"impact": preload("res://assets/audio/impact.wav"),
	"send": preload("res://assets/audio/send_balloon.wav"),
	"win": preload("res://assets/audio/win.wav")
}

func play_effect(effect: String, volume_db := -8.0) -> void:
	if not STREAMS.has(effect):
		return
	var player := AudioStreamPlayer.new()
	player.stream = STREAMS[effect]
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
