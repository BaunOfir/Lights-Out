extends CanvasLayer

@onready var control = $Control
@onready var sprite_llave = $Control/SpriteLlave

func _ready() -> void:
	control.position = Vector2.ZERO
	sprite_llave.position=Vector2(20,-40)
	sprite_llave.hide()

func mostrar_llave() -> void:
	sprite_llave.show()

func ocultar_llave() -> void:
	sprite_llave.hide()
