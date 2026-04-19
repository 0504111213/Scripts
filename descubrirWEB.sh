#!/bin/bash
if test "$#" -ne 2; then
    echo "Se necesitan dos parametros" >&2
    echo "Uso: ./descubrirWEB.sh <URL_BASE> <ARCHIVO_DICCIONARIO>" >&2
    echo "Ejemplo: ./descubrirWEB.sh http://uv.com  diccionario.txt" >&2
    exit 1
fi

url_base="$1"
diccionario="$2"

if ! test -f "$diccionario"; then
    echo "Error: El archivo de diccionario '$diccionario' no existe." >&2
    exit 1
fi

while read -r recurso; do
    
    if test -z "$recurso"; then
        continue
    fi

    codigo=$(curl -s -o /dev/null -w "%{http_code}" "$url_base/$recurso")

    if test "$codigo" -eq 200; then
        echo "Encontrado  (200): $url_base/$recurso"
    elif test "$codigo" -eq 403; then
        echo "Prohibido   (403): $url_base/$recurso"
    elif test "$codigo" -eq 301; then
        echo "Redireccion (301): $url_base/$recurso"
    elif test "$codigo" -eq 302; then
        echo "Redireccion (302): $url_base/$recurso"
    elif test "$codigo" -eq 404; then
        echo "No existe   (404): $url_base/$recurso"
    else
        echo "Es desconocido ($codigo): $url_base/$recurso"
    fi

done < "$diccionario"

echo "Escaneo finalizado."
