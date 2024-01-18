

extends Camera

export (float) var sensitivity = 0.25


var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0


var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = - 10
var _vel_multiplier = 4
var _fov_multiplier = 5


var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false

func _ready():
	
	if Variables.game.player == null and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	if not is_current():
		return 
	
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP:
				if get_fov() < 50.0:continue
				fov -= _fov_multiplier
			BUTTON_WHEEL_DOWN:
				if get_fov() > 150.0:continue
				fov += _fov_multiplier
	
	if event is InputEventKey:
		match event.scancode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed
			KEY_T:
				if Variables.game.player == null:continue
				Variables.game.player.translation = translation


func _process(delta):
	if Input.is_action_just_pressed("ui_debug_camera"):
		if not is_current():
			pause_mode = PAUSE_MODE_PROCESS
			make_current()
		else :
			pause_mode = PAUSE_MODE_INHERIT
			clear_current()
	
	get_tree().paused = is_current()
	
	if is_current():
		_update_mouselook()
		_update_movement(delta)
	elif Variables.game.player != null:
		translation = Variables.game.player.translation


func _update_movement(delta):
	if Input.is_action_just_pressed("player_walk"):
		_fov_multiplier += 5.0
		_vel_multiplier = clamp(_vel_multiplier * 3.0, 0.2, 20)
	elif Input.is_action_just_released("player_walk"):
		_fov_multiplier -= 5.0
		_vel_multiplier = clamp(_vel_multiplier / 3.0, 0.2, 20)
	
	
	_direction = Vector3(_d as float - _a as float, 
							_e as float - _q as float, 
							_s as float - _w as float)
	
	
	
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta + _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		
		_velocity = Vector3.ZERO
	else :
		
		_velocity.x = clamp(_velocity.x + offset.x, - _vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, - _vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, - _vel_multiplier, _vel_multiplier)
		translate(_velocity * delta)


func _update_mouselook():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		
		pitch = clamp(pitch, - 90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg2rad( - yaw))
		rotate_object_local(Vector3(1, 0, 0), deg2rad( - pitch))
