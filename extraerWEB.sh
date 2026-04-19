#!/bin/bash

ayuda() {
    echo "USO: ./extraerWEB.sh <URL>"
    echo "EJEMPLO: ./extraerWEB.sh https://webnnnn.com"
}

if ! test "$1"; then
    echo "Se debe ingresar un URL" >&2
    ayuda
    exit 1
fi
url="$1"

url_segura=$(echo "$url" | tr '/:' '_')

salida="extraccion_De_${url_segura}.txt"
temp="codigo_temporal.html"

curl -s -L "$url" > "$temp"

if ! test $? -eq 0; then
    echo "No se pudo establecer conexión con la pagina" >&2
    rm -f "$temp"
    exit 1
fi

echo "Conexion exitosa"

echo "Copiando comentarios a: " >> "$salida"

grep -oP '' "$temp" >> "$salida"
if ! test $? -eq 0; then
    echo "No se encontro ningun comentario" >> "$salida"
fi

echo "" >> "$salida"

grep -E -o '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$temp" | sort | uniq >> "$salida"
if ! test $? -eq 0; then
    echo " No se encontro ningun correo electronico " >> "$salida"
fi

rm -f "$temp"

echo "Extracción completada en: $salida"
