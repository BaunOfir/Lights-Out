extends AnimatableBody2D

var cambio = false
var jugador = null
var jugador_escondido = false
var persiguiendo = false
var volviendo = false
var espera = false
var dentro_luz = false
var puede_hacer_dano = true

var posicion_inicial: Vector2

@export var dano_luz = 10
@export var intervalo_dano = 1.0
@export var posXInicio = 0.0
@export var posXFin = 1300.0
@export var velocidad = 70.0


func _ready() -> void:
	posicion_inicial = global_position
	posXInicio = position.x


func _physics_process(delta: float) -> void:

	# Si está esperando en un extremo, se detiene
	if espera:
		return

	# REGRESAR A LA POSICIÓN INICIAL
	if volviendo:
		global_position = global_position.move_toward(
			posicion_inicial,
			velocidad * delta
		)

		if global_position.distance_to(posicion_inicial) < 2.0:
			global_position = posicion_inicial
			volviendo = false
			persiguiendo = false
			cambio = true
			

		return

	# HACER DAÑO DENTRO DE LA LUZ
	if jugador != null and dentro_luz and puede_hacer_dano:
		hacer_dano()

	# PERSEGUIR AL JUGADOR
	if jugador != null and not jugador_escondido:
		var direccion = global_position.direction_to(
			jugador.global_position
		)

		global_position += direccion * velocidad * delta
		persiguiendo = true
		return

	# PATRULLA NORMAL
	persiguiendo = false

	if cambio:
		position.x += velocidad * delta

		if position.x >= posXFin:
			position.x = posXFin
			$rotacion.start()
			espera = true
			cambio = false
			scale.x *= -1

	else:
		position.x -= velocidad * delta

		if position.x <= posXInicio:
			position.x = posXInicio
			$rotacion.start()
			espera = true
			cambio = true
			scale.x *= -1


# EL JUGADOR ENTRA EN LA LUZ
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not jugador_escondido:
		jugador = body
		dentro_luz = true
		espera = false

		print("¡GUARDIA DETECTÓ AL JUGADOR!")


# EL JUGADOR SALE DE LA LUZ
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == jugador:
		dentro_luz = false
		print("JUGADOR FUERA DE LA LUZ")


# EL JUGADOR SE ESCONDE
func _on_escondite_jugador_escondido() -> void:
	jugador = null
	dentro_luz = false
	jugador_escondido = true
	persiguiendo = false
	volviendo = true
	espera = false

	print("JUGADOR ESCONDIDO: GUARDIA REGRESA")


# EL JUGADOR SALE DEL ESCONDITE
func _on_escondite_jugador_salio() -> void:
	jugador_escondido = false

	print("JUGADOR SALIÓ DEL ESCONDITE")


# HACER DAÑO PERIÓDICO
func hacer_dano() -> void:
	if not puede_hacer_dano:
		return

	puede_hacer_dano = false

	if jugador != null and dentro_luz and not jugador_escondido:
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(dano_luz)

	await get_tree().create_timer(intervalo_dano).timeout

	puede_hacer_dano = true


# TERMINA LA PAUSA EN LOS EXTREMOS
func _on_rotacion_timeout() -> void:
	espera = false
