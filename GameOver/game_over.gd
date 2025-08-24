extends Control

@export var game_over_audio: AudioStreamPlayer2D
@export var last_level_label: Label
@export var last_time_alive_label: Label

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_audio.play()
	var lta = Data.last_time_alive
	var minutes = int(lta) / 60
	var seconds = int(lta) % 60
	last_time_alive_label.text = "Time alive : " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	last_level_label.text = "Level : " + str(Data.last_level)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
