#!/bin/bash
opciones=" Crear_Usuario Agregar_usuario_a_grupo Cambiar_password_de_usuario Borrar_usuario Salir "
ayuda () {
	echo "AYUDA PARA SCRIPT:"
	echo "Uso de script: ./menuusuario.sh"
	echo "Selecciona una opcion correctar"
	echo "1: para crear usuario, 2:agregar usuario a un grupo"
	echo "3: Cambiar password de un usuario, 4:Borrar un usuario, 5: salir"
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
crear_usuario () {
	pedir_usuario
	echo "Ingresa la shell del usuario tipo: /bin/bash"
	read shell_usu
	sudo useradd -m -s "$shell_usu" "$nom_usuario"
	echo "Usuario creado, ahora configura su contraseña "
	password
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
	elif [ "$seleccion" == "Borrar_usuario" ]; then
		borrar_usuario
	elif [ "$seleccion" == "Salir" ]; then
		salir
	else
		echo "Opcion no valida, enter para ver de nuevo las opciones"
	fi
done
