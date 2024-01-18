extends RigidBody

func take(owner:NodePath):
	var player = get_tree().get_root().get_node(owner)
	player.inventory.append(self)
	player.emit_signal("inventory_changed")
	queue_free()

func drop():
	var player = get_parent()
	player.get_parent().add_child(self)
	player.emit_signal("inventory_changed")
	queue_free()
