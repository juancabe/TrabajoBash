#!/bin/bash

MESA=()
MESA[Copas]="1 Copas|2 Copas|3 Copas|4 Copas|5 Copas|6 Copas|"
MESA["Oros"]="1 Oros|2 Oros|3 Oros|4 Oros|"
MESA["Espadas"]="1 Espadas|2 Espadas|3 Espadas|4 Espadas|5 Espadas|6 Espadas|7 Espadas|"
MESA["Bastos"]="1 Bastos|2 Bastos|3 Bastos|4 Bastos|5 Bastos|6 Bastos|7 Bastos|"


mostrarMesa(){
    
        # Función que muestra la mesa por pantalla
        UNO=$1
        # Variables
        PALOS=('Copas' 'Oros' 'Espadas' 'Bastos')
        CARTAS_PALO=()

        echo ${MESA[UNO]}
        echo ${MESA["Oros"]}
        echo ${MESA[UNO]}
        echo ${MESA["Bastos"]}
}

METER="Copas 1"

mostrarMesa $METER
