extends Node

var inventory = []

signal inventory_updated

var player_node: Node = null
@onready var inventory_slot_scene = preload("res://UI/inventory_slot.tscn")

func _ready() -> void:
	inventory.resize(9)

func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["description"] == item["description"]:
			inventory[1]["quantity"] += item["quantity"]
			inventory_updated.emit()
			print("Item_added", inventory)
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			print("Item_added", inventory)
			return true
		return false

func remove_item(item_type, item_description):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item_type and inventory[i]["description"] == item_description:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false
	
	

func increase_inventory_size():
	inventory_updated.emit()

func set_player_reference(player):
	player_node = player

func swap_inventory_items(index1, index2):
	if index1 < 0 or index1 > inventory.size() or index2 < 0 or index2 > inventory.size():
		return false
	
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	inventory_updated.emit()
	return true
