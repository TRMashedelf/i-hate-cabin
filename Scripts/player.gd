extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var camera: Camera3D = null

func _process(_delta) -> void:
	camera = get_viewport().get_camera_3d()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		var look_target := global_position + direction
		look_at(look_target, Vector3.UP)

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
