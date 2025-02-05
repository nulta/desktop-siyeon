extends IdleState
class_name SitState

func on_ready():
	anim_name = "sit"
	super()
	time_before_next_state = randf_range(120.0, 360.0)

func on_process(delta: float):
	process_grabbing()
	var mouse_rel = base.get_global_mouse_position()
	stare_at_mouse(mouse_rel)
	put_left_hand_at_mouse(mouse_rel)
	process_window_to_top(delta, 1.0)

	if time_elapsed >= time_before_next_state:
		base.reset_state()

func on_end():
	base.stare_enabled = false
	base.r_arm_node.z_index = 1
