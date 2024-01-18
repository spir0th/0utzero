extends KinematicBody

enum State{
	IDLE, MOVING, FALLING, CROUCHING, DEAD
}

const ACCELERATION_GROUND = 7
const ACCELERATION_AIR = 1

const DEFAULT_MOVE_SPEED = 7
const DEFAULT_ANIM_SPEED = 1.0
const DEFAULT_COLLISION_HEIGHT = 1.5

const WALK_MOVE_SPEED = 4
const WALK_ANIM_SPEED = 1.0
const WALK_COLLISION_HEIGHT = DEFAULT_COLLISION_HEIGHT

const CROUCH_MOVE_SPEED = 2
const CROUCH_ANIM_SPEED = 1.0
const CROUCH_COLLISION_HEIGHT = 0.1

const CAMERA_FOV_ZOOM_IN = 55
const CAMERA_FOV_ZOOM_OUT = 90
const CAMERA_FOV_ZOOM_MULTIPLIER = 1
const CAMERA_FOV_ZOOM_ACCEL = 0.1

export (Vector3) var default_position = Vector3(0, 0, 0)

var state = State.IDLE
var acceleration = ACCELERATION_GROUND
var move_speed = DEFAULT_MOVE_SPEED
var anim_speed = DEFAULT_ANIM_SPEED

var gravity = 9.8
var jump = 5
var snap = null

var fall_damage = 0

var camera_acceleration = 40
var camera_sensitivity = 0.1
var camera_fov_zoom = CAMERA_FOV_ZOOM_IN

var _gravity = Vector3.ZERO
var direction = Vector3.ZERO
var velocity = Vector3.ZERO

var to_zoom = false
var to_crouch = false
var to_jump = false
var to_walk = false

var health = 100
var inventory = []

signal health_changed(from, to)
signal health_depleted()
signal inventory_changed()

onready var Collision = $"Collision"
onready var Mesh = $"Mesh"
onready var Head = $"Head"
onready var Camera = $"Head/Camera"
onready var HUD = $"Head/Camera/HUD"
onready var Crosshair = $"Head/Camera/Crosshair"
onready var Raycast = $"Head/Camera/Raycast"

onready var MovementAnimator = $"Animators/MovementAnimator"
onready var DeathAnimator = $"Animators/DeathAnimator"

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad( - event.relative.x * camera_sensitivity))
		Head.rotate_x(deg2rad( - event.relative.y * camera_sensitivity))
		Head.rotation.x = clamp(Head.rotation.x, deg2rad( - 89), deg2rad(89))
	if event.is_action_pressed("player_jump"):
		to_jump = true
	elif event.is_action_released("player_jump"):
		to_jump = false
	if event.is_action_pressed("player_crouch"):
		to_crouch = true
	elif event.is_action_released("player_crouch"):
		to_crouch = false
	if event.is_action_pressed("player_walk"):
		to_walk = true
	elif event.is_action_released("player_walk"):
		to_walk = false
	if event.is_action_pressed("player_zoom"):
		to_zoom = true
	elif event.is_action_released("player_zoom"):
		to_zoom = false

func _process(delta):
	if Camera.is_current():
		Crosshair.show()
	else :
		Crosshair.hide()
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		Camera.set_as_toplevel(true)
		Camera.global_transform.origin = Camera.global_transform.origin.linear_interpolate(Camera.global_transform.origin, camera_acceleration * delta)
		Camera.rotation.y = rotation.y
		Camera.rotation.x = Head.rotation.x
	else :
		Camera.set_as_toplevel(false)
		Camera.global_transform = Head.global_transform
	if Raycast.is_colliding():
		var collider = Raycast.get_collider()
		
		if collider.is_in_group(Globals.OBJ_GROUP_PICKUP):
			if Input.is_action_just_pressed("player_interact"):
				if collider.has_method("take"):
					collider.take(get_path())
				else :
					print("Doing nothing with this object. " + 
						"Define a take function in your object script.")
			
			HUD.popup_interaction()
		else :
			HUD.hide_interaction()

func _physics_process(delta):
	var j_axis: = Input.get_vector("player_camera_left", "player_camera_right", "player_camera_down", "player_camera_up")
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("player_move_backward") - Input.get_action_strength("player_move_forward")
	var h_input = Input.get_action_strength("player_move_right") - Input.get_action_strength("player_move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	move_speed = DEFAULT_MOVE_SPEED
	
	if is_on_floor():
		var move = (velocity * delta).length()
		snap = - get_floor_normal()
		acceleration = ACCELERATION_GROUND
		_gravity = Vector3.ZERO
		
		if fall_damage > 0:
			take_damage(fall_damage)
			fall_damage = 0
		if to_jump and not to_crouch:
				snap = Vector3.ZERO
				_gravity = Vector3.UP * jump
		if to_crouch:
			Collision.shape.height -= 10 * delta
			move_speed = CROUCH_MOVE_SPEED
		else :
			Collision.shape.height += 10 * delta
		if state == State.MOVING and to_walk:
			move_speed = WALK_MOVE_SPEED
		if move >= 0.025 and not MovementAnimator.is_playing():
			MovementAnimator.play("Running")
		elif move >= 0.025 and not MovementAnimator.is_playing() and to_walk:
				MovementAnimator.play("Walking")
		elif move >= 0.005 and not MovementAnimator.is_playing():
			MovementAnimator.play("Crouching")
	else :
		snap = Vector3.DOWN
		acceleration = ACCELERATION_AIR
		_gravity += Vector3.DOWN * gravity * delta
		
		if MovementAnimator.is_playing():
			MovementAnimator.stop()
	if _gravity.y < - 10:
		fall_damage = - int(_gravity.y * 2)
	if j_axis != Vector2.ZERO:
		var axis:Vector2 = j_axis * 1000 * delta
		rotate_y(deg2rad( - axis.x * camera_sensitivity))
		Head.rotate_x(deg2rad(axis.y * camera_sensitivity))
		Head.rotation.x = clamp(Head.rotation.x, deg2rad( - 89), deg2rad(89))
	if to_zoom:
		camera_fov_zoom = CAMERA_FOV_ZOOM_IN
	else :
		camera_fov_zoom = CAMERA_FOV_ZOOM_OUT
	
	Camera.fov = lerp(Camera.fov, camera_fov_zoom, CAMERA_FOV_ZOOM_ACCEL)
	Collision.shape.height = clamp(Collision.shape.height, CROUCH_COLLISION_HEIGHT, DEFAULT_COLLISION_HEIGHT)
	velocity = velocity.linear_interpolate(direction * move_speed, acceleration * delta)
	var _r = move_and_slide_with_snap(velocity + _gravity, snap, Vector3.UP, true, 4, deg2rad(52))
	
	update_state()

func take_damage(amount):
	var old = health
	health -= amount
	
	if health <= 0:
		health = 0
		emit_signal("health_depleted")
	
	emit_signal("health_changed", old, health)

func regain_health(amount):
	var old = health
	health += amount
	
	if health >= 100:
		health = 100
	
	emit_signal("health_changed", old, health)

func update_state():
	var g = _gravity.length()
	var v = velocity.length()
	var ch = Collision.shape.height
	
	if v > 0.1 and g < 0.01 and ch > 0.2:
		state = State.MOVING
	elif g > 0.01:
		state = State.FALLING
	elif ch < 0.2:
		state = State.CROUCHING
	else :
		state = State.IDLE

func _on_Body_health_changed(_from, to):
	if to <= 0:
		health = 0
		emit_signal("health_depleted")

func _on_Body_health_depleted():
	HUD.hide()
	DeathAnimator.play("Death")
	set_physics_process(false)
	set_process_input(false)
	set_process(false)
	yield (get_tree().create_timer(5.0), "timeout")
	
	if Variables.game.map != null:
		SceneManager.change_scene(Variables.game.map)
	else :
		HUD.show()
		regain_health(100)
		Head.translation.y = 0.5
		set_physics_process(true)
		set_process_input(true)
		set_process(true)
