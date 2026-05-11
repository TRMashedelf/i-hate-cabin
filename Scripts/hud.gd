extends Control

var player = Global.player_node

@onready var ecg_display: ColorRect = $Status/StatusPanel/HealthIndicator/ECG
@onready var hunger_indicator = $Status/StatusPanel/TextureProgressBar/temphungerlabel
@onready var PauseMenu = $PauseMenu
@onready var InventoryUI = $Inventory_UI

var shader_mat: ShaderMaterial
var elapsed: float = 0.0



func _ready() -> void:
	shader_mat = ecg_display.material as ShaderMaterial

func _process(delta: float) -> void:
	hunger_indicator.text = "%.1f" % Global.get_player_hunger()
	if PauseMenu.visible == true:
		InventoryUI.visible = false
		visible = true
	elif PauseMenu.visible == false and self.visible == true:
		InventoryUI.visible = true
	elapsed += delta
	shader_mat.set_shader_parameter("time_offset", elapsed)
	
	
	if player:
		if player and player.has_method("get_health_normalized"):
			var h: float = player.get_health_normalized()
			shader_mat.set_shader_parameter("health", h)


func _on_resume_button_pressed() -> void:
	var event = InputEventAction.new()
	event.action = "escape"
	event.pressed = true
	Input.parse_input_event(event)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
