extends CharacterBody3D

class_name Enemy

@export var speed: float = 3.0
@export var health: int = 1
@export var balloon: Node3D

var player: Node3D
var death_audio: AudioStreamPlayer3D

func _physics_process(_delta: float):
	if player:
		var dir = (player.global_transform.origin - global_transform.origin)
		dir.y = 0
		dir = dir.normalized()
		
		# Rotation instantanée vers le joueur
		look_at(player.global_transform.origin, Vector3.UP)
		
		# Avancer dans la direction vers le joueur
		velocity = dir * speed
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	print(name, " prend ", amount, " dégâts ! (PV restants: ", health, ")")
	flash_red()
	if health <= 0:
		die()

func die(earn_xp = true):
	print(name, " est mort.")
	death_audio.play()
	if earn_xp:
		player.earn_xp(1)
	queue_free()

func flash_red():
	var mesh_instance: MeshInstance3D = balloon.mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	var mat = mesh_instance.get_active_material(0)
	
	var tween = create_tween()
	tween.tween_property(mat, "albedo_color", Color(1, 0.2, 0.2), 0.05)
	tween.tween_property(mat, "albedo_color", Color(1, 1, 1), 0.1)
	await tween.finished
	mesh_instance.material_override = null
