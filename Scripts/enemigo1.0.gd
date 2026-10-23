
extends CharacterBody2D

@export var velocidad: float = 200.0
@export var dano_luz: int = 10
@export var intervalo_dano: float = 1.0
@export var punto_final: Vector2 = Vector2(348,25)
@export var velocidad_rotacion: float = 5.0

@onready var navegacion: NavigationAgent2D = $NavigationAgent2D

var jugador: Node2D = null
var posicion_inicial: Vector2=Vector2(-899,71)

var volviendo: bool = true
var persiguiendo: bool = false
var dentro_luz: bool = false
var jugador_escondido: bool = false
var lastima: bool = true

var ir_final: bool = true
var patrullaje_activo: bool = true


# para volver a mostrar el guardia, podemos usar el patron STATE.
# Guardia tiene dos estados: Activo y oculto.
# "Matar" un guardia poseyendolo simplemente coloca al guardia en estado oculto.
# En vez de hacer queue_free, colocamos al guardia en ese estado, que lo oculta
# y no pasa por las partes importantes del metodo _process

# ALTERNATIVAMENTE:
# Crear un punto de respawn de guardias.-
# creamos un segundo guardia, sacado de un pool comun-
# lo "respawneamos" (simplemente aparece en la posicion de la estacion de guardias)-
#... la guarderia
# le hacemos remove_child al guardia, lo ponemos en un array en un manager global
# y cuando vuelve a la escena, simplemente pathfindea.
# lo ideal seria que tuviera un estado RETORNANDO

func _ready() -> void:
	
	

	await get_tree().physics_frame


func _physics_process(delta: float) -> void:

	# Regresa al inicio del patrullaje
	if volviendo:
		navegacion.target_position = posicion_inicial
		$Alerta.hide()
	# Persige al jugador /utilizo la target de la navegacion
	# y le adjudico la posicion del jugador en la esena
	elif persiguiendo and jugador != null and not jugador_escondido:
		$Alerta.show()
		navegacion.target_position = jugador.global_position

	# Patrulla entre 2 puntos el target en esta oportunidad
	# sera el punto inicial o el punto final que establesimos previamente
	elif patrullaje_activo:
		if ir_final:
			navegacion.target_position = punto_final
		else:
			navegacion.target_position = posicion_inicial

	#  direccion del movimiento: siguiente es el proximo punto que marca la navegacion
	# direccione es la psiciom de dicho punto
	var siguiente = navegacion.get_next_path_position()
	var direccion = global_position.direction_to(siguiente)

	# ver hacia objetivo
	if direccion.length() > 0.01:
		var angulo_objetivo = direccion.angle() + PI / 2

		rotation = rotate_toward(
			rotation,
			angulo_objetivo,
			velocidad_rotacion * delta
		)

	# movimiento del enemigo
	velocity = direccion * velocidad
	move_and_slide()

	# daño
	if dentro_luz and not jugador_escondido:
		hacer_dano()

	# vuelve a patrullar
	if volviendo and global_position.distance_to(posicion_inicial) < 10.0:
		volviendo = false
		ir_final = true
		velocity = Vector2.ZERO

	# volver al inicio de patrulla
	elif not volviendo and not persiguiendo and patrullaje_activo:
		$Alerta.hide()
		if global_position.distance_to(navegacion.target_position) < 10.0:
			ir_final = not ir_final
			velocity = Vector2.ZERO


# dentro de la luz
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not jugador_escondido:
		jugador = body
		dentro_luz = true
		persiguiendo = true
		volviendo=false
		print("¡DETRAS DE TI INBECIL!")


# sale de la luz
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == jugador:
		dentro_luz = false
		print("SAFANDO")


# jugador escondido
func _on_escondite_jugador_escondido() -> void:
	$Alerta.hide()
	jugador_escondido = true
	dentro_luz = false

	if persiguiendo:
		jugador = null
		persiguiendo = false
		volviendo = true
		print("PIKACHU REGRESA")


# puedes buscar
func _on_escondite_jugador_salio() -> void:
	jugador_escondido = false


# daño al estar dentro de la luz
func hacer_dano() -> void:
	if not lastima:
		return

	lastima = false
	
	if  dentro_luz and not jugador_escondido:
		if jugador.has_method("recibir_dano"):
			jugador.recibir_dano(dano_luz)
#timer 
	await get_tree().create_timer(intervalo_dano).timeout
	lastima = true
	
func puede_ser_poseido() -> bool:
	return not persiguiendo
