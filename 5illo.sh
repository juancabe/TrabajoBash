#!/bin/bash

compruebaConfig() {

    # Variables
    LINEAJUGADORES=$(grep "JUGADORES=" | cut -d "=" -f 2 ./config.cfg)
    LINEAESTRATEGIAS=$(grep "ESTRATEGIAS=" | cut -d "=" -f 2 ./config.cfg)
    LINEALOGS=$(grep "LOG=" | cut -d "=" -f 2 ./config.cfg)

    if [ ! -f "./config.cfg" ]
    then
        echo "No existe el fichero de configuración"
        exit 1
    fi

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

main() {

    # Comprobamos que el fichero de configuración sea válido
    compruebaConfig;

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
                ;;
            J|j)
                echo "JUGAR"
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

main()