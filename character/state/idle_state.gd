extends CharacterState
class_name IdleState


func on_ready():
	base.play_animation("idle")
	base.stare_enabled = true
	base.set_window_clip(true)

func on_process(_delta: float):
	# Stare at mouse
	var mouse_rel = base.get_global_mouse_position()
	if mouse_rel.x < 60:
		# mouse is on the left of the character
		base.stare_point = mouse_rel
	else:
		base.reset_stare_point()

	# Grabbing
	if base.is_just_grabbed():
		base.set_state(GrabbedState.new())
	
	# Mouse handling (L)
	if base.is_mouse_in_polygon(base.mouse_hand_area_l):
		# Turn off `LArmBone:rotate` track
		base.animation_player.get_animation("idle").track_set_enabled(0, false)
		var old_angle = base.l_arm_bone.rotation
		base.l_arm_bone.look_at(mouse_rel)
		base.l_arm_bone.rotation_degrees -= 90 + 28
		var desired_angle = base.l_arm_bone.rotation
		base.l_arm_bone.rotation = lerp_angle(old_angle, desired_angle, 0.3)
	else:
		base.animation_player.get_animation("idle").track_set_enabled(0, true)

	# Move the window above the taskbar.
	# I don't know why, but it works about 70% of time.
	if not base.get_window().has_focus() and Engine.get_process_frames() % 4 == 0:
		base.get_window().always_on_top = true

func on_end():
	base.stare_enabled = false
