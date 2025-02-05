extends Node

func _ready() -> void:
	%PopupMenu.index_pressed.connect(func(id: int):
		if id == 0: get_tree().quit()
		elif id == 2: %InfoWindow.popup()
	)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		if %PopupMenu.visible:
			%PopupMenu.hide()
		else:
			%PopupMenu.popup(Rect2i(get_window().position + Vector2i(20,-33), Vector2i(100, 33)))
