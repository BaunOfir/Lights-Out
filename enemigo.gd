extends AnimatableBody2D

var volviendo = false
var cambio = false
var jugador = null
var jugador_escondido = false
var persiguiendo=true
@export var posXInicio = 0
@export var posXFin = 1300
@export var velocidad = 70

var posicion_inicial = Vector2.ZERO


func _ready() -> void:
	posicion_inicial = global_position
	posXInicio = position.x


func _physics_process(delta: float) -> void:

	# Volver a pos.inicio
	if volviendo and persiguiendo:
		global_position = global_position.move_toward(posicion_inicial,velocidad * delta)
		
		if global_position.distance_to(posicion_inicial) < 2.0:
			global_position = posicion_inicial
			volviendo = false
			cambio = true
			scale.x = -1
			persiguiendo=false
		return


	# Perseguir
	if jugador != null:
		var direccion = global_position.direction_to(jugador.global_position)
		global_position += direccion * velocidad * delta
		persiguiendo=true
		return


	# Patrullar
	if cambio:
		position.x += velocidad * delta

		if position.x >= posXFin:
			position.x = posXFin
			cambio = false
			scale.x = -1

	else:
		position.x -= velocidad * delta

		if position.x <= posXInicio:
			position.x = posXInicio
			cambio = true
			scale.x = -1


# detecta al player
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not jugador_escondido:
			jugador = body
			volviendo=false
			print("que es eso??")
			
# Player entra al escondite 
func _on_escondite_jugador_escondido() -> void:
	print("PIKACHU REGRESA")

	jugador = null
	jugador_escondido = true
	volviendo = true
	
func _on_escondite_jugador_salio() -> void:
	jugador_escondido = false
	print("Donde esta esa cosa??")
	
