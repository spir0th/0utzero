extends Control

const SIMULATED_DELAY = 0.1

var thread = null
var old_scene = null
var texts = ["Loading..."]

onready var _Color = $"Color"
onready var Text = $"Text"
onready var Progress = $"Progress"
onready var Animator = $"Animator"

func _ready():
	Text.text = texts[len(texts) - 1]

func _scene_load(path):
	get_tree().paused = true
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	Variables.game.map = path
	
	if Animator.has_animation("Fade"):
		Animator.play("Fade")
	else :
		modulate = Color(1, 1, 1, 1)
		_Color.color = Color(0, 0, 0, 1)
	
	old_scene = get_tree().current_scene
	var ril = ResourceLoader.load_interactive(path)
	var total = ril.get_stage_count()
	var res = null
	
	Progress.call_deferred("set_max", total)
	get_tree().current_scene = self
	
	while true:
		Progress.call_deferred("set_value", ril.get_stage())
		OS.delay_msec(int(SIMULATED_DELAY * 1000.0))
		var err = ril.poll()
		
		if err == ERR_FILE_EOF:
			res = ril.get_resource()
			break
		elif err != OK:
			OS.alert("There was something wrong loading the scene.")
			break
	
	call_deferred("_scene_done", res)

func _scene_done(resource):
	get_tree().paused = false
	thread.wait_to_finish()
	
	if Animator.has_animation("Fade"):
		Animator.play_backwards("Fade")
	else :
		modulate = Color(0, 0, 0, 0)
		_Color.color = Color(0, 0, 0, 0)
	
	var new_scene = resource.instance()
	get_tree().root.remove_child(old_scene)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	old_scene.queue_free()

func change_scene(path):
	if not ResourceLoader.exists(path):
		return 
	if thread != null and thread.is_alive():
		return 
	
	thread = Thread.new()
	thread.start(self, "_scene_load", path)
	raise()
