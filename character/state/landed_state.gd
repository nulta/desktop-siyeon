extends CharacterState
class_name LandedState

const AudioBell = preload("res://assets/bell.mp3")

var hit_power := 0.0
var is_recovering := false

var time_before_recover := 0.0
var anim_speed := 1.0

func on_ready():
	base.play_animation("hard_landing_1")
	base.stare_enabled = false
	base.set_window_clip(false)
	base.set_big_window(true)

	time_before_recover = clamp(remap(hit_power, 1500, 5000, 0.3, 4), 0.15, 5)
	anim_speed = clamp(remap(hit_power, 1000, 5000, 1.75, 0.75), 0.75, 1.75)
	
	if hit_power >= 3500:
		await base.get_tree().create_timer(0.4).timeout
		base.play_audio(AudioBell)

func on_process(_delta: float):
	if not is_recovering and time_elapsed > time_before_recover:
		start_recovery()

	if is_recovering and base.is_just_grabbed():
		var grabbed := GrabbedState.new()
		base.set_state(grabbed)
		grabbed.start_struggle()


func start_recovery():
	is_recovering = true
	if hit_power < 1900:
		base.play_animation("hard_landing_2")
	else:
		base.play_animation("hard_landing_3")

	base.animation_player.speed_scale = anim_speed
	base.animation_player.animation_finished.connect(recover_finished, CONNECT_ONE_SHOT)

func recover_finished(_anim_name: StringName):
	base.reset_state()

func on_end():
	base.set_big_window(false)
	base.animation_player.speed_scale = 1.0

	var anim_signal := base.animation_player.animation_finished
	if anim_signal.is_connected(recover_finished):
		anim_signal.disconnect(recover_finished)
