extends Control

@export var intro_control: Control

func _on_new_game_button_pressed() -> void:
	intro_control.visible = true

func _on_exit_button_pressed() -> void:
	get_tree().quit()
