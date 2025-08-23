extends Control

signal chosen

@export var choice_button1: Button
@export var choice_button2: Button
@export var choice_button3: Button

var choices: Array[Dictionary]

func define_choices(new_choice1,new_choice2,new_choice3):
	choices = [new_choice1,new_choice2,new_choice3]
	choice_button1.text = new_choice1.label
	choice_button2.text = new_choice2.label
	choice_button3.text = new_choice3.label

func _on_choice_button_1_pressed() -> void:
	chosen.emit(choices[0]["type"])

func _on_choice_button_2_pressed() -> void:
	chosen.emit(choices[1]["type"])

func _on_choice_button_3_pressed() -> void:
	chosen.emit(choices[2]["type"])
