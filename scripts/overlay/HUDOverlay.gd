extends CanvasLayer

onready var Health = $"Health"
onready var Interact = $"Interact"

func _process(_delta):
	if not is_visible():
		return 
	
	update_health()
	update_interaction_text()

func update_health():
	if Variables.game.player == null:
		return 
	
	var player = Variables.game.player
	Health.text = "Health: " + str(player.health) + "%"

func update_interaction_text():
	pass

func popup_interaction():
	Interact.show()

func hide_interaction():
	Interact.hide()
