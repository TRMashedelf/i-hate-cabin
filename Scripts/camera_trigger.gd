extends Node

var in_trigger = false

func enter_trigger(body):
	if body.name == "Player":
		in_trigger = true

func exit_trigger(body):
	if body.name == "Player":
		in_trigger = false

func _process(_delta: float) -> void:
	if in_trigger && get_parent().current != true:
		get_parent().current = true
