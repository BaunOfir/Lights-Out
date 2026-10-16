extends Area2D

@onready var colision = $CollisionShape2D

var jugador: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	jugador=get_tree().get_first_node_in_group("Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.tiene_llave=true
		queue_free()
	pass # Replace with function body.


func _on_escondite_jugador_escondido() -> void:
	pass # Replace with function body.
