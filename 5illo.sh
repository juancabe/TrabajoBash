#!/bin/bash


#Variables globales

CONFIG_FILE="./config.cfg"
LINEAJUGADORES=""
LINEAESTRATEGIAS=""
LINEALOGS=""
BARAJA=()
JUGADORES=()
MESA=()
#Iniciamos la mesa
Copas=1
Oros=2
Espadas=3
Bastos=4

MESA[Copas]=""
MESA[Oros]=""
MESA[Espadas]=""
MESA[Bastos]=""


#############################
#                           #
#      FUNCIONES MAIN       #
#                           #
#############################

compruebaConfig() {
    # Variables
    
    if [ ! -f "$CONFIG_FILE" ]
    then
        echo "No existe el fichero de configuración"
        exit 1
    fi

    LINEAJUGADORES=$(grep "JUGADORES=" < "$CONFIG_FILE" | cut -d "=" -f 2)
    LINEAESTRATEGIAS=$(grep "ESTRATEGIA=" < "$CONFIG_FILE" | cut -d "=" -f 2)
    LINEALOGS=$(grep "LOG=" < "$CONFIG_FILE" | cut -d "=" -f 2)

    if [ -z $LINEAJUGADORES ]
    then
        echo "No existe la variable JUGADORES"
        exit 1
    fi
    if [ -z $LINEAESTRATEGIAS ]
    then
        echo "No existe la variable ESTRATEGIAS"
        exit 1
    fi
    if [ -z $LINEALOGS ]
    then
        echo "No existe la variable LOG"
        exit 1
    fi

    # Comprobamos que LINEAJUGADORES esté entre 2 y 4, LINEAESTRATEGIAS entre 0 y 2 y LINEALOGS sea una ruta relativa a un archivo valida
    if [ $LINEAJUGADORES -lt 2 ] || [ $LINEAJUGADORES -gt 4 ]
    then
        echo "El valor de JUGADORES no es válido"
        exit 1
    fi
    if [ $LINEAESTRATEGIAS -lt 0 ] || [ $LINEAESTRATEGIAS -gt 2 ]
    then
        echo "El valor de ESTRATEGIAS no es válido"
        exit 1
    fi
    if [ ! -f $LINEALOGS ]
    then
        echo "El valor de LOG no es válido"
        exit 1
    fi
}
#############################
#                           #
# FUNCIONES CONFIGURACION   #
#                           #
#############################

configurarJugadores(){

    # Función que permite configurar el número de jugadores del archivo de configuración

    # Variables
    jugadores=""
    jugadoresValidos=""

    # Pedimos el número de jugadores
    read -p "Introduzca el número de jugadores (2-4): " jugadores

    # Comprobamos que el número de jugadores sea válido
    if [ $jugadores -lt 2 ] || [ $jugadores -gt 4 ]
    then
        echo "El número de jugadores no es válido"
        configurarJugadores
    fi

    # Cambiamos el valor de la variable JUGADORES en el archivo de configuración
    sed "s/JUGADORES=$LINEAJUGADORES/JUGADORES=$jugadores/g" "$CONFIG_FILE" > tmpfile && mv tmpfile "$CONFIG_FILE"
    LINEAJUGADORES=$jugadores
}

configurarLogs(){
    # Funcion para cambiar la ruta del archivo de logs en CONFIG_FILE

    # Variables
    rutaLogs=""

    # Pedimos la ruta del archivo de logs
    read -p "Introduzca la ruta del archivo de logs: " rutaLogs

    # Comprobamos que la ruta sea válida
    if [ ! -f $rutaLogs ]
    then
        echo "La ruta no es válida"
        configurarLogs
    fi

    #Añadimos \ a las rutas / para que sed no de error
    rutaLogs=$(echo $rutaLogs | sed 's/\//\\\//g')  
    LINEALOGS=$(echo $LINEALOGS | sed 's/\//\\\//g') 

    # Cambiamos el valor de la variable LOG en el archivo de configuración
    sed "s/LOG=$LINEALOGS/LOG=$rutaLogs/g" "$CONFIG_FILE" > tmpfile && mv tmpfile "$CONFIG_FILE"
    # Eliminamos los \ de la ruta para que se muestre correctamente
    rutaLogs=$(echo $rutaLogs | sed 's/\\\//\//g')
    LINEALOGS=$rutaLogs
}

configurarEstrategias(){

    # Funcion para cambiar la estrategia de los jugadores en CONFIG_FILE

    # Variables
    estrategia=""
    estrategiaValida=""

    # Pedimos la estrategia de los jugadores
    read -p "Introduzca la estrategia de los jugadores (0-2): " estrategia

    # Comprobamos que la estrategia sea válida
    if [ $estrategia -lt 0 ] || [ $estrategia -gt 2 ]
    then
        echo "La estrategia no es válida"
        configurarEstrategias
    fi

    # Cambiamos el valor de la variable ESTRATEGIA en el archivo de configuración
    sed "s/ESTRATEGIA=$LINEAESTRATEGIAS/ESTRATEGIA=$estrategia/g" "$CONFIG_FILE" > tmpfile && mv tmpfile "$CONFIG_FILE"
    LINEAESTRATEGIAS=$estrategia

}

opcionConfiguracion(){

    # Mostrar por pantalla un menú en el que se presente qué parámetros se pueden configurar

    opcion=""

    while true;
    do
        clear
        echo "A)CONFIGURAR JUGADORES"
        echo "B)CONFIGURAR ESTRATEGIAS"
        echo "C)CONFIGURAR LOGS"
        echo "S)SALIR"
        echo "“5illo”. Introduzca una opción >>"
        read opcion
        case $opcion in
            A|a)
                echo "CONFIGURAR JUGADORES"
                configurarJugadores
                ;;
            B|b)
                echo "CONFIGURAR ESTRATEGIAS"
                configurarEstrategias
                ;;
            C|c)
                echo "CONFIGURAR LOGS"
                configurarLogs
                ;;
            S|s)
                echo "SALIR"
                main
                ;;
            *)
                echo "Opcion incorrecta"
                ;;
        esac
        read -p "Pulse INTRO para continuar..."
    done




}

#############################  de la forma {Cartas de oros} = "1 Oros|2 Oros|3 Oros|4 Oros|"
#                           #   Para i elementos en MESA: MESA[Oros] = {Cartas de oros},
#      FUNCIONES JUGAR      #                             MESA[Copas] = {Cartas de copas}, 
#                           #                             MESA[Espadas] = {Cartas de espadas}, 
#############################                             MESA[Bastos] = {Cartas de bastos}

jugarPrincipal(){   

    crearBaraja
    repartirCartasJugadores
    mostrarJugadores
    bucleJugar

}

bucleJugar(){

    # Función que contiene el bucle de la lógica de juego

    # Variables
    HA_GANADO=0
    JUGADOR_INICIO=0

    colocarCincoOrosInicio
    JUGADOR_INICIO=$?    
    
    CARTA_PRUEBA="4 Oros"
    sePuedeColocar $CARTA_PRUEBA
    echo $?

    return 0

    while [ $HA_GANADO -eq 0 ]; do
        for ((i = JUGADOR_INICIO; i < LINEAJUGADORES && HA_GANADO -eq 0 ; i++)); do 

            # Si le toca al jugador iterativo (que es el 0), llama a la funcion jugarIterativo

            case $LINEAESTRATEGIAS in
                0)
                    estrategia0 i
                    HA_GANADO=$?
                    ;;
                1)
                    estrategia1 i
                    HA_GANADO=$?
                    ;;
                2)
                    estrategia2 i
                    HA_GANADO=$?
                    ;;
            esac
        done
    done

}

jugarIterativo(){

    # Función que contiene la lógica de juego del jugador iterativo

    CARTAS_JUGADOR=${JUGADOR[0]} # Obtenemos las cartas del Jugador
    CARTAS_PALO_ARRAY=()
        IFS='|' read -r -a CARTAS_PALO_ARRAY <<< "$CARTAS_PALO"




}

mostrarMesa(){
    
        # Función que muestra la mesa por pantalla
    
        # Variables
        PALOS=("Copas" "Oros" "Espadas" "Bastos")
        CARTAS_PALO=()
    
        # Mostramos la mesa por pantalla
        for PALO in "${PALOS[@]}"; do
            echo "$PALO: ${MESA[PALO]}"
        done
}

colocarCincoOrosInicio(){

    #Función que hace que el jugador que tenga el 5 de oros empiece la partida, la función devuelve el ID del jugador que empieza

    # Variables
    JUGADOR_ID=0

    # Cadena a buscar
    CARTA_BUSCADA="5 Oros"

    # Bucle para buscar la carta en los mazos de los jugadores
    for ((i = 0; i < ${#JUGADORES[@]}; i++)); do
        if [[ ${JUGADORES[i]} == *$CARTA_BUSCADA* ]]; then
            JUGADOR_ID=$i
            break
        fi
    done

    # Eliminar la carta del jugador que empieza

    JUGADORES[JUGADOR_ID]=$(echo ${JUGADORES[JUGADOR_ID]} | sed "s/$CARTA_BUSCADA|//g")

    # Colocar la carta en la mesa

    colocarCarta $CARTA_BUSCADA
    eliminarCartaDeJugador $JUGADOR_ID $CARTA_BUSCADA


    # Devolver el ID del jugador que empieza
    # Hay que ver si somos el último jugador, en ese caso el jugador que empieza es el jugador 0

    if [ $JUGADOR_ID -eq $((LINEAJUGADORES-1)) ]; then
        JUGADOR_ID=0
    else
        JUGADOR_ID=$((JUGADOR_ID+1))
    fi

    return $JUGADOR_ID
    
}

colocarCarta(){
    
    # Funcion que coloca una carta en la mesa

    # Variables
    CARTA=$1
    PALO=$2
    NUMERO=$CARTA

    # Colocamos la carta en la MESA, hay que colocarla en orden y en su palo correspondiente
    # Comprobamos si hay cartas en el palo
    LENGTH=${#MESA[PALO]}
    if [ $LENGTH -eq 0 ]; then
        # Si no hay cartas en el palo, colocamos la carta en la primera posición
        MESA[PALO]="$CARTA $PALO|"
        mostrarMesa
    else
        # Si hay cartas en el palo, colocamos la carta en la posición correspondiente
        # Variables
        CARTAS_PALO=${MESA[PALO]} # Obtenemos las cartas del palo
        CARTAS_PALO_ARRAY=()
        IFS='|' read -r -a CARTAS_PALO_ARRAY <<< "$CARTAS_PALO"
        COLOCADA=0 # Variable que indica si la carta ha sido colocada
        POSICION=0 # Variable que indica la posición en la que se va a colocar la carta


        # Bucle para colocar la carta en la posición correspondiente
        for ((i = 0; i < ${#CARTAS_PALO_ARRAY[@]}; i++)); do
            # Obtenemos el número de la carta
            NUMERO_CARTA=${CARTAS_PALO_ARRAY[i]%% *}
            # Comprobamos si el número de la carta es mayor que el número de la carta que queremos colocar
            if [ $NUMERO_CARTA -gt "$NUMERO" ]; then
                # Si el número de la carta es mayor, colocamos la carta en la primera posición del array CARTAS_PALO_ARRAY
                CARTAS_PALO_ARRAY=("$CARTA $PALO" "${CARTAS_PALO_ARRAY[@]}")
                COLOCADA=1
                break
            fi
        done

        # Comprobamos si la carta ha sido colocada
        if [ $COLOCADA -eq 0 ]; then
            # Si la carta no ha sido colocada, la colocamos en la última posición
            CARTAS_PALO_ARRAY+=("$CARTA $PALO")
        fi

        # Pasamos el array CARTAS_PALO_ARRAY a un string de la forma "4 Oros|5 Oros|6 Oros|"
        MESA[PALO]=$(printf "%s|" "${CARTAS_PALO_ARRAY[@]}")

        mostrarMesa
        
    fi
}

eliminarCartaDeJugador(){

    # Función que elimina una carta del mazo de un jugador

    # Variables
    JUGADOR_ID=$1
    CARTA=$2

    # Eliminamos la carta del mazo del jugador
    JUGADORES[JUGADOR_ID]=$(echo ${JUGADORES[JUGADOR_ID]} | sed "s/$CARTA//g")
    mostrarJugadores

}

sePuedeColocar(){

    NUMERO=$1
    PALOENTRADA=$2


    # Comprobamos si el numero es 5

    if [ $NUMERO -eq 5 ]; then
        return 0
    fi

    HAYCARTA=${#MESA[PALOENTRADA]}
    if [ $HAYCARTA -eq 0 ]; then
        return 1
    else
        CARTAS_PALO_ARRAY=${MESA[PALOENTRADA]} # Obtenemos las cartas del palo
        CARTAS_PALO=()
        IFS='|' read -r -a CARTAS_PALO <<< "$CARTAS_PALO_ARRAY"

        # Hay que transformar el array CARTAS_PALO EN UN ARRAY DE NUMEROS, es decir, quitando a "5 Oros" el "Oros" y quedándonos con el 5

        for ((i = 0; i < ${#CARTAS_PALO[@]}; i++)); do
            # Obtenemos el número de la carta
            NUMERO_CARTA=${CARTAS_PALO[i]%% *}
            CARTAS_PALO[i]=$NUMERO_CARTA
        done


        #Creamos variable LENGTH para saber el número de elementos en CARTAS_PALO_ARRAY

        LENGTH=${#CARTAS_PALO[@]}

        if [ $NUMERO -gt 5 ]; then
            # If que comprueba si el numero es una unidad mayor que el numero de la última carta del palo
            
            if [ $NUMERO -eq $((${CARTAS_PALO[$((LENGTH-1))]} + 1)) ]; then
                return 0
            else
                return 1
            fi

        fi

        # If que comprueba si NUMERO es menor que 5, na mas

        if [ $NUMERO -lt 5 ]; then
            # If que comprueba si el numero es una unidad menor que el numero de la primera carta del palo
            if [ $NUMERO -eq $((CARTAS_PALO[0] - 1)) ]; then
                return 0
            else
                return 1
            fi

        fi

    fi

    echo "Función sePuedeColocar: Error inesperado"
    return -1

}

estrategia0(){

    # Función que contiene la estrategia 0, la aleatoria

    #Variables
    JUGADOR_ID=$1
    HA_GANADO=0
    CARTA_JUGADOR=${JUGADORES[JUGADOR_ID]}

    # Recorremos las cartas del jugador e intentamos colocarlas en la mesa
    
}

estrategia1(){

    # Función que contiene la estrategia 1

    #Variables
    JUGADOR_ID=$1
    HA_GANADO=0
    CARTA_JUGADOR=${JUGADORES[JUGADOR_ID]}

    
}

estrategia2(){

    # Función que contiene la estrategia 2

    #Variables
    JUGADOR_ID=$1
    HA_GANADO=0
    CARTA_JUGADOR=${JUGADORES[JUGADOR_ID]}

    
}

repartirCartasJugadores(){

    # Función que reparte las cartas a los JUGADORES

    JUGADORES=() 

    for ((i = 0; i < LINEAJUGADORES; i++)); do
        JUGADORES[i]="" # Inicializar el array de cada jugador
    done

    # Repartir las cartas a los JUGADORES
    CONTADOR=0

    for CARTA in "${BARAJA[@]}"; do
        JUGADOR_ID=$((CONTADOR % LINEAJUGADORES))
        JUGADORES[JUGADOR_ID]+="$CARTA|"
        ((CONTADOR++))
    done


}

mostrarJugadores(){
    
    # Función que muestra los jugadores por pantalla

    for ((i = 0; i < LINEAJUGADORES; i++)); do
        echo "Jugador $((i+1)): ${JUGADORES[i]}"
    done
}

crearBaraja(){

    # Función que crea la baraja

    BARAJA=()

    # Definir los PALOS y las cartas
    PALOS=("Copas" "Oros" "Espadas" "Bastos")
    CARTAS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")    

    # Llenar la BARAJA con las CARTAS   
    for PALO in "${PALOS[@]}"; do
        for CARTA in "${CARTAS[@]}"; do
            BARAJA+=("$CARTA $PALO")
        done
    done

    # Barajar la BARAJA

    # Variables
    NUMERO_CARTAS=${#BARAJA[@]}
    CARTA_TEMPORAL=""

    # Barajamos la baraja
    for (( i=0; i<$NUMERO_CARTAS; i++ )); do
        # Generamos un número aleatorio entre 0 y el número de cartas
        NUMERO_ALEATORIO=$(( $RANDOM % $NUMERO_CARTAS ))
        # Guardamos la carta en una variable temporal
        CARTA_TEMPORAL=${BARAJA[$NUMERO_ALEATORIO]}
        # Intercambiamos la carta aleatoria con la carta actual
        BARAJA[$NUMERO_ALEATORIO]=${BARAJA[$i]}
        BARAJA[$i]=$CARTA_TEMPORAL
    done

}

#############################
#                           #
#            MAIN           #
#                           #
#############################


main() {

    # Comprobamos que el fichero de configuración sea válido
    compruebaConfig

    # Variables
    opcion=""

    # Menú principal
    while true;
    do
        clear
        echo "C)CONFIGURACION"
        echo "J)JUGAR"
        echo "E)ESTADISTICAS"
        echo "F)CLASIFICACION"
        echo "S)SALIR"
        echo "“5illo”. Introduzca una opción >>"
        read opcion
        case $opcion in
            C|c)
                echo "CONFIGURACION"
                opcionConfiguracion
                ;;
            J|j)
                echo "JUGAR"
                jugarPrincipal
                ;;
            E|e)
                echo "ESTADISTICAS"
                ;;
            F|f)
                echo "CLASIFICACION"
                ;;
            S|s)
                echo "SALIR"
                exit 0
                ;;
            *)
                echo "Opcion incorrecta"
                ;;
        esac
        read -p "Pulse INTRO para continuar..."
    done
}

#############################
#                           #
#           INIT            #
#                           #
#############################

if [ ! -z $2 ]
then
    echo "No se admiten más de un parámetro"
    exit 1
fi
if [ -z $1 ]
then
    main
elif [ $1 = -g ] 
then
    echo "El primer parámetro es -g"
elif [ $1 != -g ]
then
    echo "El primer parámetro es inválido"
fi