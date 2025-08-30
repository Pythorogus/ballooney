extends Node

@export var enemy_scene: PackedScene
@export var enemy_spawns: Node3D
@export var enemies: Node3D
@export var player: CharacterBody3D
@export var enemy_spawn_timer: Timer

var next_spawn = 0

func _ready() -> void:
	spawn()

func spawn():
	var duplication = 1 + int(player.level / 10)
	if player.level >= 5:
		enemy_spawn_timer.wait_time = 1.5
	if player.level >= 15:
		enemy_spawn_timer.wait_time = 1.0
	if player.level >= 30:
		duplication = 1 + int(player.level / 3)
		enemy_spawn_timer.wait_time = 0.80
	if player.level >= 50:
		enemy_spawn_timer.wait_time = 0.5
	if player.level >= 70:
		enemy_spawn_timer.wait_time = 0.25
	
	if duplication > enemy_spawns.get_children().size():
		duplication = enemy_spawns.get_children().size()
	
	for i in range(duplication):
		var enemy = enemy_scene.instantiate()
		enemies.add_child(enemy)
		enemy.player = %Player
		enemy.death_audio = %EnemyDeathAudio
		enemy.global_position = enemy_spawns.get_children()[next_spawn].global_position
		enemy.speed = enemy.speed * (1 + (int(player.level / 10) / 10))
	
		var previous_spawn = next_spawn
		while next_spawn == previous_spawn :
			next_spawn = randi_range(0, enemy_spawns.get_children().size() - 1)
		#next_spawn += 1
		#if next_spawn >= enemy_spawns.get_children().size():
			#next_spawn = 0

func _on_enemy_spawn_timer_timeout() -> void:
	spawn()
