#include "../ejs.h"

// Función auxiliar para contar casos por nivel
void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores) {    
    
    for (int i = 0; i < largo; i++) {
        //agarro el caso
        caso_t casoActual = arreglo_casos[i];
        //agarro el cliente
        usuario_t* usuarioActual = casoActual.usuario;
        //agarro el nivel
        uint32_t nivel = usuarioActual->nivel;

        switch (nivel)
        {
        case 0:
            contadores[0] += 1;
            break;

        case 1:
            contadores[1] += 1;
            break;

        case 2:
            contadores[2] += 1;
            break;
        
        default:
            break;
        }
    }
}


segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {
    //cuento casos por nivel
    int contadores[3] = {0};
    contar_casos_por_nivel(arreglo_casos, largo, contadores);
    
    //creo segmentacion
    segmentacion_t* resultado = malloc(sizeof(segmentacion_t));
    //asigno sus arreglos
    resultado->casos_nivel_0 = contadores[0] > 0? malloc(contadores[0] * sizeof(caso_t)) : NULL;
    resultado->casos_nivel_1 = contadores[1] > 0? malloc(contadores[1] * sizeof(caso_t)) : NULL;
    resultado->casos_nivel_2 = contadores[2] > 0? malloc(contadores[2] * sizeof(caso_t)) : NULL;

    //creo array para saber donde agregar elementos
    int tamArrays[3] = {0};
    //recorro el arreglo
    for(int i = 0; i < largo; i++){
        //agarro el caso
        caso_t casoActual = arreglo_casos[i];
        //agarro el cliente
        usuario_t* usuarioActual = casoActual.usuario;

        //agarro el nivel
        uint32_t nivel = usuarioActual->nivel;

        switch (nivel)
        {
        case 0:
            //si es 0 lo agrego al nivel 0
            resultado->casos_nivel_0[tamArrays[0]] = casoActual;
            tamArrays[0] = tamArrays[0]+1;
            break;

        case 1:
            //si es 1 lo agrego al nivel 1
            resultado->casos_nivel_1[tamArrays[1]] = casoActual;
            tamArrays[1] = tamArrays[1]+1;
            break;

        case 2:
            //si es 2 lo agrego al nivel 2
            resultado->casos_nivel_2[tamArrays[2]] = casoActual;
            tamArrays[2] = tamArrays[2]+1;
            break;
        
        default:
            break;
        }
    }
    return resultado;
}



