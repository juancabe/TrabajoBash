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


    # Seteamos todas las variables y arrays a 0
    BARAJA=()
    JUGADORES=()
    MESA=()
    MESA[Copas]=""
    MESA[Oros]=""
    MESA[Espadas]=""
    MESA[Bastos]=""

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
     


    while [ $HA_GANADO -eq 0 ]; do
        for ((k = $JUGADOR_INICIO; k < $LINEAJUGADORES; k++)); do 
            JUGADOR_INICIO=0
            echo "Jugador $((k+1))"
            # Si le toca al jugador iterativo (que es el 0), llama a la funcion jugarIterativo

            if [ $k -eq 0 ]; then
                jugarIterativo
            else
                case $LINEAESTRATEGIAS in
                    0)
                        estrategia0 $k
                        ;;
                    1)
                        estrategia1 $k
                        ;;
                    2)
                        estrategia2 $k
                        ;;
                esac
            fi

            haGanado $k
            HA_GANADO=$?
            if [ $HA_GANADO -eq 1 ]; then
                break
            fi

        done
    done

}

jugarIterativo(){

    # Función que contiene la lógica de juego del jugador iterativo

    CARTAS_JUGADOR=${JUGADORES[0]} # Obtenemos las cartas del Jugador
    CARTAS_JUGADOR_ARRAY=()
    IFS='|' read -r -a CARTAS_JUGADOR_ARRAY <<< "$CARTAS_JUGADOR"
    BIENCOLOCADA=0 # Variable que indica si la carta ha sido colocada
    PUEDEJUGAR=0

    # Comprobamos si el jugador puede jugar
    puedeJugar 0
    PUEDEJUGAR=$?
    if [ $PUEDEJUGAR -eq 1 ]; then
        # Si el jugador no puede jugar, pasamos al siguiente jugador
        echo "El jugador 1 no puede jugar"
        return 0
    fi


    # Bucle que imprime las cartas del jugador y pide la carta que se quiere colocar

    while [ $BIENCOLOCADA -eq 0 ]; do
        # Bucle for para mostrar todas las cartas del jugador

        for ((i = 0; i < ${#CARTAS_JUGADOR_ARRAY[@]}; i++)); do
            echo "$i) ${CARTAS_JUGADOR_ARRAY[i]}"
        done

        # Pedimos la carta que queremos colocar

        read -p "Introduzca el número de la carta que quiere colocar: " CARTA

        # Verificar si lo introducido es un número usando una expresión regular
        if ! [[ $CARTA =~ ^[0-9]{1,2}$ ]]; then
            echo "La carta no es válida"
            continue
        fi


        # Comprobamos que la carta sea válida

        if [ $CARTA -lt 0 ] || [ $CARTA -gt ${#CARTAS_JUGADOR_ARRAY[@]} ]; then
            echo "La carta no es válida"
            continue
        else
            sePuedeColocar ${CARTAS_JUGADOR_ARRAY[CARTA]%% *} ${CARTAS_JUGADOR_ARRAY[CARTA]##* }
            if [ $? -eq 0 ]; then
                # Si se puede colocar, colocamos la carta en la mesa
                colocarCarta ${CARTAS_JUGADOR_ARRAY[CARTA]} ${CARTAS_JUGADOR_ARRAY[CARTA]##* }

                BIENCOLOCADA=1
            else
                echo "La carta no se puede colocar"
                continue
            fi
        fi

    done
}

haGanado() {
    
        # Función que comprueba si un jugador ha ganado
    
        # Variables
        JUGADOR_ID_haGanado=$1
        CARTAS_JUGADOR=${JUGADORES[JUGADOR_ID_haGanado]} # Obtenemos las cartas del Jugador
        CARTAS_JUGADOR_ARRAY=()
        IFS='|' read -r -a CARTAS_JUGADOR_ARRAY <<< "$CARTAS_JUGADOR"
    
        if [ ${#CARTAS_JUGADOR_ARRAY[@]} -eq 0 ]; then
            return 1
        else
            return 0
        fi
}

mostrarMesa(){
    
        # Función que muestra la mesa por pantalla
    
        # Variables
        PALOSs=("Copas" "Oros" "Espadas" "Bastos")
    
        # Mostramos la mesa por pantalla
        for PALOh in "${PALOSs[@]}"; do
            echo "$PALOh: ${MESA[PALOh]}"
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
    CARTAa=$1
    PALOoo=$2

    # Colocamos la cartaa en la MESA, hay que colocarla en orden y en su palooo correspondiente
    # Comprobamos si hay cartaas en el palooo
    LENGTH=${#MESA[PALOoo]}
    if [ $LENGTH -eq 0 ]; then
        # Si no hay cartaas en el palooo, colocamos la cartaa en la primera posición
        MESA[PALOoo]="$CARTAa $PALOoo|"
            
        mostrarMesa

    else
        # Si hay cartaas en el palooo, colocamos la cartaa en la posición correspondiente
        # Variables
        CARTAaS_PALOoo=${MESA[PALOoo]} # Obtenemos las cartaas del palooo
        CARTAaS_PALOoo_ARRAY=()
        IFS='|' read -r -a CARTAaS_PALOoo_ARRAY <<< "$CARTAaS_PALOoo"
        COLOCADA=0 # Variable que indica si la cartaa ha sido colocada
        POSICION=0 # Variable que indica la posición en la que se va a colocar la cartaa


        # Bucle para colocar la cartaa en la posición correspondiente
        for ((i = 0; i < ${#CARTAaS_PALOoo_ARRAY[@]}; i++)); do
            # Obtenemos el número de la cartaa
            NUMERO_CARTAa=${CARTAaS_PALOoo_ARRAY[i]%% *}
            # Comprobamos si el número de la cartaa es mayor que el número de la cartaa que queremos colocar
            if [ $NUMERO_CARTAa -gt "$CARTAa" ]; then
                # Si el número de la cartaa es mayor, colocamos la cartaa en la primera posición del array CARTAaS_PALOoo_ARRAY
                CARTAaS_PALOoo_ARRAY=("$CARTAa $PALOoo" "${CARTAaS_PALOoo_ARRAY[@]}")
                COLOCADA=1
                break
            fi
        done


        # Comprobamos si la cartaa ha sido colocada
        if [ $COLOCADA -eq 0 ]; then
            # Si la cartaa no ha sido colocada, la colocamos en la última posición
            CARTAaS_PALOoo_ARRAY+=("$CARTAa $PALOoo")
        fi

        # Pasamos el array CARTAaS_PALOoo_ARRAY a un string de la forma "4 Oros|5 Oros|6 Oros|"
        MESA[PALOoo]=$(printf "%s|" "${CARTAaS_PALOoo_ARRAY[@]}")

        mostrarMesa
        
    fi

    eliminarCartaDeJugador $CARTAa $PALOoo

    
}

eliminarCartaDeJugador(){

    # Función que elimina una carta del mazo de un jugador

    # Variables
    NUMEROeliminar=$1
    PALOpaloeliminar=$2


    # Eliminamos la carta del mazo del jugador
    for ((i = 0; i < ${#JUGADORES[@]}; i++)); do
        if [[ ${JUGADORES[i]} == *"$NUMEROeliminar $PALOpaloeliminar"* ]]; then
            JUGADORES[i]=$(echo ${JUGADORES[i]} | sed "s/$NUMEROeliminar $PALOpaloeliminar|//g")
            break
        fi
    done

    mostrarJugadores

}

sePuedeColocar(){

    NUMEROo=$1
    PALOENTRADAa=$2


    # Comprobamos si el numeroo es 5

    if [ $NUMEROo -eq 5 ]; then
        return 0
    fi

    HAYCARTA=${#MESA[PALOENTRADAa]}
    if [ $HAYCARTA -eq 0 ]; then
        return 1
    else
        CARTAS_PALO_ARRAY=${MESA[PALOENTRADAa]} # Obtenemos las cartas del palo
        CARTAS_PALO=()
        IFS='|' read -r -a CARTAS_PALO <<< "$CARTAS_PALO_ARRAY"

        # Hay que transformar el array CARTAS_PALO EN UN ARRAY DE NUMEROoS, es decir, quitando a "5 Oros" el "Oros" y quedándonos con el 5

        for ((i = 0; i < ${#CARTAS_PALO[@]}; i++)); do
            # Obtenemos el número de la carta
            NUMEROo_CARTA=${CARTAS_PALO[i]%% *}
            CARTAS_PALO[i]=$NUMEROo_CARTA
        done


        #Creamos variable LENGTH para saber el número de elementos en CARTAS_PALO_ARRAY

        LENGTH=${#CARTAS_PALO[@]}

        if [ $NUMEROo -gt 5 ]; then
            # If que comprueba si el numeroo es una unidad mayor que el numeroo de la última carta del palo
            
            if [ $NUMEROo -eq $((${CARTAS_PALO[$((LENGTH-1))]} + 1)) ]; then
                return 0
            else
                return 1
            fi

        fi

        if [ $NUMEROo -lt 5 ]; then
            # If que comprueba si el numero es una unidad menor que el numero de la primera carta del palo
            if [ $NUMEROo -eq $((CARTAS_PALO[0] - 1)) ]; then
                return 0
            else
                return 1
            fi

        fi

    fi

    echo "Función sePuedeColocar: Error inesperado"
    return -1

}

puedeJugar(){

    # Función que comprueba si un jugador puede jugar

    # Variables
    JUGADOR_ID=$1
    CARTAS_JUGADOR=${JUGADORES[JUGADOR_ID]}
    CARTAS_JUGADOR_ARRAY=()
    IFS='|' read -r -a CARTAS_JUGADOR_ARRAY <<< "$CARTAS_JUGADOR"

    # Bucle para comprobar si el jugador puede jugar
    for ((y = 0; y < ${#CARTAS_JUGADOR_ARRAY[@]}; y++)); do
        # Obtenemos el número de la carta
        NUMERO_CARTA=${CARTAS_JUGADOR_ARRAY[y]%% *}
        # Obtenemos el palo de la carta
        PALO_CARTA=${CARTAS_JUGADOR_ARRAY[y]##* }
        # Comprobamos si se puede colocar la carta
        sePuedeColocar $NUMERO_CARTA $PALO_CARTA
        if [ $? -eq 0 ]; then
            return 0
        fi
    done

    return 1

}

estrategia0(){

    # Función que contiene la estrategia 0, la aleatoria

    #Variables
    JUGADOR_ID_A=$1
    CARTAS_JUGADOR_est0=${JUGADORES[$JUGADOR_ID_A]}
    CARTAS_JUGADOR_est0_ARRAY=()
    IFS='|' read -r -a CARTAS_JUGADOR_est0_ARRAY <<< "$CARTAS_JUGADOR_est0"

    # Comprobamos si el jugador puede jugar
    puedeJugar $JUGADOR_ID_A
    PUEDEJUGAR=$?
    if [ $PUEDEJUGAR -eq 1 ]; then
        # Si el jugador no puede jugar, pasamos al siguiente jugador
        echo "El jugador $((JUGADOR_ID_A+1)) no puede jugar"
        return 0
    fi

    # Recorremos las cartas del jugador e intentamos colocarlas en la mesa

    for ((l = 0; l < ${#CARTAS_JUGADOR_est0_ARRAY[@]}; l++)); do
        # Obtenemos el número de la carta
        NUMERO_CARTA_est0=${CARTAS_JUGADOR_est0_ARRAY[l]%% *}
        # Obtenemos el palo de la carta
        PALO_CARTA_est0=${CARTAS_JUGADOR_est0_ARRAY[l]##* }
        # Comprobamos si se puede colocar la carta
        sePuedeColocar $NUMERO_CARTA_est0 $PALO_CARTA_est0
        if [ $? -eq 0 ]; then
            # Si se puede colocar, colocamos la carta en la mesa
            colocarCarta $NUMERO_CARTA_est0 $PALO_CARTA_est0
            break
        fi
    done
}

estrategia1(){

    # Función que contiene la estrategia 1
    # En esta estrategia priorizamos colocar cartas de las cuales tenemos la siguiente, 
    # así aseguramos que no facilitamos a los demás colocar.

    #Variables
    JUGADOR_ID_B=$1
    CARTAS_JUGADOR_est1=${JUGADORES[$JUGADOR_ID_B]}
    CARTAS_JUGADOR_est1_ARRAY=()
    IFS='|' read -r -a CARTAS_JUGADOR_est1_ARRAY <<< "$CARTAS_JUGADOR_est1"
    
    # Comprobamos si el jugador puede jugar
    puedeJugar $JUGADOR_ID_B
    PUEDEJUGAR=$?
    if [ $PUEDEJUGAR -eq 1 ]; then
        # Si el jugador no puede jugar, pasamos al siguiente jugador
        echo "El jugador $((JUGADOR_ID_B+1)) no puede jugar"
        return 0
    fi

    # Bucle en el cual buscamos cartas de las cuales tenemos la siguiente, excepto los cincos
    
    for ((ii = 0; ii < ${#CARTAS_JUGADOR_est1_ARRAY[@]}; ii++)); do
        # Obtenemos el número de la carta
        NUMERO_CARTA_est1=${CARTAS_JUGADOR_est1_ARRAY[ii]%% *}

        # Comprobamos si el número de la carta es 5, si es 5, pasamos a la siguiente carta
        if [ $NUMERO_CARTA_est1 -eq 5 ]; then
            continue
        fi

        # Obtenemos el palo de la carta
        PALO_CARTA_est1=${CARTAS_JUGADOR_est1_ARRAY[ii]##* }
        # Comprobamos si se puede colocar la carta
        sePuedeColocar $NUMERO_CARTA_est1 $PALO_CARTA_est1
        if [ $? -eq 0 ]; then
            # Si se puede colocar, buscamos a ver si tenemos la siguiente carta

            # Si la carta es mayor que 5, buscamos la carta posterior
            if [ $NUMERO_CARTA_est1 -gt 5 ]; then

                if [[ "$CARTAS_JUGADOR_est1" == *"$((NUMERO_CARTA_est1+1)) $PALO_CARTA_est1"* ]]; then
                    # Si tenemos la siguiente carta, la colocamos
                    colocarCarta $NUMERO_CARTA_est1 $PALO_CARTA_est1
                    break
                fi

            fi

            # Si la carta es menor que 5, buscamos la carta anterior
            if [ $NUMERO_CARTA_est1 -lt 5 ]; then

                if [[ "$CARTAS_JUGADOR_est1" == *"$((NUMERO_CARTA_est1-1)) $PALO_CARTA_est1"* ]]; then
                    # Si tenemos la siguiente carta, la colocamos
                    colocarCarta $NUMERO_CARTA_est1 $PALO_CARTA_est1
                    break
                fi

            fi            
        fi
    done

    # Si no hemos podido colocar ninguna carta, colocamos una carta aleatoria

    if [ $ii -eq ${#CARTAS_JUGADOR_est1_ARRAY[@]} ]; then
        estrategia0 $JUGADOR_ID_B
        return $?
    fi
}

estrategia2(){

    # Función que contiene la estrategia 2
    # En esta estrategia priorizamos colocar un rey o un uno,
    # si esto no es posible, miramos a ver si tenemos un 5 y de
    # ese palo cartas cercanas al límite (sota, caballo, rey o uno, dos)
    # y no las intermedias (tres, cuatro, seis y siete)
    # si es así, colocamos el 5, ya que vamos a necesitar que los demás
    # coloquen cartas intermedias para poder colocar las nuestras
    # si tenemos esas cartas intermedias, no colocamos el 5
    # En caso de no tener un 5, colocamos una carta aleatoria
    # así aseguramos que no facilitamos a los demás colocar.

    #Variables
    JUGADOR_ID_C=$1
    CARTAS_JUGADOR_est2=${JUGADORES[$JUGADOR_ID_C]}
    CARTAS_JUGADOR_est2_ARRAY=()
    IFS='|' read -r -a CARTAS_JUGADOR_est2_ARRAY <<< "$CARTAS_JUGADOR_est2"
    
    # Comprobamos si el jugador puede jugar
    puedeJugar $JUGADOR_ID_C
    PUEDEJUGAR=$?
    if [ $PUEDEJUGAR -eq 1 ]; then
        # Si el jugador no puede jugar, pasamos al siguiente jugador
        echo "El jugador $((JUGADOR_ID_C+1)) no puede jugar"
        return 0
    fi

    for ((e=0 ; e < ${#CARTAS_JUGADOR_est2_ARRAY[@]} ; e++)); do
        # Obtenemos el número y palo de la carta
        NUMERO_CARTA_e=${CARTAS_JUGADOR_est2_ARRAY[e]%% *}
        PALO_CARTA_e=${CARTAS_JUGADOR_est2_ARRAY[e]##* }
        
        # Miramos a ver si tenemos un rey o un uno
        if [ $NUMERO_CARTA_e -eq 10 ]; then
            sePuedeColocar $NUMERO_CARTA_e $PALO_CARTA_e
            if [ $? -eq 0 ]; then
                colocarCarta $NUMERO_CARTA_e $PALO_CARTA_e
                break
            fi
        else if [ $NUMERO_CARTA_e -eq 1 ]; then
            sePuedeColocar $NUMERO_CARTA_e $PALO_CARTA_e
            if [ $? -eq 0 ]; then
                colocarCarta $NUMERO_CARTA_e $PALO_CARTA_e
                break
            fi
        fi
        fi
    done

    for ((e=0 ; e < ${#CARTAS_JUGADOR_est2_ARRAY[@]} ; e++)); do
        # Obtenemos el número y palo de la carta
        NUMERO_CARTA_e=${CARTAS_JUGADOR_est2_ARRAY[e]%% *}
        PALO_CARTA_e=${CARTAS_JUGADOR_est2_ARRAY[e]##* }

        # Miramos a ver si tenemos un 5
        if [ $NUMERO_CARTA_e -eq 5 ]; then
            # Si tenemos un 5, miramos a ver si tenemos cartas cercanas
            # al límite de ese palo y no las intermedias. Si es así, colocamos el 5
            for ((carta = 0 ; carta < ${#CARTAS_JUGADOR_est2_ARRAY[@]} ; carta++)); do
                # Obtenemos el número y palo de la carta
                NUMERO_CARTA_c=${CARTAS_JUGADOR_est2_ARRAY[carta]%% *}
                PALO_CARTA_c=${CARTAS_JUGADOR_est2_ARRAY[carta]##* }

                # Comprobamos si el palo de la carta es el mismo que el del 5
                if [ $PALO_CARTA_c == $PALO_CARTA_e ]; then
                    # Si la carta es el mismo 5, pasamos a la siguiente carta
                    if [ $NUMERO_CARTA_c -eq $NUMERO_CARTA_e ]; then
                        continue
                    fi
                    case $NUMERO_CARTA_c in
                        9)
                            # Si tenemos un 9, comprobamos que no tenemos el 6, 7 y 8
                            # (Si tenemos solo una de las tres, colocamos el 5)
                            CARTAS_DISPONIBLES=0
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c-3)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c-2)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c-1)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi

                            if [ $CARTAS_DISPONIBLES -eq 1 ]; then
                                colocarCarta $NUMERO_CARTA_e $PALO_CARTA_e
                                return 0
                            else
                                continue
                            fi
                            ;;
                        8)
                            # Si tenemos un 8, comprobamos que no tenemos el 6 y 7
                            # (Si no tenemos ninguna de las dos, colocamos el 5)
                            CARTAS_DISPONIBLES=0
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c-2)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c-1)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi

                            if [ $CARTAS_DISPONIBLES -eq 0 ]; then
                                colocarCarta $NUMERO_CARTA_e $PALO_CARTA_e
                                return 0
                            else
                                continue
                            fi
                            ;;
                        2)
                            # Si tenemos un 2, comprobamos que no tenemos el 3 y 4
                            # (Si no tenemos ninguna de las dos, colocamos el 5)
                            CARTAS_DISPONIBLES=0
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c+1)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi
                            if [[ "$CARTAS_JUGADOR_est2" == *"$((NUMERO_CARTA_c+2)) $PALO_CARTA_c"* ]]; then
                                CARTAS_DISPONIBLES+=1;
                            fi

                            if [ $CARTAS_DISPONIBLES -eq 0 ]; then
                                colocarCarta $NUMERO_CARTA_e $PALO_CARTA_e
                                return 0
                            else
                                continue
                            fi
                            ;;
                    esac
                fi
            done
        fi
    done

    # Si no hemos podido colocar ninguna carta, colocamos una carta con la estrategia1
    estrategia1 $JUGADOR_ID_C
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