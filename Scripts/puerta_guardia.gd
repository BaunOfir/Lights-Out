extends StaticBody2D

@onready var colision = $CollisionShape2D
var jugador: CharacterBody2D
var abierto = false

func _ready() -> void:
	jugador = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	if jugador == null:
		return

	abierto = jugador.en_posesion

	if abierto:
		colision.set_deferred("disabled", true)
	
