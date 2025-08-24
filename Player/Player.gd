extends CharacterBody3D

@export var weapon: Node3D
@export var pan_audio: AudioStreamPlayer3D
@export var projectile_scene: PackedScene
@export var health: int = 5
@export var max_health: int = 5
@export var weapon_cooldown: Timer
@export var projectile_spawn: Node3D
@export var damage_area: Area3D
@export var health_bar: ProgressBar
@export var health_label: Label
@export var level_label: Label
@export var xp_label: Label
@export var xp_bar: ProgressBar
@export var hit_container: Control
@export var hit_audio: AudioStreamPlayer3D

signal level_up

const SPEED: float = 10.0
const JUMP_VELOCITY: float = 4.5
const SENSITIVITY: float = 0.0053
const RECOIL_DISTANCE: float = 0.1
const RECOIL_TIME: float = 0.1
const RECOIL_RETURN_TIME: float = 0.5

var bonus_speed: float = 1.0
var bonus_projectile_number: int = 0
var bonus_projectile_size: float = 0
var bonus_projectile_speed: float = 0
var bonus_fire_rate: float = 1.0
var bonus_projectile_area: int = 0

var xp: int = 0
var max_xp: int = 3
var level: int = 1

var weapon_default_z: float
var time_alive: float = 0.0

func _ready():
	weapon_default_z = weapon.position.z
	health_bar.max_value = max_health
	health_bar.value = health
	update_health_label()
	update_xp()
	#for child in %WorldModel.find_children("*","VisualInstance3D"):
		#child.set_layer_mask_value(1, false)
		#child.set_layer_mask_value(2, true)

func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#elif event.is_action_pressed("ui_cancel"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		%Camera3D.rotate_x(-event.relative.y * SENSITIVITY)
		%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _process(delta: float) -> void:
	time_alive += delta

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
		velocity.x = direction.x * (SPEED * bonus_speed)
		velocity.z = direction.z * (SPEED * bonus_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * bonus_speed)
		velocity.z = move_toward(velocity.z, 0, SPEED * bonus_speed)

	move_and_slide()

func shoot():
	if weapon_cooldown.is_stopped():
		var camera = %Camera3D
		var direction = -camera.global_transform.basis.z.normalized()

		# Raycast pour viser
		var ray_length = 1000.0
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			camera.global_transform.origin,
			camera.global_transform.origin + direction * ray_length
		)
		var result = space_state.intersect_ray(query)
		if result.size() > 0:
			direction = (result.position - projectile_spawn.global_transform.origin).normalized()

		var num_projectiles = 1 + bonus_projectile_number
		var deg_rad = 15.0 + bonus_projectile_area
		var spread_angle = deg_to_rad(deg_rad)
		var half_spread = spread_angle / 2.0
		
		# Tirer projectiles en arc
		for i in range(num_projectiles):
			if i == 0 and num_projectiles != 3 and num_projectiles != 5:
				# Balle centrale
				var projectile_central = projectile_scene.instantiate()
				projectile_central.scale *= (1.0 + bonus_projectile_size)
				projectile_central.speed += bonus_projectile_speed
				get_tree().current_scene.add_child(projectile_central)
				projectile_central.global_transform.origin = projectile_spawn.global_transform.origin
				projectile_central.direction = direction
			else :
				# t dans [0,1] pour lerp
				var t = float(i) / (num_projectiles - 1)
				var angle = lerp(-half_spread, half_spread, t)
				var rotated_direction = direction.rotated(Vector3.UP, angle).normalized()

				var projectile = projectile_scene.instantiate()
				projectile.scale *= (1.0 + bonus_projectile_size)
				projectile.speed += bonus_projectile_speed
				get_tree().current_scene.add_child(projectile)
				projectile.global_transform.origin = projectile_spawn.global_transform.origin
				projectile.direction = rotated_direction

		# Son + recul comme avant
		pan_audio.pitch_scale = randf_range(0.95, 1.05)
		pan_audio.play()

		var tween = create_tween()
		tween.tween_property(weapon, "position:z", weapon_default_z + RECOIL_DISTANCE, RECOIL_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(weapon, "position:z", weapon_default_z, RECOIL_RETURN_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		weapon_cooldown.start()

func take_damage(amount:int):
	var tween = create_tween()
	tween.tween_property(hit_container, "modulate:a", 1, 0.1)
	tween.tween_property(hit_container, "modulate:a", 0, 0.1)
	hit_audio.play()
	update_health(health - amount)

func update_health(new_health):
	health = new_health
	health_bar.value = health
	update_health_label()
	if health <= 0:
		die()

func update_health_label():
	health_label.text = str(health) + " / " + str(max_health)

func die():
	print("Le joueur est mort !")
	Data.last_level = level
	Data.last_time_alive = time_alive
	get_tree().change_scene_to_file("res://GameOver/game_over.tscn")

func earn_xp(amount:int):
	xp += amount
	update_xp()
	if xp == max_xp:
		emit_level_up()

func update_xp():
	xp_bar.value = xp
	xp_label.text = str(xp) + " / " + str(max_xp)

func emit_level_up():
	level += 1
	xp = 0
	max_xp += 1
	xp_bar.value = xp
	xp_bar.max_value = max_xp
	level_label.text = "LEVEL : " + str(level)
	level_up.emit()
	update_xp()

func heal():
	if health < max_health:
		update_health(health + 1)

func upgrade_max_health():
	max_health += 1
	health_bar.max_value = max_health
	update_health_label()
	heal()

func upgrade_speed():
	bonus_speed += 0.1

func upgrade_projectile_number():
	bonus_projectile_number += 1

func upgrade_projectile_speed():
	bonus_projectile_speed += 10

func upgrade_projectile_size():
	bonus_projectile_size += 2.0

func upgrade_fire_rate():
	bonus_fire_rate += 0.05
	weapon_cooldown.wait_time -= (weapon_cooldown.wait_time * (bonus_fire_rate-1))

func upgrade_projectile_area():
	bonus_projectile_area += 15

func _on_damage_area_body_entered(body: Node3D) -> void:
	if body is Enemy:
		take_damage(1)
		body.die(false)
