extends Area2D

@onready var colision = $CollisionShape2D

var jugador: CharacterBody2D

func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if jugador == null:
		return

	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player")and jugador.tiene_llave==true:
		jugador.tiene_llave=false
		var ui = get_tree().get_first_node_in_group("UI")
		
		ui.ocultar_llave() 
		queue_free()
	pass # Replace with function body.
