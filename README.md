# Balloon Frontier

Juego original de defensa de torres inspirado en el ritmo de los juegos de globos y oleadas. Está hecho con Godot 4 y no necesita recursos externos.

## Recursos incluidos

- `assets/coral_bend_map.svg`: mapa jugable "Coral Bend".
- `assets/characters/dart_ranger.svg`: personaje de la torre Dardo.
- `assets/characters/boomerang_scout.svg`: personaje de la torre Bumerán.
- `assets/characters/guardian.svg`: guardián decorativo del mapa.

Godot importa automáticamente estos SVG como texturas al abrir el proyecto.

## Abrir y jugar

1. Abre Godot 4.x.
2. Importa o abre la carpeta de este proyecto.
3. Ejecuta la escena principal (`F6` o `F5`).

## Controles

- En la pantalla inicial: haz clic en **Individual**, **Co-op local** o **En línea 1 vs 1**.
- Clic en una carta o `1` / `2`: seleccionar torre.
- Clic sobre la hierba: colocar la torre seleccionada.
- Espacio o el botón **INICIAR OLEADA**: comenzar la siguiente oleada.
- Tras ganar o perder: clic o `R` para reiniciar.

Sobrevive 12 oleadas para ganar. Las torres no se pueden colocar sobre el camino ni demasiado cerca una de otra.

En **Multijugador** se juega en cooperativo local: los dos jugadores comparten recursos y defensa, y se alternan automáticamente cada vez que colocan una torre.

La opción **En línea 1 vs 1** permite conexión directa por IP usando ENet:

1. El anfitrión escribe un puerto (por defecto `7777`) y pulsa **Crear sala**.
2. El rival escribe la IP local o pública del anfitrión, el mismo puerto y pulsa **Unirse a sala**.
3. Al conectarse, ambos entran en un duelo con mapas iguales pero independientes.

Durante el duelo se ven los dos mapas: el tuyo y el del rival. Cada jugador compra torres, inicia oleadas y protege sus propias vidas; gana quien siga con vidas cuando el rival las pierde todas. Para jugar desde redes distintas, el anfitrión debe permitir ese puerto en el firewall/router.
