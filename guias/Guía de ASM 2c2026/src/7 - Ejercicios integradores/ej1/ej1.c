#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador) {
	// tengo que recorrer el indice, buscar en el inventario los elementos a los que el indice apunta, y compararlos. a la primera puedo saltar
	//recorro el indice

	bool resultado = true;
	for (size_t i = 0; i < tamanio - 1; i++)
	{
		size_t j = i + 1;
		
		uint16_t indice_i = indice[i];
		uint16_t indice_j = indice[j];

		item_t* puntero_i = inventario[indice_i];
		item_t* puntero_j = inventario[indice_j];

		if (!comparador(puntero_i, puntero_j)) resultado = false;
	}

	return resultado;
}

/**
 * OPCIONAL: implementar en C
 */
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio) {
	// ¿Cuánta memoria hay que pedir para el resultado?
		// es un array de punteros a item luego un array de cosas de 8 bytes. Cuantas cosas? -> tamanio. Luego necesito alocar tamanio * 8
	size_t memoriaInventarioNuevo = (size_t) tamanio * 8;
	item_t** resultado = malloc(memoriaInventarioNuevo);

	
	for (size_t i = 0; i < tamanio; i++)
	{
		resultado[i] = inventario[indice[i]];
	}
	
	return resultado;
}
