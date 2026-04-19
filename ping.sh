#!/bin/bash
ip_completa=$(ip route | cut -d " " -f 3 | head -n 1)
red="${ip_completa%.*}"
activos=()

for i in $(seq 1 254); do
    ip="$red.$i"
    if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
        echo "Dispositivo encontrado: $ip"
        activos+=("$ip")
    fi
done

echo "Total de dispositivos activos: ${#activos[@]}"
for ip_activa in "${activos[@]}"; do
    echo " $ip_activa"
done
