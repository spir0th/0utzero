extends Node

onready var viewport_size = get_tree().get_root().get_size()
onready var window_size = OS.get_window_size()
onready var window_position = OS.get_window_position()

func _init():
	pause_mode = PAUSE_MODE_PROCESS
	init_window_position()
	init_is_maximized()

func _ready():
	
	init_min_window_size()
	
	update_ui_scale()

func _notification(what):
	if what == NOTIFICATION_WM_QUIT_REQUEST and Variables.config.save_on_exit:
		var result = ProjectSettings.save_custom(Globals.CONFIG_OVERRIDE_PATH)
		if result != OK:print_debug("Could not save modified config changes.")

func _process(_delta):
	
	var new_viewport_size = get_tree().get_root().get_size()
	var new_window_size = OS.get_window_size()
	var new_window_position = OS.get_window_position()
	
	
	ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_FULLSCREEN, 
		OS.is_window_fullscreen())
	ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_BORDERLESS, 
		OS.get_borderless_window())
	ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_MAXIMIZED, 
		OS.is_window_maximized())
	
	
	if window_position != new_window_position:
		ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_POSITION_WIDTH, 
			new_window_position.x)
		ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_POSITION_HEIGHT, 
			new_window_position.y)
		window_position = new_window_position
	
	if not OS.is_window_maximized() and OS.is_window_fullscreen() and not OS.get_borderless_window() and window_size != new_window_size:
			ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_WIDTH, 
				new_window_size.x)
			ProjectSettings.set_setting(Globals.SETTINGS_WINDOW_HEIGHT, 
				new_window_size.y)
			window_size = new_window_size
	
	if viewport_size != new_viewport_size:update_ui_scale(new_viewport_size)

func update_ui_scale(vport_size = get_tree().get_root().get_size()):
	
	var ui_stretch_mode = SceneTree.STRETCH_MODE_2D
	var ui_stretch_aspect = SceneTree.STRETCH_ASPECT_EXPAND
	var ui_scale = 1.0
	
	if ProjectSettings.has_setting(Globals.SETTINGS_UI_SCALE):
		ui_scale = ProjectSettings.get_setting(Globals.SETTINGS_UI_SCALE)
		
	get_tree().set_screen_stretch(ui_stretch_mode, ui_stretch_aspect, 
		vport_size, ui_scale)
	viewport_size = vport_size

func init_min_window_size():
	
	var min_window_size = Vector2(640, 480)

	if ProjectSettings.has_setting(Globals.SETTINGS_WINDOW_MIN_WIDTH):
		min_window_size.x = ProjectSettings.get_setting(Globals.SETTINGS_WINDOW_MIN_WIDTH)
	if ProjectSettings.has_setting(Globals.SETTINGS_WINDOW_MIN_HEIGHT):
		min_window_size.y = ProjectSettings.get_setting(Globals.SETTINGS_WINDOW_MIN_HEIGHT)
	
	OS.set_min_window_size(min_window_size)

func init_window_position():
	
	var _window_position = Vector2(0, 0)
	
	if ProjectSettings.has_setting(Globals.SETTINGS_WINDOW_POSITION_WIDTH):
		_window_position.x = ProjectSettings.get_setting(Globals.SETTINGS_WINDOW_POSITION_WIDTH)
	if ProjectSettings.has_setting(Globals.SETTINGS_WINDOW_POSITION_HEIGHT):
		_window_position.y = ProjectSettings.get_setting(Globals.SETTINGS_WINDOW_POSITION_HEIGHT)
	if _window_position.length() != 0:
		OS.set_window_position(_window_position)
	else :
		OS.center_window()

func init_is_maximized():
	
	if not ProjectSettings.has_setting(Globals.SETTINGS_WINDOW_MAXIMIZED):
		return 
	
	OS.set_window_maximized(ProjectSettings.get_setting(Globals.SETTINGS_WINDOW_MAXIMIZED))
