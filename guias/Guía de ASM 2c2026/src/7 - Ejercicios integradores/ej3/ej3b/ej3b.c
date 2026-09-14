#include "../ejs.h"

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){
    //mantengo un indice de casos_a_revisar
    int indiceCasosARevisar = 0;

    //recorro el arreglo de casos
    for(int i = 0; i < largo; i++){
        //busco direccion caso actual
        caso_t* pCasoActual = &arreglo_casos[i];
        //busco nivel del usuario del caso actual
        uint32_t nivelUsuarioActual = pCasoActual->usuario->nivel;
        
        switch (nivelUsuarioActual)
        {
        case 0:
            //lo agrego directo a casos_a_revisar
            casos_a_revisar[indiceCasosARevisar] = arreglo_casos[i];
            //actualizo el indice
            indiceCasosARevisar++;
            break;
        
        case 1:
        case 2:
            //llamo a la funcion
            uint16_t resFuncion = funcion(pCasoActual);
            switch (resFuncion)
            {
            //si el res ses 0:
            case 0:
                //chequeo la categoria
                //si es "CLT" estado = 2
                if (strncmp(pCasoActual->categoria, "CLT", 4) == 0) pCasoActual->estado = 2;
                //si no, si es "RBO estado == 2"
                else if(strncmp(pCasoActual->categoria, "RBO", 4) == 0) pCasoActual->estado = 2;
                //si no:
                else {
                    //agrego a casos a revisar
                    casos_a_revisar[indiceCasosARevisar] = arreglo_casos[i];
                    //actualizo indice
                    indiceCasosARevisar++;
                }
                break;
            
            case 1:
            //si el res es 1
            //solo cierro (estado = 1)
                pCasoActual->estado = 1;
                break;
            
            default:
                break;
            }
            break;
        
        default:
            break;
        }
    }
    //si es nivel 0
        //lo agrego directo a casos_a_revisar
        //actualizo el indice
    //si es nivel 1 o 2
        //llamo a la funcion
        //si el resultado es 0
            //chequeo la categoria
            //si es "CLT" 
                //marco el estado = 2
            //si es "RBO"
                //marco el estado = 2
            //si no
                //agrego a casos a revisar
                //actualizo el infice
        //si el resultado es 1
            //marco el estado = 1
}
