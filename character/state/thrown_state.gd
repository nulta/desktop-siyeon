extends CharacterState
class_name ThrownState


const AudioLaunch = preload("res://assets/launch.mp3")
const AudioHit = preload("res://assets/hit.mp3")
const gravity = Vector2(0, 1600)

var velocity := Vector2(0, 0)
var override_fall_height := 0
var _initial_velocity := Vector2(0, 0)
var _destination_y_pos := 0
var _screen_area := Rect2i(0, 0, 0, 0)

func on_ready():
	# Set up _screen_area
	for x in DisplayServer.get_screen_count():
		var scr_pos := DisplayServer.screen_get_position(x)
		var scr_size := DisplayServer.screen_get_size(x)
		if _screen_area == Rect2i(0, 0, 0, 0):
			_screen_area = Rect2i(scr_pos, scr_size)
		else:
			_screen_area = _screen_area.merge(Rect2i(scr_pos, scr_size))

	base.play_animation("thrown")
	base.stare_enabled = false
	base.set_window_clip(false)
	base.set_big_window(true)
	base.play_audio(AudioLaunch)

	_initial_velocity = velocity

	var start_y_pos := base.get_window().position.y
	if override_fall_height != 0:
		_destination_y_pos = start_y_pos + override_fall_height
	else:
		var depth_multiplier_per_angle := absf(sin((velocity.angle() + 0.5 * PI) / 2.0)) ** 2
		var destination_delta_y := velocity.length() * depth_multiplier_per_angle
		_destination_y_pos = start_y_pos + destination_delta_y

func on_process(delta: float):
	var window := base.get_window()
	var last_screen := window.current_screen

	# Catch!
	if base.is_just_grabbed():
		var grabbed := GrabbedState.new()
		base.set_state(grabbed)
		grabbed.start_struggle()
		return

	# Velocity and Gravity and Rotation
	window.position += Vector2i(velocity * delta)
	velocity += gravity * delta
	base.main_body_bone.rotation = get_character_angle()

	# Hit the destination y-level
	if window.position.y >= _destination_y_pos:
		window.position.y = _destination_y_pos
		hit_the_ground()
		return

	# Screen edge (L, R)
	if window.position.x < _screen_area.position.x:
		window.position.x = _screen_area.position.x
		velocity.x = abs(velocity.x) * 0.1
	elif _screen_area.end.x < (window.position.x + 130):
		window.position.x = _screen_area.end.x - 130
		velocity.x = -abs(velocity.x) * 0.1

	# Screen bottom check
	var window_bottom_rect := Rect2(window.position + Vector2i(0, 150), Vector2(130, 10000))
	if DisplayServer.get_screen_from_rect(window_bottom_rect) == -1:
		var scr_pos := DisplayServer.screen_get_position(last_screen)
		var scr_size := DisplayServer.screen_get_size(last_screen)
		var scr_bottom := scr_pos.y + scr_size.y
		window.position.y = scr_bottom - 150
		hit_the_ground()


func on_end():
	base.set_big_window(false)


func get_character_angle() -> float:
	var angle := fmod(2*PI + velocity.angle() + 0.5 * PI, 2.0*PI)
	if angle < PI:
		angle = clamp(angle, 0.0, 0.75*PI)
	elif PI < angle:
		angle = clamp(angle, 1.25*PI, 2.0*PI)
	elif is_equal_approx(angle, PI):
		angle = 0.5*PI if _initial_velocity.x <= 0 else 1.5*PI
	return angle

func hit_the_ground():
	var power = velocity.length()
	base.play_audio(AudioHit)
	base.reset_state()  # FIXME
	#if power < 50.0:  # px/s
	
	var landed := LandedState.new()
	landed.hit_power = power
	base.set_state(landed)
