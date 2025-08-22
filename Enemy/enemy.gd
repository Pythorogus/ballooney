extends CharacterBody3D

@export var speed: float = 3.0
@export var health: int = 3
@export var player: Node3D
@export var balloon: Node3D

func _ready():
	# Cherche le joueur dans la scène (par son nom ou un groupe)
	print(player)

func _physics_process(delta: float):
	if player:
		var dir = (player.global_transform.origin - global_transform.origin)
		dir.y = 0
		dir = dir.normalized()
		
		# Rotation instantanée vers le joueur
		look_at(player.global_transform.origin, Vector3.UP)
		
		# Avancer dans la direction vers le joueur
		velocity = dir * speed
		move_and_slide()
		
		# Contact
		if global_transform.origin.distance_to(player.global_transform.origin) < 1.2:
			attack_player()



func take_damage(amount: int):
	health -= amount
	print(name, " prend ", amount, " dégâts ! (PV restants: ", health, ")")
	flash_red()
	if health <= 0:
		die()

func die():
	print(name, " est mort.")
	%EnemyDeathAudio.play()
	queue_free()

func attack_player():
	player.die()

func flash_red():
	var mesh_instance: MeshInstance3D = balloon.mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	var mat = mesh_instance.get_active_material(0)
	
	var tween = create_tween()
	tween.tween_property(mat, "albedo_color", Color(1, 0.2, 0.2), 0.05)
	tween.tween_property(mat, "albedo_color", Color(1, 1, 1), 0.1)
	await tween.finished
	mesh_instance.material_override = null
