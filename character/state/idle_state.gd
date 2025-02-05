extends CharacterState
class_name IdleState

var anim_name := "idle"
var is_windows := OS.get_name() == "Windows"
var window_top_timer := 0.0
var time_before_next_state := 0.0


func on_ready():
	base.play_animation(anim_name)
	base.animation_player.get_animation(anim_name).track_set_enabled(0, false)
	base.stare_enabled = true
	base.set_window_clip(true)
	base.get_window().always_on_top = true
	base.r_arm_node.z_index = 0
	time_before_next_state = randf_range(30.0, 120.0)

func on_process(delta: float):
	process_grabbing()
	var mouse_rel = base.get_global_mouse_position()
	stare_at_mouse(mouse_rel)
	put_left_hand_at_mouse(mouse_rel)
	process_window_to_top(delta, 2.0)
	
	if time_elapsed >= time_before_next_state:
		base.set_state(SitState.new())

func on_end():
	base.stare_enabled = false
	base.r_arm_node.z_index = 1


func process_window_to_top(delta: float, delay_between: float):
	if is_windows:
		window_top_timer += delta
		if window_top_timer >= delay_between:
			base.reposition_window_on_top()
			window_top_timer = 0.0

func process_grabbing():
	if base.is_just_grabbed():
		base.set_state(GrabbedState.new())

func stare_at_mouse(mouse_rel: Vector2):
	if mouse_rel.x < 60:
		base.stare_point = mouse_rel
	else:
		base.reset_stare_point()

func put_left_hand_at_mouse(mouse_rel: Vector2):
	var old_angle = base.l_arm_bone.rotation
	if base.is_mouse_in_polygon(base.mouse_hand_area_l):
		var angle_to_point := base.l_arm_bone.global_position.angle_to_point(mouse_rel)
		var desired_angle := fmod(rad_to_deg(angle_to_point) + 360,360) - 90
		desired_angle = deg_to_rad(remap(desired_angle, 10, 120, -25, 85))
		base.l_arm_bone.rotation = lerp_angle(old_angle, desired_angle, 0.17)
	else:
		var anim_player := base.animation_player
		var idle_anim := anim_player.get_animation(anim_name)
		var desired_angle = idle_anim.value_track_interpolate(0, anim_player.current_animation_position)
		if time_elapsed < 0.1:
			base.l_arm_bone.rotation = lerp_angle(old_angle, desired_angle, 0.7)
		elif abs(angle_difference(old_angle, desired_angle)) < 0.03*PI:
			base.l_arm_bone.rotation = lerp_angle(old_angle, desired_angle, 0.3)
		else:
			base.l_arm_bone.rotation = lerp_angle(old_angle, desired_angle, 0.1)
