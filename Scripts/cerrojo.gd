extends StaticBody2D

@onready var colision = $CollisionShape2D

var jugador: CharacterBody2D

func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if jugador == null:
		return

	colision.set_deferred("disabled", jugador.tiene_llave)
