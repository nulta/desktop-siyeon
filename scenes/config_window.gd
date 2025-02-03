extends Window


func _init() -> void:
	close_requested.connect(func(): hide())
	#visible = false
