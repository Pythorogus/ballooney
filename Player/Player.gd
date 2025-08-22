extends CharacterBody3D

@export var weapon: Node3D
@export var pan_audio: AudioStreamPlayer3D
@export var projectile_scene: PackedScene
@export var health: int = 1 
@export var weapon_cooldown: Timer

@onready var projectile_spawn: Node3D = $Head/Camera3D/Weapon/ProjectileSpawn

const SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY : float = 0.0053
const RECOIL_DISTANCE: float = 0.1
const RECOIL_TIME: float = 0.1
const RECOIL_RETURN_TIME: float = 0.5

var weapon_default_z: int

func _ready():
	weapon_default_z = weapon.position.z
	#for child in %WorldModel.find_children("*","VisualInstance3D"):
		#child.set_layer_mask_value(1, false)
		#child.set_layer_mask_value(2, true)

func _unhandled_input(event: InputEvent) -> void:
	
	#if event is InputEventMouseButton:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif event.is_action_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		%Camera3D.rotate_x(-event.relative.y * SENSITIVITY)
		%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Shoot
	if Input.is_action_pressed("shoot"):
		shoot()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func shoot():
	if weapon_cooldown.is_stopped():
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)

		# Spawn au niveau du canon / muzzle
		projectile.global_transform.origin = projectile_spawn.global_transform.origin

		# Direction par défaut = face caméra
		var camera = %Camera3D
		var direction = -camera.global_transform.basis.z.normalized()

		# Lancer un raycast pour viser un point dans le monde
		var ray_length = 1000.0
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			camera.global_transform.origin,
			camera.global_transform.origin + direction * ray_length
		)
		var result = space_state.intersect_ray(query)

		if result.size() > 0:
			# Ajuste la direction pour aller du canon au point visé
			direction = (result.position - projectile_spawn.global_transform.origin).normalized()

		projectile.direction = direction
		
		pan_audio.pitch_scale = randf_range(0.95, 1.05)
		pan_audio.play()
		
		var tween = create_tween()
		tween.tween_property(weapon, "position:z", weapon_default_z + RECOIL_DISTANCE, RECOIL_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(weapon, "position:z", weapon_default_z, RECOIL_RETURN_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
		weapon_cooldown.start()

func die():
	print("💀 Le joueur est mort !")
	queue_free()
	# Ici tu pourrais charger un écran de Game Over
