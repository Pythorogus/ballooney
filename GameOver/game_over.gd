extends Control

@export var game_over_audio: AudioStreamPlayer2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_audio.play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
