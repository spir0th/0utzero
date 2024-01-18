extends Area

export (String) var scene_to_load = Globals.MAP_MAIN_SCENE
export (bool) var trigger_on_exit = false

func _process(_delta):
	if scene_to_load == null:return 

func _on_SceneLoaderArea_body_entered(_body):
	if _body != Variables.game.player or trigger_on_exit:return 
	SceneManager.change_scene(scene_to_load)

func _on_SceneLoaderArea_body_exited(_body):
	if _body != Variables.game.player or not trigger_on_exit:return 
	SceneManager.change_scene(scene_to_load)
