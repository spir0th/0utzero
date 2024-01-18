extends Spatial

var debug_cam = preload("res://scenes/debug/DebugCamera.tscn")

export (float) var fallback_height = - 50.0
export (bool) var always_capture_cursor = true
export (NodePath) var player = null

func _ready():
	add_child(debug_cam.instance())

func _enter_tree():
	if player != null and has_node(player):
		Variables.game.player = get_node(player)
	
	Variables.game.session = true

func _exit_tree():
	Variables.game.player = null
	Variables.game.session = false

func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			Menu.show()

func _process(_delta):
	if always_capture_cursor:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	if player != null and has_node(player):
		var playern = get_node(player)
		
		if playern.translation.y < fallback_height:
			playern.fall_damage = 0
			playern.health = 0
