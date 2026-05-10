@tool
extends Node3D


@export var item_type = ""
@export var item_name = ""
@export var item_model: PackedScene
@export var item_icon_texture: Texture2D
@export var item_description = ""
var scene_path: String = "res://Objects/Pickups/item_pickup.tscn"

@onready var model = $Model
@onready var interact_ui = $InteractUI

var player_in_range = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		var model_item = item_model.instantiate()
		model.add_child.call_deferred(model_item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint() && model.get_child_count() == 0 and item_model != null:
		var model_item = item_model.instantiate()
		model.add_child.call_deferred(model_item)
		
	if player_in_range and Input.is_action_just_pressed("interact"):
			pickup_item()

func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"description": item_description,
		"model": item_model,
		"icon": item_icon_texture,
		"scene_path": scene_path,
	}
	if Global.player_node:
		Global.add_item(item)
		self.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		interact_ui.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		interact_ui.visible = false
