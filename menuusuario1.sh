#!/bin/bash
opciones=" Crear_Usuario Agregar_usuario_a_grupo Cambiar_password_de_usuario Configurar_cuota Borrar_usuario Salir "
ayuda () {
	echo "AYUDA PARA SCRIPT:"
	echo "Uso de script: ./menuusuario.sh"
	echo "Selecciona una opcion correcta"
	echo "1: Crear usuario, 2: Agregar usuario a un grupo"
	echo "3: Cambiar password de un usuario, 4: Configurar cuota, 5: Borrar usuario, 6: Salir"
	echo "Nota: ejecutar script con sudo para cualquiera de las opciones"
}
password () {
	while true; do
	echo "Ingresa una contraseña para $nom_usuario: "
	echo "La contraseña debe de tener minimo 8 caracteres, 1 mayuscula, 1 minuscula, 1 numero y 1 caracter especial"
	read -s password
	echo "Confirme la contraseña "
	read -s password_confir
	if test "$password" != "$password_confir"; then
		echo "Las contraseñas no coinciden, intente de nuevo " >&2
		continue
	fi
	if test ${#password} -lt 8; then 
		echo "La contraseña debe de tener al menos 8 caracteres ">&2
		continue
	fi
	if test -z "$(echo "$password" | grep '[A-Z]')"; then
		echo "La contraseña debe de tener al menos una letra mayúscula." >&2
		continue
	fi
	if test -z "$(echo "$password" | grep '[a-z]')"; then
		echo "La contraseña debe de tener al menos una letra minúscula." >&2
		continue
	fi
	if test -z "$(echo "$password" | grep '[0-9]')"; then
		echo "La contraseña debe de tener al menos un número." >&2
		continue
	fi
	if test -z "$(echo "$password" | grep '[^a-zA-Z0-9]')"; then
		echo "Error: Debe incluir al menos un carácter especial." >&2
		continue
	fi
	echo "$nom_usuario:$password" | sudo chpasswd
	if test $? -eq 0; then
		echo "La contraseña es segura y a sido asignada correctamente"
		break
	else
		echo "Hubo un error al asignar la contraseña" >&2
		break
	fi
done
}

pedir_usuario () {
	echo "Ingresa nombre de usuario"
	read nom_usuario
	if ! test "$nom_usuario" ;then
		echo "Ingresa un nombre de usuario valido" >&2 
		ayuda
		exit 1
	fi
}
aplicar_cuota () {
	echo "Ingresa el límite SOFT en KB (1024000 para 1GB o 0 para sin limite): "
	read soft_limit
	echo "Ingresa el límite HARD en KB (2048000 para 2GB o 0 para sin limite): "
	read hard_limit
	echo "Ingresa la partición donde se aplicará la cuota (/ o /home): "
	read particion
	sudo setquota -u "$nom_usuario" "$soft_limit" "$hard_limit" 0 0 "$particion"
	if test $? -eq 0; then
		echo "Cuota asignada a $nom_usuario"
	else
		echo "No se pudo asignar cuota a $nom_usuario" >&2
	fi
	echo "¿Deseas cambiar el periodo de gracia en esta partición? (s/n)"
	read cambiar_gracia
	if test "$cambiar_gracia" == "s"; then
		echo "Ingresa el nuevo tiempo de gracia en SEGUNDOS (604800 para 7 dias): "
		read gracia_seg
		sudo setquota -t "$gracia_seg" "$gracia_seg" "$particion"
		if test $? -eq 0; then
			echo "Periodo de gracia actualizado en $particion."
		else
			echo "No se pudo actualizar el periodo de gracia." >&2
		fi
	fi
}
configurar_cuota_menu () {
	pedir_usuario
	aplicar_cuota
}
crear_usuario () {
	pedir_usuario
	echo "Ingresa la shell del usuario tipo: /bin/bash"
	read shell_usu
	sudo useradd -m -s "$shell_usu" "$nom_usuario"
	echo "Usuario creado, ahora configura su contraseña "
	password
	echo "¿Deseas asignarle una cuota de disco a este usuario? (s/n)"
	read resp_cuota
	if test "$resp_cuota" == "s"; then
		aplicar_cuota
	fi
}
agregar_usuario () {
	pedir_usuario
	echo "Ingresa nombre de grupo que deseas agregar a $nom_usuario"
	read grup
	sudo usermod -a -G "$grup" "$nom_usuario"
}
cambiar_password () {
	pedir_usuario
	password
}

borrar_usuario () {
	pedir_usuario
	sudo userdel -r "$nom_usuario"
}

salir () {
	echo "Saliendo del script"
	exit
}

select seleccion in $opciones; do
	if [ "$seleccion" == "Crear_Usuario" ]; then
		crear_usuario
	elif [ "$seleccion" == "Agregar_usuario_a_grupo" ]; then
		agregar_usuario
	elif [ "$seleccion" == "Cambiar_password_de_usuario" ]; then
		cambiar_password
	elif [ "$seleccion" == "Configurar_cuota" ]; then
		configurar_cuota_menu
	elif [ "$seleccion" == "Borrar_usuario" ]; then
		borrar_usuario
	elif [ "$seleccion" == "Salir" ]; then
		salir
	else
		echo "Opcion no valida, enter para ver de nuevo las opciones"
	fi
done
