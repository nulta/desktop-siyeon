extends RefCounted
class_name CharacterState


var base: CharacterBase
var time_elapsed: float = 0.0

func on_process(_delta: float) -> void:
	pass

func on_ready() -> void:
	pass

func on_end() -> void:
	pass


func _run_process(delta: float):
	time_elapsed += delta
	on_process(delta)
