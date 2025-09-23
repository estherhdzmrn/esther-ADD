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
      ;;
      5)
      ;;
      6)
      ;;
      7)
      ;;
      8)
      ;;
      9)
      ;;
      10)
      ;;
      11)
      ;;
      12)
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
