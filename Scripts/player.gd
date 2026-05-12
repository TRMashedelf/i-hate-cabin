extends CharacterBody3D

const SPEED = 2.3
const SPRINT_SPEED = 4.5
const TURN_SPEED = 5.0
const SPRINT_TURN_SPEED = 10.0

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var max_hunger: float = 100.0
@export var current_hunger: float = 100.0

var time_passed := 0.0

@export var camera: Camera3D = null

@onready var HUD = $HUD
@onready var anim_tree: AnimationTree = $"Joey 5/AnimationTree"

var _anim_state: AnimationNodeStateMachinePlayback

enum PlayerState {
	IDLE,
	WALK,
	SPRINT,
}

const ANIM_STATE_NAMES := {
	PlayerState.IDLE:   "idle",
	PlayerState.WALK:   "walk",
	PlayerState.SPRINT: "sprint",
}

var current_state: PlayerState = PlayerState.IDLE

func _set_state(new_state: PlayerState) -> void:
	if new_state == current_state:
		return
	current_state = new_state
	_anim_state.travel(ANIM_STATE_NAMES[new_state])


func _ready() -> void:
	Global.set_player_reference(self)
	_anim_state = anim_tree.get("parameters/playback")
	_anim_state.travel(ANIM_STATE_NAMES[current_state])

func _process(delta: float) -> void:
	camera = get_viewport().get_camera_3d()
	if get_tree().paused:
		return
	time_passed += delta
	if time_passed >= 1.0:
		current_hunger -= 0.1
		time_passed -= 1.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		HUD.visible = !HUD.visible
	elif event.is_action_pressed("escape"):
		var pause_menu = HUD.PauseMenu
		pause_menu.visible = !pause_menu.visible

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	var sprinting := Input.is_action_pressed("sprint")
	var current_speed := SPRINT_SPEED if sprinting else SPEED
	var current_turn_speed := SPRINT_TURN_SPEED if sprinting else TURN_SPEED

	var move_input := Input.get_axis("backward", "forward")  
	var turn_input := Input.get_axis("left", "right")       

	var effective_turn_speed: float
	if abs(move_input) > 0.0:
		effective_turn_speed = current_turn_speed * 0.4
	else:
		effective_turn_speed = current_turn_speed * 1.2

	if abs(turn_input) > 0.0:
		rotation.y -= turn_input * effective_turn_speed * delta

	if abs(move_input) > 0.0:
		var forward := -global_transform.basis.z.normalized()
		velocity.x = forward.x * move_input * current_speed
		velocity.z = forward.z * move_input * current_speed

		if sprinting:
			_set_state(PlayerState.SPRINT)
		else:
			_set_state(PlayerState.WALK)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		_set_state(PlayerState.IDLE)

	move_and_slide()

func get_health_normalized() -> float:
	return clampf(current_health / max_health, 0.0, 1.0)

func eat(amount: float) -> void:
	current_hunger = minf(current_hunger + amount, max_hunger)
