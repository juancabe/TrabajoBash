#!/bin/bash
CONFIG_FILE="./config.cfg"
LINEAJUGADORES=""
LINEAESTRATEGIAS=""
LINEALOGS=""

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

    # Comprobamos que LINEAJUGADORES esté entre 1 y 4, LINEAESTRATEGIAS entre 0 y 2 y LINEALOGS sea una ruta relativa a un archivo valida
    if [ $LINEAJUGADORES -lt 1 ] || [ $LINEAJUGADORES -gt 4 ]
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
    read -p "Introduzca el número de jugadores (1-4): " jugadores

    # Comprobamos que el número de jugadores sea válido
    if [ $jugadores -lt 1 ] || [ $jugadores -gt 4 ]
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

#############################
#                           #
#      FUNCIONES JUGAR      #
#                           #
#############################

jugarPrincipal(){

    

    echo "Jugar Principal"


}

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