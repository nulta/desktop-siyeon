extends CharacterState
class_name GrabbedState


const AudioGrabStart = preload("res://assets/grab_start.mp3")
const AudioGrabEnd = preload("res://assets/grab_end.mp3")

var is_struggling := false


func on_ready():
	base.play_animation("grabbed_1")
	base.stare_enabled = false
	base.set_window_clip(false)
	base.play_audio(AudioGrabStart)

func on_process(delta: float):
	var mouse_diff := base.get_global_mouse_position()
	var window_diff := Vector2i(mouse_diff - base.grab_marker.global_position)

	var is_held = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if not is_held:
		var last_velocity := Vector2(window_diff) / delta / 3.0
		stop_holding(last_velocity)
		return

	base.get_window().position += window_diff

	if time_elapsed > 3.0:
		start_struggle()
	if time_elapsed > 12.5:
		throw(Vector2(randf_range(-200,0), randf_range(-50,50)), 700)
		return

func on_end():
	base.audio_grab_long.stop()

func start_struggle():
	if is_struggling: return
	is_struggling = true
	base.play_animation("grabbed_2")
	base.create_tween().tween_property(base.audio_grab_long, "volume_db", -8.0, 1.25)
	base.audio_grab_long.volume_db = -50.0
	base.audio_grab_long.play()

func stop_holding(last_velocity: Vector2):
	if last_velocity.length() < 500.0:  # px/s
		base.play_audio(AudioGrabEnd)
		base.reset_state()
	else:
		throw(last_velocity)

func throw(velocity: Vector2, override_fall_height := 0):
	var thrown := ThrownState.new()
	thrown.velocity = velocity
	thrown.override_fall_height = override_fall_height
	base.set_state(thrown)
