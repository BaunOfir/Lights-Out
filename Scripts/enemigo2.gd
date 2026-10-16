
extends CharacterBody2D

@export var velocidad: float = 100.0

@onready var navegacion = $NavigationAgent2D

var jugador


func _ready() -> void:
	await get_tree().process_frame
	jugador = get_tree().get_first_node_in_group("Player")


func _physics_process(_delta: float) -> void:
	var siguiente = navegacion.get_next_path_position()
	var direccion = global_position.direction_to(siguiente)

	velocity = direccion * velocidad
	move_and_slide()


func _on_timer_timeout() -> void:
	if jugador != null:
		navegacion.target_position = jugador.global_position
