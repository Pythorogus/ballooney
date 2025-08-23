extends Node

@export var player: CharacterBody3D
@export var level_up_menu: Control
@export var cross_container: Container

var choices: Array[Dictionary] = [
	{"type":"heal","label":"HEAL 1 HP"},
	{"type":"max_health","label":"MAX HEALTH +1"},
	{"type":"projectile_number","label":"PROJECTILES +1"},
	{"type":"projectile_size", "label":"PROJECTILE SIZE +50%"},
	{"type":"projectile_speed", "label":"PROJECTILE SPEED +10%"},
	{"type":"projectile_area", "label":"PROJECTILES AREA +15°"},
	{"type":"speed", "label":"MOVEMENT SPEED +10%"},
	{"type":"fire_rate", "label":"FIRE RATE +10%"},
]

func _on_player_level_up() -> void:
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = false
	Input.parse_input_event(ev)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var viewport_size = get_viewport().get_visible_rect().size
	var center = viewport_size / 2
	Input.warp_mouse(Vector2(center.x - 600, center.y))
	get_tree().paused = true
	
	choices.shuffle()
	var new_choices = choices.slice(0, 3)
	level_up_menu.define_choices(choices[0],choices[1],choices[2])
	
	level_up_menu.visible = true
	cross_container.visible = false

func _on_level_up_menu_chosen(type) -> void:
	match type:
		"heal":
			player.heal()
		"max_health":
			player.upgrade_max_health()
		"projectile_number":
			player.upgrade_projectile_number()
		"projectile_size":
			player.upgrade_projectile_size()
		"projectile_speed":
			player.upgrade_projectile_speed()
		"projectile_area":
			player.upgrade_projectile_area()
		"speed":
			player.upgrade_speed()
		"fire_rate":
			player.upgrade_fire_rate()
	
	level_up_menu.visible = false
	cross_container.visible = true
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
