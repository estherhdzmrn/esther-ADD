# Menú principal
Clear-Host
Write-Host "****************"
Write-Host "MENÚ PRINCIPAL"
Write-Host "****************"
Write-Host ""
Write-Host "16) Pizza"
Write-Host "17) Días"
Write-Host "18) Menú usuarios"
Write-Host "19) Menú grupos"
Write-Host "20) DiskP"
Write-Host "21) Contraseña"
Write-Host "22) Fibonacci 1"
Write-Host "23) Fibonacci 2"
Write-Host "24) Monitoreo"
Write-Host "25) Alerta espacio"
Write-Host "26) Copias masivas"
Write-Host "27) Automatizar"
Write-Host "28) Barrido"
Write-Host "29) Eventos y Agenda"
Write-Host "30) Limpieza"
Write-Host " 0) Salir"
Write-Host "************************"
Write-Host " "

while (($opcion = Read-Host "Elige una opción del al 16–30 ó 0 para salir: ") -ne 0) {
    switch ($opcion) {
        16 { 
                Write-Host "Bienvenido a la Pizzería Bella Napoli, servimos pizzas Vegetariana y Normal"
                $pizza = Read-Host "Elija la opción Vegetariana (Pimiento/Tofu) o Normal(Peperoni/Jamón/Salmón)"
                if ($pizza -eq "Vegetariana") {
                    $ingrediente = Read-Host "Elige entre Pimiento o Tofu";
                    if (($ingrediente -eq "Pimiento") -OR ($ingrediente -eq "Tofu")) {
                    Write-Host "Su pizza será Vegetariana con $ingrediente, Mozarella y Tomate"
                    } else {
                            Write-Host "Por favor, elija Pimiento o Tofu"
                    }
                } else {
                    $ingrediente = Read-Host "Elige entre Peperoni, Jamón o Salmón"
                    if (($ingrediente -eq "Peperoni") -or ($ingrediente -eq "Jamón") -or ($ingrediente -eq "Salmón")) {
                    Write-Host "Su pizza será Normal con $ingrediente, Mozarella y Tomate"
                    } else {
                            Write-Host "Por favor, elija Peperoni, Jamón o Salmón"
                            }
                }
            }        
        17 { 
                Write-Host "Calcular el número de días pares e impares que hay en un año bisiesto: "
                $longitudes = 31,29,31,30,31,30,31,31,30,31,30,31
                $pares = 0
                $impares = 0
                foreach ($diasEnMes in $longitudes) {
                    for ($dia = 1; $dia -le $diasEnMes; $dia++) {
                        if ($dia % 2 -eq 0) { 
                        $pares++ 
                        } else { 
                        $impares++ 
                        }
                    }
                }
                Write-Host "Hay un total de $pares días pares"
                Write-Host "Hay un total de $impares días impares"     
         }

        18 {
            function menu_usuarios {
                Write-Host "***************"
                Write-Host "Menú para usuarios"
                Write-Host "1. Listar"
                Write-Host "2. Crear"
                Write-Host "3. Eliminar"
                Write-Host "4. Modificar"
                Write-Host "0. Salir"
                Write-Host "***************"
                }

                menu_usuarios

                while (($opcion = Read-Host "Elige una opción del 1-4, 0 para salir") -ne 0) {
                    switch ($opcion) {
                        1 {
                        $listar = get-localuser
                        foreach ($usuarios in $listar) {
                            Write-Host "$usuarios"
                            }
                        }

                        2 {
                        $usuario = Read-Host "Dame un usuario"
                        $password = Read-Host "Dame una contraseña de 7 caracteres" -AsSecureString
                        $crearusu = new-localUser -name $usuario -Password $password
                        Write-Host "Has creado el usuario $usuario"
                        }
                        3 {
                        $eliminarusu = Read-Host "Dime un usuario para eliminarlo"
                        $eliminar = remove-localUser $eliminarusu
                        Write-Host "Has eliminado a $eliminarusu"
                        }

                        4 {
                        $modificarusu = Read-Host "Dime el usuario para modificar"
                        $nombre = Read-Host "Dime el nuevo nombre"
                        $modificar = Rename-LocalUser -name $modificarusu -NewName $nombre
                        Write-Host "Has modificado el nombre de $modificarusu por $nombre"
                        }
                    }
                }
                menu_usuarios
        }

        19 { 

        }
        20 { 
        
        }
        21 { 
        
        }
        22 { 
        
        }
        23 { 
        
        }
        24 { 
        
        }
        25 {
        
         }
        26 {
        
         }
        27 { 
        
        }
        28 { 
        
        }
        29 {
        
         }
        30 { 
        
        }
        0  { 
            Write-Host "Hola"
        }
    }
}
