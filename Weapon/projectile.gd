extends Area3D

@export var speed: float = 50.0
@export var lifetime: Timer
var direction: Vector3 = Vector3.ZERO

func _ready():
	# Connecte la détection de collisions
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float):
	# Déplacement en ligne droite
	if direction != Vector3.ZERO:
		global_transform.origin += direction * speed * delta

func _on_body_entered(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()
