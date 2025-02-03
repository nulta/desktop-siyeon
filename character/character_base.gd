extends CanvasGroup
class_name CharacterBase


var state: CharacterState = null

@export var flipped := false
@export var stare_enabled := false
@export var stare_point := Vector2.ZERO

@onready var grab_marker: Marker2D = %GrabMarker
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var mouse_hand_area_l: Polygon2D = %MouseHandAreaL
@onready var main_body_bone: Bone2D = %MainBodyBone
@onready var l_arm_bone: Bone2D = %Skeleton/MainBodyBone/LArmBone
@onready var r_arm_bone: Bone2D = %Skeleton/MainBodyBone/RArmBone
@onready var _skeleton: Skeleton2D = %Skeleton
@onready var _eye_marker: Node2D = %EyeMarker
@onready var _face_bone: Bone2D = %FaceBone
@onready var _pickup_area: Polygon2D = %PickupArea
@onready var _audio_player: AudioStreamPlayer = $AudioPlayer
@onready var audio_grab_long: AudioStreamPlayer = $AudioGrabLong


func set_state(new_state: CharacterState):
	if state: state.on_end()
	state = new_state
	if new_state:
		new_state.base = self
		new_state.on_ready()

func reset_state():
	set_state(IdleState.new())

func play_audio(audio: AudioStream):
	_audio_player.stream = audio
	_audio_player.play()

func set_window_clip(use_clipping: bool):
	var has_clipping_set := not get_window().mouse_passthrough_polygon.is_empty()
	if use_clipping and not has_clipping_set:
		var new_polygon := _pickup_area.polygon
		new_polygon = Transform2D(0, _pickup_area.global_position) * new_polygon
		get_window().mouse_passthrough_polygon = new_polygon
	elif has_clipping_set:
		get_window().mouse_passthrough_polygon = []

func set_big_window(use_big_window: bool):
	var using_big_window := get_window().size.x == 180
	if use_big_window == using_big_window: return

	if use_big_window:
		get_window().size = Vector2i(180, 180)
	else:
		get_window().size = Vector2i(130, 150)

func play_animation(anim_name: StringName):
	animation_player.play(anim_name)

func is_just_grabbed() -> bool:
	var has_mouse := is_mouse_in_polygon(_pickup_area)
	var is_clicked := Input.is_action_just_pressed("click")
	return has_mouse and is_clicked

func is_mouse_in_polygon(polygon: Polygon2D) -> bool:
	var poly := polygon.polygon
	var local_mouse = polygon.get_local_mouse_position()
	return Geometry2D.is_point_in_polygon(local_mouse, poly)

func reset_stare_point():
	stare_point = _eye_marker.global_position + Vector2.LEFT


func _ready():
	reset_state()

func _process(delta: float):
	if state:
		state._run_process(delta)
	_process_stare(delta)

func _process_stare(_delta: float):
	if not stare_enabled: return
	const angle_limit = deg_to_rad(18.0)
	var desired_angle := _eye_marker.global_position.angle_to_point(stare_point) + PI
	desired_angle = _clamp_angle(desired_angle, angle_limit)
	_face_bone.rotation = lerp_angle(_face_bone.rotation, desired_angle, min(_delta*5, 1.0))

func _get_skeleton_modstack(idx: int) -> SkeletonModification2D:
	return _skeleton.get_modification_stack().get_modification(idx)

func _clamp_angle(ang: float, limit: float):
	if ang > PI:
		ang = ang - 2 * PI
	return clampf(ang, -limit, limit)
