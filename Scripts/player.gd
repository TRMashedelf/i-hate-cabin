extends CharacterBody3D

const SPEED = 2.3
const SPRINT_SPEED = 4.5
const TURN_SPEED = 5.0
const SPRINT_TURN_SPEED = 10.0

var max_health: float = 100.0
var current_health: float = 100.0
var max_hunger: float = 100.0
var current_hunger: float = 100.0

@onready var HUD = $HUD

@export var camera: Camera3D = null

func _ready() -> void:
	Global.set_player_reference(self)

func _process(_delta) -> void:
	camera = get_viewport().get_camera_3d()

func _input(event):
	if event.is_action_pressed("inventory"):
		HUD.visible = !HUD.visible
		get_tree().paused = !get_tree().paused

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	var sprinting := Input.is_action_pressed("sprint")
	var current_speed := SPRINT_SPEED if sprinting else SPEED
	var current_turn_speed := SPRINT_TURN_SPEED if sprinting else TURN_SPEED

	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	if input_dir != Vector2.ZERO and camera:
		var cam_basis := camera.global_transform.basis
		var forward := cam_basis.z
		var right   := cam_basis.x
		forward.y = 0.0
		right.y   = 0.0
		forward   = forward.normalized()
		right     = right.normalized()

		var direction := (right * input_dir.x + forward * input_dir.y).normalized()

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		var target_angle := atan2(-direction.x, -direction.z)
		var current_angle := rotation.y
		rotation.y = lerp_angle(current_angle, target_angle, current_turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func get_health_normalized() -> float:
	return clampf(current_health / max_health, 0.0, 1.0)
