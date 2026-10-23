
extends CharacterBody2D

const VELOCIDAD = 700
const ACELERACION = 2000

var guardia_cercano = null
var en_posesion = false
var tiene_llave = false

var textura_original: Texture2D
var escala_original: Vector2

var vida_max = 100
var vida_actual = 100
var mostrar_vida = false

@onready var barra_vida = $BarraVida
@onready var area_posesion = $AreaPosecion
@onready var barra_posesion: ProgressBar = $BarraPosesion
@onready var Timer_posesion = $TimerPosesion


func _ready() -> void:
	textura_original = $Sprite2D.texture
	escala_original = $Sprite2D.scale

	barra_posesion.max_value = Timer_posesion.wait_time
	barra_posesion.value = Timer_posesion.wait_time
	barra_posesion.hide()

	Timer_posesion.timeout.connect(terminar_posesion)
	%TimerMostrarHP.timeout.connect(_esconder_barra_hp)


func _process(_delta: float) -> void:
	if en_posesion:
		barra_posesion.value = Timer_posesion.time_left


func _physics_process(delta: float) -> void:
	var direccion = Input.get_vector(
		"izquierda", "derecha", "arriba", "abajo"
	)

	if direccion != Vector2.ZERO:
		velocity = velocity.move_toward(
			direccion * VELOCIDAD,
			ACELERACION * delta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			ACELERACION * delta
		)

	move_and_slide()

	if Input.is_action_just_pressed("interactuar"):
		if en_posesion:
			Timer_posesion.stop()
			terminar_posesion()
		elif guardia_cercano != null:
			poseer_guardia()

func _on_area_posecion_body_exited(cuerpo: Node2D) -> void:
	if cuerpo == guardia_cercano:
		guardia_cercano = null


func _on_area_posecion_body_entered(cuerpo: Node2D) -> void:
	print("ENTRÓ ALGO: ", cuerpo.name)

	if cuerpo.is_in_group("guardia"):
		guardia_cercano = cuerpo
		print("GUARDIA REGISTRADO: ", guardia_cercano.name)


func poseer_guardia() -> void:
	print("¡POSESION!")

	if guardia_cercano == null:
		return

	if guardia_cercano.persiguiendo:
		return

	var guardia_poseido = guardia_cercano
	var sprite_enemigo = guardia_poseido.get_node("Sprite2D")

	$Sprite2D.texture = sprite_enemigo.texture
	global_position = guardia_poseido.global_position

	en_posesion = true
	barra_posesion.value = Timer_posesion.wait_time
	barra_posesion.show()
	Timer_posesion.start()

	var guarderia = get_tree().get_first_node_in_group("guarderia")

	if guarderia != null:
		guarderia.guardias.erase(guardia_poseido)

	guardia_poseido.queue_free()
	guardia_cercano = null

	print("estas poseido papa")


func recibir_dano(cantidad: int) -> void:
	vida_actual = max(vida_actual - cantidad, 0)

	barra_vida.value = vida_actual
	barra_vida.show()
	mostrar_vida = true

	if vida_actual > vida_max * 0.25:
		%TimerMostrarHP.start()
	else:
		%TimerMostrarHP.stop()

	print("Vida actual: ", vida_actual)


func terminar_posesion() -> void:
	$Sprite2D.texture = textura_original
	$Sprite2D.scale = escala_original

	en_posesion = false
	barra_posesion.hide()

	print("POSESIÓN TERMINADA")

	var guarderia = get_tree().get_first_node_in_group("guarderia")

	if guarderia != null:
		guarderia.reemplazar_guardia()


func _esconder_barra_hp() -> void:
	if vida_actual > vida_max * 0.25:
		barra_vida.hide()
