extends Control

@onready var grid_container = $GridContainer
@onready var usage_panel = $UsagePanel
@onready var use_button = $UsagePanel/Use
@onready var discard_button = $UsagePanel/Discard

var dragged_slot = null
var active_slot = null

func _ready() -> void:
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	usage_panel.visible = false
	use_button.pressed.connect(_on_use_pressed)
	discard_button.pressed.connect(_on_discard_pressed)

func open_usage_panel(slot: Control) -> void:
	active_slot = slot
	var local_pos = slot.global_position - global_position
	usage_panel.position = local_pos + Vector2(slot.size.x + 10, 0)
	# Clamp so it doesn't go off the right edge
	if usage_panel.position.x + usage_panel.size.x > size.x:
		usage_panel.position.x = local_pos.x - usage_panel.size.x - 10
	usage_panel.visible = true

func close_usage_panel() -> void:
	usage_panel.visible = false
	active_slot = null

func _on_use_pressed() -> void:
	if active_slot == null or active_slot.item == null:
		return
	match active_slot.item["type"]:
		"food":
			Global.player_node.eat(20)
			Global.remove_item(active_slot.item["type"], active_slot.item["description"])
			close_usage_panel()
		"weapon":
			pass

func _on_discard_pressed() -> void:
	if active_slot == null or active_slot.item == null:
		return
	Global.remove_item(active_slot.item["type"], active_slot.item["description"])
	close_usage_panel()

func _on_inventory_updated():
	close_usage_panel()
	clear_grid_container()
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		slot.toggle_usage_panel.connect(_on_slot_toggle_usage_panel)
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func _on_slot_toggle_usage_panel(slot: Control) -> void:
	if usage_panel.visible and active_slot == slot:
		close_usage_panel()
	else:
		open_usage_panel(slot)

func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

func _on_drag_start(slot_control: Control):
	dragged_slot = slot_control

func _on_drag_end():
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null

func get_slot_under_mouse() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in grid_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func get_slot_index(slot: Control) -> int:
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i) == slot:
			return i
	return -1

func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 or slot2_index == -1:
		print("ERROR: Invalid slots found")
		return
	else:
		if Global.swap_inventory_items(slot1_index, slot2_index):
			_on_inventory_updated()
