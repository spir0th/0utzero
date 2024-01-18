extends WindowDialog

var debug_maps = ["testlevel01", "testlevel02"]
var maps = ["level01", "level02", "level03", "placeholder", "main"]

var history = [""]
var selection = 0

onready var Output = $"Contents/Output"
onready var _Input = $"Contents/Input"

func _ready():
	get_close_button().hide()
	write("%s - version %s" % [Globals.GAME_NAME, Globals.GAME_VERSION])

func _process(_delta):
	if visible:
		if Input.is_action_just_pressed("ui_up"):
			if selection < len(history) - 1:
				selection += 1
				_Input.clear()
				_Input.append_at_cursor(history[selection])
		elif Input.is_action_just_pressed("ui_down"):
			if selection > 0:
				selection -= 1
				_Input.clear()
				_Input.append_at_cursor(history[selection])
		if not _Input.has_focus():
			_Input.grab_focus()

func execute(command:String, append_history = true):
	write(">> %s" % command)
	
	if append_history:
		history.insert(1, command)
		selection = 0
	if command.begins_with("help"):
		write("help, copyright, clear, version, quit")
		write("load, unload, maps, vars")
		
		if Variables.game.player != null:write("teleport, reset, spawn, die")
		if Variables.debugging.enabled:write_debug("debugdraw, reload, crash")
	elif command.begins_with("copyright"):
		write("Copyright (c) %s %s" % [Globals.GAME_COPYRIGHT_YEAR, Globals.GAME_AUTHORS])
		write("This program comes with ABSOLUTELY NO WARRANTY.")
		write("This is free software, and you are welcome to redistribute it under certain conditions.")
	elif command.begins_with("clear"):
		Output.clear()
	elif command.begins_with("version"):
		write("version %s" % Globals.GAME_VERSION)
	elif command.begins_with("quit"):
		get_tree().quit()
	elif command.begins_with("teleport") and Variables.game.player != null:
		var x = command.get_slice(" ", 1)
		var y = command.get_slice(" ", 2)
		var z = command.get_slice(" ", 3)
		Variables.game.player.pause_mode = PAUSE_MODE_PROCESS
		Variables.game.player.translation = Vector3(x, y, z)
		Variables.game.player.pause_mode = PAUSE_MODE_INHERIT
		write("Teleported player to %s" % Vector3(x, y, z))
	elif command.begins_with("reset") and Variables.game.player != null:
		var position = Variables.game.player.default_position
		var coords = "%s %s %s" % [position.x, position.y, position.z]
		var _result = execute("teleport %s" % coords, false)
	elif command.begins_with("spawn") and Variables.game.player != null:
		var camera_translation = Variables.game.player.Camera.translation
		var translation = Variables.game.player.translation
		var object_name = command.substr(command.find_last(" ") + 1)
		var object = null
		
		translation.z -= camera_translation.z
		
		if object_name.begins_with("phonebrick"):
			object = load(Globals.OBJ_PHONEBRICK).instance()
		else :
			if object_name == "spawn":
				write_err("Cannot spawn %s, not a valid object." % object_name)
			else :
				write_err("No object name was found or given.")
		if object != null:
			object.translation = translation
			get_tree().get_root().add_child(object)
	elif command.begins_with("die") and Variables.game.player != null:
			Variables.game.player.take_damage(69420)
	elif command.begins_with("load"):
		var map = command.get_slice(" ", 1)
		
		if map == "testlevel01" and Variables.debugging.enabled:
			SceneManager.change_scene(Globals.MAP_TESTLEVEL_01)
		elif map == "testlevel02" and Variables.debugging.enabled:
			SceneManager.change_scene(Globals.MAP_TESTLEVEL_02)
		elif map == "placeholder" and Variables.debugging.enabled:
			SceneManager.change_scene(Globals.MAP_PLACEHOLDER_MENU)
		elif map == "main":
			SceneManager.change_scene(Globals.MAP_MAIN_SCENE)
		elif map != "load":
			write_err("%s is not a valid map name." % map)
		else :
			write_err("No map name was given.")
	elif command.begins_with("unload"):
		SceneManager.change_scene(Globals.MAP_MAIN_SCENE)
	elif command.begins_with("maps"):
		var map_count = len(maps)
		var dbg_map_count = len(debug_maps) if Variables.debugging.enabled else 0
		write("There are %s maps:\n\n" % [map_count + dbg_map_count])
		
		for m in maps:
			write(m)
		for debug_m in debug_maps:
			if not Variables.debugging.enabled:continue
			write_debug(debug_m)
	elif command.begins_with("vars"):
		var subcommand = command.get_slice(" ", 1)
		
		if subcommand == "set":
			var group = "user_defined"
			var key = command.get_slice(" ", 2)
			var value = command.get_slice(" ", 3)
			
			if ":" in key:
				group = key.get_slice(":", 1)
			if group == "config":
				Variables.config[key] = value
			elif group == "debugging":
				Variables.debugging[key] = value
			elif group == "game":
				Variables.game[key] = value
			elif group == "user_defined":
				Variables.user_defined[key] = value
			
			write("Set %s in group %s to value %s" % [key, group, value])
		elif subcommand == "get":
			var group = "user_defined"
			var key = command.get_slice(" ", 2)
			
			if ":" in key:
				group = key.get_slice(":", 1)
			if group == "config":
				write(Variables.config[key])
			elif group == "debugging":
				write(Variables.debugging[key])
			elif group == "game":
				write(Variables.game[key])
			elif group == "user_defined":
				write(Variables.user_defined[key])
		elif subcommand == "list":
			for k in Variables.config.keys():
				write("CONFIG: %s = %s" % [k, Variables.config[k]])
			for k in Variables.debugging.keys():
				write("DEBUGGING: %s = %s" % [k, Variables.debugging[k]])
			for k in Variables.game.keys():
				write("GAME: %s = %s" % [k, Variables.game[k]])
			for k in Variables.user_defined.keys():
				write("USER DEFINED: %s = %s" % [k, Variables.user_defined[k]])
	elif command.begins_with("exec"):
		var context = command.get_slice(" ", 1)
		var script = GDScript.new()
		var object = Reference.new()
		var exec = command.substr(command.find_last(" ") + 1)
		
		script.set_source_code("func eval():\n	%s" % exec)
		script.reload()
		object.set_script(script)
		
		if object.has_method("eval"):
			if context != "get":
				object.eval()
			else :
				write(object.eval())
		else :
			write_err("Cannot call internal function exec() inside the isolated code.")
		
		return 
	elif command.begins_with("debugdraw") and Variables.debugging.enabled:
		var value = command.substr(command.find_last(" ") + 1)
		var viewport = get_tree().get_root()
		
		if value == "2":
			viewport.debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			write_debug("Debug draw is now set to unshaded.")
		elif value == "1" or value == "true":
			viewport.debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
			write_debug("Debug draw is now set to overdraw.")
		elif value == "0" or value == "false":
			viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED
			write_debug("Debug draw has been disabled.")
		else :
			write_err("Value must be 0 or 1.")
	elif command.begins_with("reload") and Variables.debugging.enabled:
		var result = get_tree().reload_current_scene()
		
		if result == ERR_UNCONFIGURED:
			write_err("No map is currently loaded into game scene.")
		elif result == ERR_CANT_OPEN:
			write_err("Map is either corrupted or unavailable.")
		elif result == ERR_CANT_CREATE:
			write_err("Could not initialize current map.")
	elif command.begins_with("crash") and Variables.debugging.enabled:
		OS.crash("Console requested to exit, game progress is saved.")
	else :
		var invalid = command.substr(command.find_last(" ") + 1)
		if invalid.length() > 0:write_err("%s is an invalid command" % invalid)

func write(message):
	Output.append_bbcode("%s\n" % message)

func write_err(message):
	write("[color=#EE4B2B]%s[/color]" % message)

func write_debug(message):
	write("[color=#D3D3D3]%s[/color]" % message)

func _on_Input_text_entered(text):
	_Input.clear()
	execute(text)
