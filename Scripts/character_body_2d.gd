extends CharacterBody2D

const VELOCIDAD = 600
var guardia_cercano=null
var en_posesion=false
@onready var area_posesion=$AreaPosecion

func _physics_process(delta: float) -> void:

	var direccion = Input.get_vector("izquierda","derecha","arriba","abajo")

	velocity = direccion * VELOCIDAD

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
	print("¡POSESIÓN ACTIVADA!")
	if guardia_cercano==null:
		return
	var sprite_enemigo=guardia_cercano.get_node("Sprite2D")
	var sprite_jugador=$Sprite2D
	
	sprite_jugador.texture = sprite_enemigo.texture
	global_position=guardia_cercano.global_position
	en_posesion=true
	guardia_cercano.queue_free()
	guardia_cercano=null
	print("estas poseido papa")
