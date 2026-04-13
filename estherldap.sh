#!/bin/bash

# Variables de configuración
DOMINIO="dc=esther2026,dc=ldap"
ADMIN="cn=admin,$DOMINIO"

echo "Menú LDAP:"
echo "1. Eliminar correo de un usuario"
echo "2. Modificar el correo de un usuario"
echo "3. Realizar búsquedas (Listado)"
echo "0. Salir"

read -p "Seleccione opción [0-3]: " OPCION

case $OPCION in

    1) 
        echo "1. Eliminar correo de un usuario"
        read -p "UID del usuario:" USER
        echo -e "dn: uid=$USER,ou=Alumnado,$DOMINIO\nchangetype: modify\ndelete: mail" > mod.ldif
        ldapmodify -x -D "$ADMIN" -W -f mod.ldif
        rm mod.ldif
        ;;

    2)
        echo "2. Modificar el correo de un usuario"
        read -p "UID del usuario: " USER
        read -p "Nuevo correo: " MAIL
        echo -e "dn: uid=$USER,ou=Alumnado,$DOMINIO\nchangetype: modify\nreplace: mail\nmail: $MAIL" > mod.ldif
        ldapmodify -x -D "$ADMIN" -W -f mod.ldif
        rm mod.ldif
        ;;

    3)
        echo "3. Realizar búsquedas: "
        echo "  a. Consultar un usuario concreto. "
        echo "  b. Listar todos (solo nombre y correo). "
        read -p "Seleccione subopción [a/b]: " SUB
        
        if [ "$SUB" = "a" ]; then
            read -p "Introduzca el UID del usuario: " USER
            ldapsearch -x -LLL -b "$DOMINIO" "(uid=$USER)"
        elif [ "$SUB" = "b" ]; then
            echo "Listado de Usuarios: "
            # Filtramos para que solo muestre los valores después del ":"
            ldapsearch -x -LLL -b "$DOMINIO" "(objectClass=inetOrgPerson)" cn mail | grep -E "^(cn|mail):"
        else
            echo "Subopción no válida. "
        fi
        ;;

    0)
        echo "0. Salir "
        echo "Hasta pronto."
        exit 0
        ;;

    *)
        echo "Opción no válida. "
        exit 1
        ;;
esac
