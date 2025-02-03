@tool
extends Node2D
class_name NodeSwitcher


@export
var active_name: String:
	get():
		var active = get_active_node()
		return active.name if active else ""
	set(x):
		if active_name == x: return
		active_name = x
		switch_to(x)


func switch_to(what: String):
	if not is_node_ready(): await ready
	var found_one = false
	for x: Node2D in get_children():
		x.visible = (what == x.name)
		if what == x.name: found_one = true
	if not found_one and what != "":
		push_warning("NodeSwitcher.switch_to(): Failed to find the node with name ", what)

func get_active_node() -> Node2D:
	return get_children().filter(func(x): return x.visible).pop_back()
