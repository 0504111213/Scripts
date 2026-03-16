#! /bin/bash
opciones="Mostrar_Interfaces Cambiar_Estado Establecer_Cableada Establecer_Wi-Fi Salir"
ayuda () {
	echo "USO DE SCRIPT ./internet.sh"
	echo "Este script sirve para realizar una conexion de internet de las diferentes formas (Ethernet o Wi-Fi)"
	echo "Se debe seleccionar una opcion valida mediante el numero indicado dependiendo lo que se desee realizar"
	echo "En cada opcion para escribir se pone un ejemplo para poder saber como se debe escribir correctamente para que no existan errores"
	echo "NOTA: Se recomienda ejecutar el script como super usuario para que no exista conflicto con los comandos."
}
interfaces="/etc/network/interfaces"
mostrar_interfaces(){
	echo "Las interfaces de red son: "
	ip -br link show
}
cambiar_estado () {
	mostrar_interfaces
	echo "Ingresa la interfaz que deseas cambiar: "
	read interfaz
	echo "Ingresa 'up' para encenderla o 'down' para apagarla: "
	read estado
	sudo ip link set "$interfaz" "$estado"
	echo "Interfaz $interfaz esta en estado $estado"
}
conf_ip () {
	local interfaz=$1
	echo "Quieres hacer configuracion dinamica (DHCP) o estatica"
	read tipo_conf
	if [ "$tipo_conf" == "estatica" ]; then
		echo "Ingresa la ip con mascara ejemplo (192.168.1.2/24): "
		read ip_mask
		echo "Ingresa el gateway: "
		read gateway
		echo "Ingresa servidor DNS ejemplo (8.8.8.8): "
		read dns
		sudo ip addr flush dev "$interfaz"
		sudo ip addr add "ip_mask" dev "$interfaz"
		sudo ip route add default via "$gateway"
		echo "nameserver $dns" | sudo tee /etc/resolv.conf > /dev/null
		echo "¿Desea hacerlo de forma permante y/n?"
		read respuesta
			if [ "$respuesta" == "y" ]; then
				echo -e "\nauto $intf\niface $intf inet static\n\taddress $ip_mask\n\tgateway $gw" | sudo tee -a "$archivo_interfaces" > /dev/null
				echo " Configuracion estatica hecha de forma permanente y guardada en $archivos_interfaces "
			else
				echo " Configuracion estatica hecha de forma temporal "
			fi
	elif [ "$tipo_ip" == "dinamica" ]; then
		sudo killall dhclient 2>/dev/null
		sudo dhclient "$interfaz"
		echo "IP dinamica asignada "
		echo "¿Desea hacerlo de forma permante y/n?"
		read respuesta
			if [ "$respuesta" == "y" ]; then
			 echo -e "\nauto $intf\niface $intf inet dhcp" | sudo tee -a "$archivo_interfaces" > /dev/null
				echo " Configuracion dinamica hecha de forma permanente y guardada en $archivos_interfaces"
			else
					echo " Configuracion dinamica hecha de forma temporal "
			fi
	fi				
}
conectar_cableadea () {
	mostrar_interfaces
	echo "Ingresa cual es la interfaz cableada: "
	read intf
	sudo ip link set "$intf" up
	configurar_ip_manual "$intf"
}
conectar_inalambrica () {
	mostrar_interfaces
	echo "Ingresa cual es la intefaz de Wi-Fi (wlp0s0): "
	read intf
	sudo ip link set "$intf" up
	echo "Escanenando las redes....."
	show iw dev "$intf" scan | grep SSID
	echo "Escribe el nombre de la red "
	read ssid
	echo "Escribe la contraseña: "
	read pass
	sudo wpa_passphrase "$ssid" "$pass" | sudo tee /etc/wpa_supplicant/mi_red.conf > /dev/null
	sudo killall wpa_supplicant 2>/dev/null
	sudo wpa_supplicant -B -i "$intf" -c /etc/wpa_supplicant/mi_red.conf
	conf_ip "$intf"
}
salir (){
	echo "Saliendo del programa"
	exit
}
select seleccion in $opciones; do
    if [ "$seleccion" == "Mostrar_Interfaces" ]; then 
    mostrar_interfaces
    elif [ "$seleccion" == "Cambiar_Estado" ]; then 
    cambiar_estado
    elif [ "$seleccion" == "Establecer_Cableada" ]; then 
    conectar_cableada
    elif [ "$seleccion" == "Establecer_Wi-Fi" ]; then 
    conectar_inalambrica
    elif [ "$seleccion" == "Salir" ]; then 
    Salir
    fi
done
