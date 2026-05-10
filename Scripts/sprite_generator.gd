@tool
extends SubViewport

@export_tool_button("Generate Sprite")
var generate_sprite = func():
	get_texture().get_image().save_png("user://sprite.png")
