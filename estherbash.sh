#!/bin/bash
# Creación de menú para scripts del 1-15
menu(){
  opcion=1
  while [ $opcion -ne 0 ]; do
  # Menú que se muestra por pantalla
    echo "********************************"
    echo "Opción 1: Bisiesto"
    echo "Opción 2: Configurar red"
    echo "Opción 3: Adivina"
    echo "Opción 4: Buscar"
    echo "Opción 5: Contar"
    echo "Opción 6: Permiso octal"
    echo "Opción 7: Romano"
    echo "Opción 8: Automatizar"
    echo "Opción 9: Crear"
    echo "Opción 10: Crear 2"
    echo "Opción 11: Reescribir"
    echo "Opción 12: Contusu"
    echo "Opción 13: Quita blancos"
    echo "Opción 14: Lineas"
    echo "Opción 15: Analizar"
    echo "Opción 0: Para salir"
    echo "********************************"
    read -p "Elegir la opción deseada: " opcion
    echo ""
    case $opcion in
      0)
      ;;
      1)
        read -p "Dame un año: " anyo
        let anyo=anyo-1
        if (( ( $anyo % 4 == 0  &&  $anyo % 100 != 0 ) || ( $anyo % 400 == 0 ) )); then 
          echo "$anyo es un año bisiesto"
        else
          echo "$anyo no es un año bisiesto"
        fi
        sleep 5
      ;;
      2)
        read -p "Dame la ip: " ip
        read -p "Dame la mascara: " masc
        read -p "Dame la puerta de enlace: " enlace
        read -p "Dame el dns: " dns
        cat > /etc/netplan/50-cloud-init.yaml <<EOF
        network:
          version: 2
          renderer: NetworkManager
          ethernets:
            enp0s3:
              addresses: [$ip/$masc]
              routes:
                - to: default
                  via: $enlace
              nameservers:
                addresses: [$dns]
EOF
        cat /etc/netplan/50-cloud-init.yaml
        sleep 5
      ;;
      3)
        aleatorio=$(( RANDOM % 101 ))
        max_intentos=5
        intentos=5
        total=1
        for ((i=1; i<=max_intentos;i++)); do
          echo "El número de intentos que tienes ahora es $intentos"
          read -p "Adivina el número: " numusu
          if [ $numusu -eq $aleatorio ]; then
            echo "Has acertado campeon, yeray te aprueba!!"
            break
          elif [ $numusu -lt $aleatorio ]; then
            echo "El número es mayor"
            let intentos=$intentos-1
            let total=$total+1
          else
            echo "El número es menor"
            let intentos=$intentos-1
            let total=$total+1
          fi
        done
          if [ $numusu -eq $aleatorio ]; then
            echo "El numero de intentos que has realizado es $total"
          else
            echo "Ya no te quedan intentos, el numero era el $aleatorio"
          fi
        sleep 5 
      ;;
      4)
        # Buscar
        # Este script te ayudará a buscar un fichero
        read -p "Dame el nombre de un fichero a buscar: " fichero
        buscar=$(sudo find / -name "$fichero")
          if [ -n "$buscar" ]; then
            vocales=$(grep -o -i '[aeiou]' $buscar | wc -l)
            echo "La ubicación es $buscar y tiene $vocales vocales"
          else
            echo "No se encontró el fichero"
          fi
      ;;
      5)
        # contar
        #!/bin/bash
        read -p "Introduce el directorio: " dir
        if [ -d "$dir" ]; then
          echo "Hay $(ls -l "$dir" | grep -c ^-) ficheros en $dir"
        else
          echo "El directorio no existe"
        fi
      ;;
      6)
        # permisosoctal
        # Dado un objeto (ruta absoluta existente), muestra sus permisos en octal (incluyendo especiales).       
        read -p "Introduce la ruta absoluta del archivo o directorio: " ruta  
        # Mostrar permisos en octal
        permisos=$(stat -c "%a" "$ruta")
        echo "Los permisos octales de $ruta son: $permisos"

      ;;
      7)
        # romano"
        # Solicita un número del 1 al 200 y muestra su representación en números romanos (I, V, X, L, C) 
        read -p "Introduce un número (1-200): " num
        if [ "$num" -lt 1 ] || [ "$num" -gt 200 ]; then
          echo "Error: el número debe estar entre 1 y 200."
          exit 1
        fi
        romano=""
        # Centenas (100–199)
        if [ $num -ge 100 ]; then
          centenas=$((num / 100))
          for ((i=1; i<=centenas; i++)); do
            romano="${romano}C"
          done
          num=$((num % 100))
        fi
        # Decenas (10–99)
        if [ $num -ge 90 ]; then
          romano="${romano}XC"; num=$((num-90))
        elif [ $num -ge 50 ]; then
          romano="${romano}L"
          decenas=$(((num-50)/10))
          for ((i=1; i<=decenas; i++)); do
            romano="${romano}X"
          done
          num=$((num % 10))
        elif [ $num -ge 40 ]; then
          romano="${romano}XL"; num=$((num-40))
        elif [ $num -ge 10 ]; then
          decenas=$((num/10))
          for ((i=1; i<=decenas; i++)); do
            romano="${romano}X"
          done
          num=$((num % 10))
        fi
        # Unidades (1–9)
        if [ $num -eq 9 ]; then
          romano="${romano}IX"
        elif [ $num -ge 5 ]; then
          romano="${romano}V"
          for ((i=6; i<=num; i++)); do
            romano="${romano}I"
          done
        elif [ $num -eq 4 ]; then
          romano="${romano}IV"
        elif [ $num -ge 1 ]; then
          for ((i=1; i<=num; i++)); do
            romano="${romano}I"
          done
        fi
        echo "En números romanos: $romano"

      ;;
      8)
        # automatizar
        DIR="/mnt/usuarios"
        shopt -s nullglob
        files=("$DIR"/*)
        if [ ${#files[@]} -eq 0 ]; then
          echo "listado vacío"
          exit 0
        fi
        for f in "${files[@]}"; do
          [ -f "$f" ] || continue
          user="$(basename -- "$f")"
          id -u "$user" >/dev/null 2>&1 || useradd -m "$user"
          home="$(getent passwd "$user" | cut -d: -f6)"
          [ -d "$home" ] || mkdir -p "$home"
          while IFS= read -r d; do
            [ -z "$d" ] && continue
            mkdir -p "$home/$d"
            chown -R "$user:$user" "$home/$d"
          done < "$f"
          rm -f -- "$f"
        done
      ;;
      9)
      # crear
      if [ $# -eq 0 ]; then
        nombre="fichero_vacio"
        tamano=1024
      elif [ $# -eq 1 ]; then
        nombre="$1"
        tamano=1024
      else
        nombre="$1"
        tamano="$2"
      fi      
      truncate -s "${tamano}K" "$nombre"
      echo "Creado el fichero $nombre con tamaño ${tamano}K"
      ;;
      10)
        # crear_2
        if [ $# -eq 0 ]; then
          nombre="fichero_vacio"
          tamano=1024
        elif [ $# -eq 1 ]; then
          nombre="$1"
          tamano=1024
        else
          nombre="$1"
          tamano="$2"
        fi
        
        # Comprobación si el fichero ya existe
        if [ -e "$nombre" ]; then
          echo "El fichero '$nombre' ya existe."
        
          contador=1
          encontrado=0
        
          while [ $contador -le 9 ]; do
            nuevo="${nombre}${contador}"
            if [ ! -e "$nuevo" ]; then
              nombre="$nuevo"
              echo "Se creará como '$nombre'."
              encontrado=1
              contador=10  # fuerza salida sin usar break
            else
              contador=$((contador+1))
            fi
          done
        
          if [ $encontrado -eq 0 ]; then
            echo "Ya existen versiones del 1 al 9. No se creará nada."
            creado=0
          else
            creado=1
          fi
        else
          creado=1
        fi
        
        # Crear el fichero solo si procede
        if [ $creado -eq 1 ]; then
          truncate -s "${tamano}K" "$nombre"
          echo "Creado el fichero '$nombre' con tamaño ${tamano}K"
        fi
      ;;
      11)
      # Reescribir
      palabra=$1
      echo "$palabra" | tr 'aeiouAEIOU' '1234512345'
      ;;
      12)
      # contusu"
      usuarios=$(ls /home | wc -l)
      echo "El sistema tiene $usuarios usuarios reales."
      
      ls /home
  
      echo ""
      read -p "Escribe el nombre de uno de los usuarios: " user
      mkdir -p /home/copiaseguridad
      cp -r /home/$user /home/copiaseguridad/${user}_$(date +%Y%m%d-%H%M%S)
      echo "Vamos a hacer una copia de seguridad de $user"
      ;;
      13)
      ;;
      14)
      ;;
      15)
      ;;
      *)
        echo "Opción incorrecta"
    esac
  done
}

menu
