extends Control

@onready var icon = $InnerBorder/ItemIcon
@onready var quantity_label = $InnerBorder/ItemQuantity
@onready var details_panel = $DetailsPanel
@onready var item_description_label = $DetailsPanel/Description
@onready var item_name_label = $DetailsPanel/ItemName
@onready var item_type_label = $DetailsPanel/ItemType
@onready var outer_border = $OuterBorder

var item = null

signal drag_start(slot)
signal drag_end()
signal toggle_usage_panel(slot) 

func _on_item_button_mouse_entered() -> void:
	if item != null:
		details_panel.visible = true

func _on_item_button_mouse_exited() -> void:
	details_panel.visible = false

func set_empty():
	icon.texture = null
	quantity_label.text = ""
	item = null

func set_item(new_item):
	item = new_item
	icon.texture = new_item["icon"]
	quantity_label.text = str(item["quantity"])
	item_name_label.text = str(item["name"])
	item_type_label.text = str(item["type"])
	item_description_label.text = str(item.get("description", ""))

func _on_item_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if item != null:
				toggle_usage_panel.emit(self)  # delegate upward
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				outer_border.modulate = Color(1, 1, 0)
				drag_start.emit(self)
			else:
				outer_border.modulate = Color(1, 1, 1)
				drag_end.emit()
