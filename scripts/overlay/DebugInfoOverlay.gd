extends CanvasLayer

onready var LeftInfo = $"Contents/LeftInfo"
onready var RightInfo = $"Contents/RightInfo"

func _input(event):
	if event.is_action_pressed("ui_debug_overlay"):
		if not is_visible():
			show()
		else :
			hide()

func _process(_delta):
	if not is_visible():
		return 
	
	LeftInfo.text = ""
	RightInfo.text = ""
	LeftInfo.text += str("Frames per second: ", Engine.get_frames_per_second(), "\n")
	LeftInfo.text += str("Frames drawn: ", Engine.get_frames_drawn(), "\n")
	LeftInfo.text += str("Objects instanced: ", Performance.get_monitor(Performance.OBJECT_COUNT), "\n")
	LeftInfo.text += str("Resources used: ", Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT), "\n")
	LeftInfo.text += str("Draw calls: ", Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME), "\n")
	LeftInfo.text += str("Nodes: ", Performance.get_monitor(Performance.OBJECT_NODE_COUNT), "\n")
	LeftInfo.text += str("Ticks: ", Time.get_ticks_msec(), "\n\n")
	
	var gpu_used_mb = String.humanize_size(int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)))
	LeftInfo.text += str("Renderer: ", OS.get_video_driver_name(OS.get_current_video_driver()), "\n")
	LeftInfo.text += str("GPU adapter: ", VisualServer.get_video_adapter_name(), "\n")
	LeftInfo.text += str("GPU vendor: ", VisualServer.get_video_adapter_vendor(), "\n")
	LeftInfo.text += str("GPU memory used: ", gpu_used_mb, "\n")
	LeftInfo.text += str("Window position: ", OS.window_position, "\n")
	LeftInfo.text += str("Window size: ", OS.window_size, "\n")
	LeftInfo.text += str("VSync: ", "Enabled" if OS.vsync_enabled else "Disabled", "\n")
	LeftInfo.text += str("UI scale: ", ProjectSettings.get_setting(Globals.SETTINGS_UI_SCALE), "\n\n")
	
	var speaker_mode = AudioServer.get_speaker_mode()
	var speaker_mode_str = "Unknown"
	
	match speaker_mode:
		AudioServer.SPEAKER_MODE_STEREO:
			speaker_mode_str = "Stereo"
			continue
		AudioServer.SPEAKER_SURROUND_31:
			speaker_mode_str = "3.1 surround channel"
			continue
		AudioServer.SPEAKER_SURROUND_51:
			speaker_mode_str = "5.1 surround channel"
			continue
		AudioServer.SPEAKER_SURROUND_71:
			speaker_mode_str = "7.1 surround channel"
			continue
	
	LeftInfo.text += str("Audio driver: ", OS.get_audio_driver_name(0), "\n")
	LeftInfo.text += str("Output device: ", AudioServer.device, "\n")
	LeftInfo.text += str("Speaker mode: ", speaker_mode_str, "\n")
	LeftInfo.text += str("Mix rate: ", AudioServer.get_mix_rate(), "\n\n")
	
	RightInfo.text += str("%s - version %s" % [Globals.GAME_NAME, Globals.GAME_VERSION], "\n")
	RightInfo.text += str("Godot Engine ", Engine.get_version_info()["string"], "\n")
	
	if Variables.debugging.enabled:
		RightInfo.text += str("This is a debug build, some features may not work as intended.", "\n\n")
	else :
		RightInfo.text += "\n"
	
	var cpu_cores = "%s cores" % String(OS.get_processor_count())
	var date_time = "%s %s" % [Time.get_date_string_from_system(), Time.get_time_string_from_system()]
	RightInfo.text += str("Platform: ", OS.get_name(), "\n")
	RightInfo.text += str("Processor: ", cpu_cores, ", ", OS.get_processor_name(), "\n")
	
	if Variables.debugging.enabled:
		var dynamic_mem = OS.get_dynamic_memory_usage()
		var static_mem = OS.get_static_memory_usage()
		RightInfo.text += str("Memory: ", String.humanize_size(dynamic_mem + static_mem), "\n")
	
	RightInfo.text += str("Date & Time: ", date_time, "\n\n")
	
	if Variables.game.player != null:
		var player = Variables.game.player
		var state = "Unknown"
		
		if player.state == 0:
			state = "Idle"
		elif player.state == 1:
			state = "Moving"
		elif player.state == 2:
			state = "Falling"
		elif player.state == 3:
			state = "Crouching"
		elif player.state == 4:
			state = "Dead"
		
		RightInfo.text += str("State: ", state, "\n")
		RightInfo.text += str("Position: ", player.translation, "\n")
		RightInfo.text += str("Velocity: ", player.velocity, "\n")
		RightInfo.text += str("Movement speed: ", player.move_speed, "\n")
