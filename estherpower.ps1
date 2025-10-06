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
                $meses = 31,29,31,30,31,30,31,31,30,31,30,31
                $pares = 0
                $impares = 0
                foreach ($diasMes in $meses) {
                    for ($dia = 1; $dia -le $diasMes; $dia++) {
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
                Write-Host "******************"
                Write-Host "Menú para usuarios"
                Write-Host "1. Listar"
                Write-Host "2. Crear"
                Write-Host "3. Eliminar"
                Write-Host "4. Modificar"
                Write-Host "0. Salir"
                Write-Host "******************"

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
                        new-localUser -name $usuario -Password $password
                        Write-Host "Has creado el usuario $usuario"
                        }
                        3 {
                        $eliminarusu = Read-Host "Dime un usuario para eliminarlo"
                        remove-localUser $eliminarusu
                        Write-Host "Has eliminado a $eliminarusu"
                        }

                        4 {
                        $modificarusu = Read-Host "Dime el usuario para modificar"
                        $nombre = Read-Host "Dime el nuevo nombre"
                        Rename-LocalUser -name $modificarusu -NewName $nombre
                        Write-Host "Has modificado el nombre de $modificarusu por $nombre"
                        }
                    }
                }
        }

        19 {
            Write-Host "********************************"
            Write-Host "        Menú para grupos"
            Write-Host "1. Listar grupos y miembros"
            Write-Host "2. Crear grupo"
            Write-Host "3. Eliminar grupo"
            Write-Host "4. Crea miembro de un grupo"
            Write-Host "5. Elimina miembro de un grupo"
            Write-Host "0. Salir"
            Write-Host "********************************"

            while (($opcion = Read-Host "Elige una opción del 1-5, 0 para salir") -ne 0) {

                switch ($opcion) {
                    1 {
                       $listar = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
                        foreach ($grp in $listar) {
                            Write-Host "Grupo: $grp"
                            $miembro = get-ADgroupMember -Identity "$grp" | Select-Object -ExpandProperty Name
                            Write-Host "- $miembro"
                        }

                    }

                    2 {
                        $nombregrp = Read-Host "Dime el nombre del grupo que quieres crear"
                        New-ADGroup -name $nombregrp -GroupScope Global
                        Write-Host "Tu grupo $nombregrp ha sido creado"
                    }

                    3 {
                       $eliminar = Read-Host "Dime el nombre del grupo a eliminar"
                       remove-ADgroup $eliminar
                       Write-Host "Has borrado el grupo $eliminar"
                    }

                    4{
                       $miembro = Read-Host "Dime el miembro que quieres añadir a un grupo"
                       $grp = Read-Host "Dime el grupo al que quieres añadir el miembro anterior"
                       Add-ADGroupMember -Identity $grp -Members $miembro
                       Write-Host "Has añadido a $miembro en $grp"
                    }

                    5 {
                       $usu = Read-host "Dame el miembro que quieres borrar de un grupo"
                       $grp = Read-Host "Dame el grupo del miembro que quieres borrar"
                       Remove-ADGroupMember -Identity $grp -Members $usu
                       Write-Host "Has borrado el miembro $usu del grupo $grp"
                    }
                }          
            } 

        }
        20 { 
            Get-Disk
            $disc = Read-Host "Dime el número de disco a utilizar"
            $GB = [math]::Round((Get-Disk -Number $disc).Size / 1GB, 2)
            Write-Host "El tamaño del disco es de $GB GB"

            $ruta   = "$env:TEMP\diskpart_script.txt"
    
            "select disk $disc" | Out-File -FilePath "$ruta" -Encoding ASCII
            "clean" | Out-File -FilePath "$ruta" -Append -Encoding ASCII

            Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$ruta`"" `
            -NoNewWindow -Wait 
            Write-Host "El disco $disc ha sido borrado"
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
        }
    }
}
