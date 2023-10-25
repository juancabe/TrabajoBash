#!/bin/bash

# Define un array de jugadores con sus respectivos mazos
JUGADORES=("7 Bastos|5 Oros|10 Copas" "3 Espadas|5 Oros|9 Oros" "2 Copas|4 Espadas|As Oros")

# Inicializa la variable JUGADOR_ID en -1 (ningún jugador encontrado)
JUGADOR_ID=-1

# Cadena a buscar
CARTA_BUSCADA="5 Oros"

# Bucle para buscar la carta en los mazos de los jugadores
for ((i = 0; i < ${#JUGADORES[@]}; i++)); do
    if [[ ${JUGADORES[i]} == *$CARTA_BUSCADA* ]]; then
        JUGADOR_ID=$i
        break
    fi
done

# Comprueba si se encontró el jugador que tiene la carta
if [ $JUGADOR_ID -ne -1 ]; then
    echo "La carta '$CARTA_BUSCADA' se encontró en el mazo del jugador $JUGADOR_ID"
else
    echo "La carta '$CARTA_BUSCADA' no se encontró en ningún mazo de jugador"
fi
