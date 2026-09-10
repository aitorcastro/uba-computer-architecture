#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = false;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
    //hash de la unidad compartida para comparar
    uint32_t hashAComparar = fun_hash(compartida);

    //recorro el mapa
    for (size_t fila = 0; fila < 255; fila++) {
        for (size_t columna = 0; columna < 255; columna ++) {
            //busco puntero a unidad actual
            attackunit_t* pUnidadActual = mapa[fila][columna];

            //calculo hash unidad actual solo si es dif a null
            if (pUnidadActual != NULL) {
                uint32_t hashUnidadActual = fun_hash(pUnidadActual);

                //comparo con la que tengo que buscar, si corresponde hago el cambio
                if (hashAComparar == hashUnidadActual && pUnidadActual != compartida) {
                    //decremento las referencias de la actual
                    uint8_t ref = pUnidadActual->references;
                    pUnidadActual->references = ref > 0? ref - 1: 0;
                    //apunto el lugar del mapa a la compartida
                    mapa[fila][columna] = compartida;
                    //incremento las referencias de la compartida
                    compartida->references++;
                }
            }

        }
    }
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
    //tengo que calcular cuantro combustible extr atotal se uso
    
    uint32_t resultado = 0;
    //recorro el mapa
    for (size_t fila = 0; fila < 255; fila++) { 
        for (size_t columna = 0; columna < 255; columna++) { 
            //comparo combustible de la unidad actual, vs combustible base
            attackunit_t* pUnidadActual = mapa[fila][columna];

            if (pUnidadActual != NULL) {
                uint16_t combustibleBase = fun_combustible(pUnidadActual->clase);
                uint16_t combustibleActual = pUnidadActual->combustible;         

                if (combustibleActual > combustibleBase) {
                    resultado += combustibleActual - combustibleBase;
                }
            }
        }
    }

    return resultado;

}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
}
