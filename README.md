# DOCUMENTACIÓN SCRIPT DEL VIDEOJUEGO
## Sistema de guardias, escondites, posesión y puertas
### **Introducción**
El proyecto implementa un conjunto de mecánicas que permiten al jugador desplazarse por el escenario, ser detectado por guardias enemigos, esconderse para evitar su persecución y poseer a un guardia para aprovechar sus características y atravesar determinadas puertas.
El sistema está dividido en cuatro scripts principales:
1. **Guardia**: controla el patrullaje, la detección del jugador y el regreso a su posición inicial cuando el jugador se esconde.
2. **Jugador**: gestiona el movimiento, la detección de guardias cercanos y la mecánica de posesión.
3. **Escondite**: detecta cuándo el jugador entra o sale de una zona segura y comunica esos cambios mediante señales.
4. **Puerta**: administra la colisión de una puerta en función de si el jugador está poseyendo a un guardia.
La separación de responsabilidades permite que cada objeto tenga su propia lógica y que los diferentes sistemas se comuniquen entre sí.
### 2. Sistema de guardias enemigos
**Objetivo**
El guardia es un enemigo que recorre una zona del escenario, detecta al jugador cuando entra en su área de detección y comienza a perseguirlo. Si el jugador se esconde, el guardia pierde su objetivo, regresa a su posición inicial y retoma su patrullaje.
Tipo de nodo utilizado
`AnimatableBody2D`
Este nodo permite representar un cuerpo físico que puede desplazarse mediante el código. En este caso, se utiliza para controlar el movimiento del guardia.
Variables principales
● `volviendo`: indica si el guardia debe regresar a su posición inicial.
● `cambio`: controla el sentido del patrullaje.
● `jugador`: almacena la referencia al jugador detectado.
● `jugador_escondido`: indica si el jugador está dentro de un escondite.
● `persiguiendo`: indica si el guardia se encuentra en estado de persecución.
● `posXInicio` y `posXFin`: establecen los límites horizontales del patrullaje.
● `velocidad`: determina la velocidad de movimiento.
● `posicion_inicial`: almacena la posición global donde comienza el guardia.
Las variables `posXInicio`, `posXFin` y `velocidad` están declaradas con `@export`, lo que permite modificarlas desde el Inspector de Godot sin tener que editar el código cada vez.
2.1. Inicialización
En la función `_ready()` se guarda la posición inicial del guardia:
`posicion_inicial` = global_position
También se establece el límite inicial del patrullaje a partir de la coordenada horizontal del nodo.
De esta forma, el guardia conserva una referencia al lugar al que debe regresar cuando pierde al jugador.
2.2. Patrullaje
El movimiento se ejecuta en `_physics_process(delta)`, una función que Godot llama durante los pasos de física.
El guardia se desplaza horizontalmente entre dos límites: `posXInicio` y `posXFin`.
● Si se desplaza hacia el límite final, avanza hasta `posXFin`.
● Al alcanzar el límite, cambia el valor de cambio.
● Cuando se desplaza hacia el límite inicial, retrocede hasta posXInicio.
● Al alcanzar ese límite, vuelve a cambiar el sentido del movimiento.
La expresión `velocidad * delta` permite ajustar el desplazamiento al tiempo transcurrido entre actualizaciones, en lugar de depender directamente de la cantidad de fotogramas por segundo.
El código también modifica `scale.x` para cambiar la orientación horizontal del sprite. En la versión actual se asigna -1 en ambos límites, por lo que la orientación podría necesitar un ajuste posterior para reflejar correctamente los dos sentidos del movimiento.
2.3. Detección y persecución
La función `_on_area_2d_body_entered(body)` se ejecuta cuando otro cuerpo entra en el área de detección del guardia.
Primero comprueba si el cuerpo pertenece al grupo Player:
`body.is_in_group("Player")`
Si pertenece a ese grupo y el jugador no está escondido, se guarda su referencia en la variable jugador. Además, se cancela el estado de regreso mediante volviendo = false.
Durante el procesamiento de física, el guardia comprueba si jugador != null. Si existe una referencia válida, calcula la dirección hacia el jugador con:
global_position.direction_to(jugador.global_position)
Después, utiliza esa dirección y la velocidad para avanzar hacia su objetivo.
Esto permite que el guardia persiga al jugador desde distintas posiciones del escenario, en lugar de moverse únicamente de izquierda a derecha.
2.4. Regreso a la posición inicial
Cuando el jugador entra en un escondite, el guardia recibe la señal correspondiente y ejecuta _on_escondite_jugador_escondido().
Esta función realiza tres acciones:
1. Elimina la referencia al jugador asignando null a jugador.
2. Marca que el jugador está escondido.
3. Activa volviendo para iniciar el regreso.
El movimiento de regreso se realiza con move_toward, que desplaza gradualmente al guardia hacia posicion_inicial sin sobrepasar el objetivo.
Cuando la distancia entre ambas posiciones es inferior a 2.0, el guardia se coloca exactamente en su posición inicial, desactiva el regreso y vuelve al patrullaje.
La instrucción return al finalizar los bloques de movimiento evita que el guardia ejecute simultáneamente varias lógicas de desplazamiento durante la misma actualización.
2.5. Salida del escondite
La función _on_escondite_jugador_salio() se ejecuta cuando el jugador abandona el área de escondite. En ese momento, jugador_escondido vuelve a false.
Esto permite que el guardia vuelva a considerar al jugador como un objetivo válido cuando lo detecte nuevamente.
Resultado: se obtiene un enemigo con tres comportamientos principales: patrullar, perseguir y regresar a su posición inicial.
3. Sistema de movimiento y posesión del jugador
Objetivo
El jugador puede desplazarse en cuatro direcciones y poseer a un guardia cercano mediante una acción de interacción. Al hacerlo, toma la textura del sprite del enemigo y se coloca en su posición.
Tipo de nodo utilizado
`CharacterBody2D`
Este nodo está diseñado para personajes que necesitan movimiento controlado por código y detección de colisiones físicas.
3.1. Movimiento del jugador
La variable VELOCIDAD establece la velocidad de movimiento en 150.0.
Para obtener la dirección de entrada se utiliza:
Input.get_vector("izquierda", "derecha", "arriba", "abajo")
Esta función combina las cuatro acciones configuradas en el mapa de entradas de Godot y devuelve un vector de dirección.
Luego se calcula la velocidad:
velocity = direccion * VELOCIDAD
Finalmente, move_and_slide() aplica el movimiento al personaje teniendo en cuenta las colisiones físicas.
Este sistema permite desplazarse en horizontal y vertical, incluyendo diagonales, utilizando las acciones configuradas en el proyecto.
3.2. Detección de guardias cercanos
La variable guardia_cercano almacena una referencia al guardia que se encuentra dentro del área de posesión.
El nodo AreaPosecion detecta los cuerpos que entran en su área mediante la señal body_entered, conectada a la función _on_area_posecion_body_entered(cuerpo).
La función verifica si el cuerpo pertenece al grupo guardia. Si la comprobación es correcta, guarda ese cuerpo en guardia_cercano.
La comprobación por grupos permite identificar a los enemigos sin depender exclusivamente del nombre de cada nodo.
3.3. Activación de la posesión
Dentro de `_physics_process()`, el código comprueba si se acaba de pulsar la acción interactuar mediante Input.is_action_just_pressed("interactuar").
Esta función detecta el momento en que se presiona la acción, evitando que la posesión se active continuamente mientras el botón permanece pulsado.
Si existe un guardia registrado en guardia_cercano, se llama a poseer_guardia().
La acción interactuar debe estar configurada previamente en el apartado de mapa de entradas de Godot.
3.4. Transferencia del sprite
La función `poseer_guardia()` comienza comprobando que exista un guardia válido. Si no lo hay, termina sin ejecutar el resto del procedimiento.
Después obtiene las referencias a los sprites:
● sprite_enemigo: sprite del guardia.
● sprite_jugador: sprite del jugador.
La instrucción:
sprite_jugador.texture = sprite_enemigo.texture
copia la textura del enemigo al sprite del jugador.
Esto cambia la imagen visible del personaje, pero no transfiere automáticamente el resto de las propiedades del guardia, sus animaciones ni su comportamiento.
3.5. Cambio de posición y eliminación del guardia
Una vez obtenida la textura, se ejecuta:
global_position = guardia_cercano.global_position
Así, el jugador se coloca en la posición global donde se encontraba el guardia.
A continuación, en_posesion pasa a true. Esta variable funciona como un indicador de estado que otros objetos pueden consultar para modificar su comportamiento.
Finalmente, queue_free() solicita la eliminación del guardia de la escena y guardia_cercano vuelve a null.
Resultado: el jugador adopta visualmente la apariencia del guardia, ocupa su posición y activa un estado que permite utilizar la mecánica de puertas.
Limitación actual: la posesión modifica la textura y la posición, pero no implementa todavía un sistema completo de cambio de personaje con transferencia de animaciones o habilidades.
4. Sistema de escondites
Objetivo
Los escondites son zonas del escenario que permiten al jugador ocultarse de los guardias. Su función es detectar la entrada y salida del jugador y comunicar estos acontecimientos al resto del sistema.
Tipo de nodo utilizado
Area2D
Este nodo permite detectar cuerpos que entran o salen de una región sin funcionar como una pared física que bloquee su movimiento.
4.1. Señales personalizadas
El script declara dos señales:
● jugador_escondido
● jugador_salio
Las señales permiten comunicar un acontecimiento a otros nodos sin que el escondite tenga que controlar directamente todo el comportamiento del guardia.
Esta separación reduce la dependencia entre los scripts y facilita ampliar el sistema posteriormente.
4.2. Entrada al escondite
La función _on_body_entered(body) se ejecuta cuando un cuerpo entra en el área.
Primero comprueba si pertenece al grupo Player. Si es así, emite la señal:
jugador_escondido.emit()
El guardia que tiene conectada esta señal puede reaccionar inmediatamente: elimina la referencia al jugador y activa su regreso a la posición inicial.
4.3. Salida del escondite
La función _on_body_exited(body) realiza una comprobación equivalente cuando un cuerpo abandona el área.
Si se trata del jugador, emite:
jugador_salio.emit()
El guardia recibe esta señal y actualiza su variable jugador_escondido para indicar que el jugador ya no está oculto.
4.4. Configuración necesaria
Para que el sistema funcione, deben cumplirse las siguientes condiciones:
● El jugador debe pertenecer al grupo Player.
● El escondite debe tener un CollisionShape2D correctamente configurado.
● Las señales de entrada y salida deben estar conectadas a las funciones correspondientes del script del escondite.
● Las señales personalizadas del escondite deben estar conectadas a las funciones del guardia.
Resultado: el escondite actúa como un sistema de comunicación que informa de los cambios de estado del jugador y permite modificar el comportamiento de los enemigos.
5. Sistema de puertas condicionado por la posesión
Objetivo
La puerta impide el paso del jugador mientras este no esté poseyendo a un guardia. Cuando la posesión se activa, la colisión se deshabilita y el jugador puede atravesarla.
Tipo de nodo utilizado
StaticBody2D
Este nodo representa un cuerpo físico estático, apropiado para elementos del escenario que normalmente no se desplazan, como una puerta.
El nodo hijo CollisionShape2D define la forma utilizada para detectar y bloquear colisiones.
5.1. Referencia al jugador
En _ready(), el script busca al primer nodo que pertenezca al grupo Player:
jugador = get_tree().get_first_node_in_group("Player")
De esta manera, la puerta obtiene una referencia al personaje y puede consultar su variable en_posesion.
Esto evita tener que asignar manualmente el jugador desde el Inspector, siempre que exista un nodo en el grupo indicado.
5.2. Comprobación del estado
La función _process(_delta) se ejecuta durante el procesamiento normal de cada fotograma.
Primero comprueba si la referencia al jugador es válida:
if jugador == null: return
Si no existe el jugador, la función termina para evitar intentar acceder a una referencia inexistente.
Si el jugador existe, el código ejecuta:
colision.set_deferred("disabled", jugador.en_posesion)
Esta instrucción modifica la propiedad disabled del nodo de colisión utilizando set_deferred().
El valor de la propiedad depende directamente del estado de posesión:
● en_posesion = false: disabled recibe false, por lo que la colisión permanece habilitada y la puerta bloquea el paso.
● en_posesion = true: disabled recibe true, por lo que la colisión se deshabilita y el jugador puede atravesar la puerta.
5.3. ¿Por qué se utiliza set_deferred()?
Godot puede impedir que ciertas propiedades físicas se modifiquen directamente mientras el motor está procesando colisiones.
set_deferred() programa el cambio para un momento seguro del procesamiento. Esto evita problemas al modificar el estado de una colisión durante la ejecución del juego.
5.4. Ventaja de este sistema
La puerta no necesita detectar por sí misma si el jugador ha poseído a un guardia. Solo consulta una variable que ya existe en el script del personaje.
Esto permite reutilizar el sistema en distintas puertas y agregar condiciones nuevas en el futuro sin tener que rehacer la mecánica de posesión.
Resultado: se obtiene una puerta que funciona como un obstáculo condicionado por el estado del jugador, sin necesidad de desactivar todas sus colisiones.
