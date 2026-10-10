#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t* card) {
    //campo __dir
    card->__dir = malloc(2*sizeof(directory_entry_t*));

        //entrada sleep
        card->__dir[0] = create_dir_entry("sleep",sleep);

        //entrada wakeup
        card->__dir[1] = create_dir_entry("wakeup", wakeup);

    //campo __dir_entries
    card->__dir_entries = 2;
}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {
    //alloco la carta
    fantastruco_t* carta = malloc(sizeof(fantastruco_t));

    //inicializo campo dir y dir entries
    init_fantastruco_dir(carta);

    //inicializo campo archetype
    carta->__archetype=NULL;

    //inicializo campo face_up
    carta->face_up=1;

    //devuelvo la carta
    return carta;
    
}
