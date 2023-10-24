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

echo "LLEGA"