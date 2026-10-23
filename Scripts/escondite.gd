extends Area2D

signal jugador_escondido
signal jugador_salio


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("escondido")
		jugador_escondido.emit()
	pass # Replace with function body.
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("desescondido")
		jugador_salio.emit()
	pass # Replace with function body.
