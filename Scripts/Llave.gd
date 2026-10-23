
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.tiene_llave = true

		var ui = get_tree().get_first_node_in_group("UI")

		if ui != null:
			ui.mostrar_llave()

		queue_free()
