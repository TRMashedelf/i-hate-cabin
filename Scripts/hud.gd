extends Control

var player = Global.player_node

@onready var ecg_display: ColorRect = $Status/StatusPanel/HealthIndicator/ECG

var shader_mat: ShaderMaterial
var elapsed: float = 0.0

func _ready() -> void:
	shader_mat = ecg_display.material as ShaderMaterial

func _process(delta: float) -> void:
	elapsed += delta
	shader_mat.set_shader_parameter("time_offset", elapsed)
	
	if player:
		if player and player.has_method("get_health_normalized"):
			var h: float = player.get_health_normalized()
			shader_mat.set_shader_parameter("health", h)
