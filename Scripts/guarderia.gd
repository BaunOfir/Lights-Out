extends Node

var guardias:Array=[]
const ESENA_GUARDIA=preload("res://Scenes/PrefabScenes/enemigo_1.0.tscn")

func Crear_guardia()->void:
	var nuevo_guardia=ESENA_GUARDIA.instantiate()
	add_child(nuevo_guardia)
	guardias.append(nuevo_guardia)
	
	conectar_escondites(nuevo_guardia)
	

func reemplazar_guardia() -> void:
	Crear_guardia()
	print("GUARDIA DE REEMPLAZO CREADO")


func conectar_escondites(nuevo_guardia: Node) -> void:
	var escondites = get_tree().get_nodes_in_group("escondites")

	for escondite in escondites:
		escondite.jugador_escondido.connect(nuevo_guardia._on_escondite_jugador_escondido)
		escondite.jugador_salio.connect(nuevo_guardia._on_escondite_jugador_salio)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("guarderia")
	print("guarderia pronta")
	Crear_guardia()
	print("guardias creados",guardias.size())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
