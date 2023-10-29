#!/bin/bash

MESA="1 Copas|5 Copas|3 Copas|4 Copas|5 Copas|6 Copas"

if [[ "$MESA" == *"2 Copas"* ]]; then
    echo "Encontrado"
else
    echo "No encontrado"
fi

