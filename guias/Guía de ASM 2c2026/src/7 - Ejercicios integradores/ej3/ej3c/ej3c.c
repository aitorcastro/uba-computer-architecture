#include "../ejs.h"
estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id);
estadisticas_t* calcular_estadisticas_totales(caso_t* arreglo_casos, int largo,estadisticas_t* resultado);
estadisticas_t* calcular_estadisticas_usuario(caso_t* arreglo_casos, int largo, uint32_t usuario_id, estadisticas_t* resultado);
void actualizarContadores(caso_t* pCasoActual, estadisticas_t* resultado);

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){   
    //guardo el resultado en memoria inizializado en cero
    estadisticas_t* resultado = calloc(1, sizeof(estadisticas_t));
    //si el usuario es 0 cuento todo
    if(usuario_id == 0){
        resultado = calcular_estadisticas_totales(arreglo_casos, largo, resultado);
    }
    //si no cuento solo los campos del usuario
    else{
        resultado = calcular_estadisticas_usuario(arreglo_casos, largo, usuario_id, resultado);
    }
    return resultado;
}






estadisticas_t* calcular_estadisticas_totales(caso_t* arreglo_casos, int largo,estadisticas_t* resultado){
    //recorro el arreglo
    for(int i = 0; i < largo; i++){
        //busco caso actual
        caso_t* pCasoActual = &arreglo_casos[i];

        actualizarContadores(pCasoActual, resultado);
    }
    return resultado;
}

estadisticas_t* calcular_estadisticas_usuario(caso_t* arreglo_casos, int largo, uint32_t usuario_id, estadisticas_t* resultado){
    //recorro el arreglo
    for(int i = 0; i < largo; i++){
        //busco caso actual
        caso_t* pCasoActual = &arreglo_casos[i];

        //busco usuario actual
        usuario_t* pUsuarioActual = pCasoActual->usuario;

        if(pUsuarioActual->id == usuario_id){
            actualizarContadores(pCasoActual, resultado);
        }
    }
    return resultado;
}

void actualizarContadores(caso_t* pCasoActual, estadisticas_t* resultado){
    if(strncmp(pCasoActual->categoria, "CLT", 3)==0) resultado->cantidad_CLT++;
    else if(strncmp(pCasoActual->categoria, "RBO", 3)==0)resultado->cantidad_RBO++;
    else if(strncmp(pCasoActual->categoria, "KSC", 3)==0)resultado->cantidad_KSC++;
    else if(strncmp(pCasoActual->categoria, "KDT", 3)==0) resultado->cantidad_KDT++;

    //busco estado
    uint16_t est = pCasoActual->estado;
    //chequeo cual es
    if(est == 0) resultado->cantidad_estado_0++;
    else if(est == 1) resultado->cantidad_estado_1++;
    else if(est == 2) resultado->cantidad_estado_2++;
}