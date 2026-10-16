extends CharacterBody2D

const VELOCIDAD = 700
var guardia_cercano=null
var en_posesion=false
var tiene_llave=false

var textura_original:Texture2D
var escala_original:Vector2
@onready var barra_posesion:ProgressBar=$BarraPosesion
@onready var Timer_posesion=$TimerPosesion


var vida_max=100
var vida_actual=100
var mostrar_vida=false
@onready var barra_vida=$BarraVida
@onready var area_posesion=$AreaPosecion

func _ready() -> void:
	textura_original = $Sprite2D.texture
	escala_original = $Sprite2D.scale
	barra_posesion.max_value=Timer_posesion.wait_time
	barra_posesion.value=Timer_posesion.wait_time
	barra_posesion.hide()
	Timer_posesion.timeout.connect(terminar_posesion)
	
func _process(_delta: float) -> void:
	if en_posesion:
		barra_posesion.value = Timer_posesion.time_left

func _physics_process(delta: float) -> void:

	var direccion = Input.get_vector("izquierda","derecha","arriba","abajo")

	velocity = direccion * VELOCIDAD

	

	#velocity = move_toward(velocity, direccion * VELOCIDAD, delta * ACELERACION)

	move_and_slide()
	
	if Input.is_action_just_pressed("interactuar"):
		print("EE EE EE")
		if guardia_cercano!=null:
			print("HAY UN GUARDIA CERCA")
			poseer_guardia()



func _on_area_posecion_body_entered(cuerpo: Node2D) -> void:
	print("ENTRÓ ALGO: ", cuerpo.name)
	if cuerpo.is_in_group("guardia"):
		guardia_cercano = cuerpo
		print("GUARDIA REGISTRADO: ", guardia_cercano.name)
		
func poseer_guardia() -> void:
	print("¡POSESION!")
	if guardia_cercano==null:
		return
		
	if guardia_cercano.persiguiendo:
		return
	var sprite_enemigo=guardia_cercano.get_node("Sprite2D")
	var sprite_jugador=$Sprite2D
	
	sprite_jugador.texture = sprite_enemigo.texture
	global_position=guardia_cercano.global_position
	en_posesion=true
	barra_posesion.value=Timer_posesion.wait_time
	barra_posesion.show()
	Timer_posesion.start()
	guardia_cercano.queue_free()
	guardia_cercano=null
	print("estas poseido papa")

func recibir_dano(cantidad: int) -> void:
	vida_actual = max(vida_actual - cantidad, 0)

	barra_vida.value = vida_actual
	barra_vida.show()
	mostrar_vida = true
	#%TimerMostrarHP.start()
	
	#en ready...
	# %TimerMostrarHP.timeout.connect(_esconder_barra_hp)
	# si queres siempre mostrar el hp si estamos muy dañados, la funcion
	# puede tener un if que mide la vida restante.
	

	print("Vida actual: ", vida_actual)

func terminar_posesion() -> void:
	$Sprite2D.texture = textura_original
	$Sprite2D.scale = escala_original

	en_posesion = false
	barra_posesion.hide()

	print("POSESIÓN TERMINADA")
