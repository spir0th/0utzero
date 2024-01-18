extends CanvasLayer

onready var Console = $"Console"

func _input(event):
	if event.is_action_pressed("ui_pause") and Variables.game.session:
		if not is_visible():
			show()
		else :
			hide()
	if event.is_action_pressed("ui_pause_console"):
		if not Console.is_visible():
			if not is_visible():
				show()
			
			Console.show()
		else :
			Console.hide()

func _process(_delta):
	if is_visible():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Variables.game.session:
		get_tree().paused = visible
