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
            function diskpart {
            ﻿# Solicitamos el número de disco
            $numdisk = Read-Host "¿Qué disco quiere utilizar?"
            
            #Obtenemos el tamaño del disco pedido en GB
            $tamdisk = (Get-Disk -Number $numdisk | Select-Object Size).Size /1GB
            Write-Host "El tamaño del disco $numdisk es de $tamdisk GB."
            
            #Abrimos el diskpart, limpiamos el disco seleccionado y lo convertimos en dinámico y gpt.
@"
            sel disk $numdisk
            clean
            conv gpt
            con dyn
"@ | diskpart
            
            #Creamos particiones de 1GB hasta limitar su espacio.
            $letra = 'D'
            $numvol = 0
            for ($espacdisk = 1; $espacdisk -le $tamdisk; $espacdisk++) {
            $letra = [char]([int]$letra[0] + 1)
            $numvol++
@"
            sel disk $numdisk
            create volume simple size=1022
            format fs='NTFS' label='Volumen $numvol' 'quick'
            assign letter $letra
"@ | diskpart
            }
        }
        21 { 
            $contrasena_seg = Read-Host "Dime una contraseña" -AsSecureString
            $contrasena = [System.net.NetworkCredential]::new("",$contrasena_seg).Password
        
            if ($contrasena.Length -lt 8){
            return $false
            }
            
            if ($contrasena -notmatch '[a-z]'){
            return $false
            }
            if ($contrasena -notmatch '[A-Z]'){
            return $false
            }
            if ($contrasena -notmatch '\d'){
            return $false 
            }
            if ($contrasena -notmatch '[^a-zA-Z0-9]'){
            return $false9
            }
            return $true
            
            if( validar $contrasena){
            Write-Host ""
            Write-Host "contraseña valida"
            }
            else{
            Write-Host ""
            Write-Host "Contraseña no valida"
            }
        }
        22 { 
            #Ponemos los dos primeros numeros de fibonacci
            $n1 = 0
            $n2 = 1
            #El usuario decide cuantos numero quiere imprimir
            $veces = Read-Host "Dime cuantas veces"
        
            Write-Host "Secuencia de Fibonacci:"
        
            #Ejecutamos el bucle mientras sea menor o igual a las veces haya introducido el usuario e incrementamos 
            for ($i = 0; $i -lt $veces; $i++) {
               #Hacemos que imprima los dos primero numero (0 y 1)
                if ($i -lt 2) {
                    $resultado = $i
                } else {
                #Calculamos el siguiente numero con una suma
                    $resultado = $n1 + $n2
                #Actualizamos los valores para que los numeros sean los dos ultimos usados 
                    $n1 = $n2
                    $n2 = $resultado
                }
                #Los imprimimos por pantalla todo seguido
                Write-Host " " $resultado -NoNewLine
        }
        23 { 
            (Get-Counter '\Procesador(_Total)\% de tiempo de procesador' -SampleInterval 5 -MaxSamples 6 ).CounterSamples.CookedValue |
            Measure-Object -Average | 
            ForEach-Object {"Promedio de CPU: $([math]::Round($_.Average,2)) %"}
            }
        24 { 
            $ruta = "$env:USERPROFILE\espacio.log"
        
            Get-PSDrive -PSProvider 'FileSystem' | ForEach-Object {
            $total = $_.Used + $_.Free
            if ($total -eq 0){ return }
        
            $porcent_libre = ($_.Free / $total) * 100
            $GB = $_.Free / 1GB
        
            Write-Host "La unidad $($_.Name): tiene $GB GB Libres ($porcent_libre GB)"
        
            if ($porcent_libre -lt 10){
                $mensaje = "Alerta: Unidad $($_.Name) solo tiene $porcent_libre ($GB GB)"
                $mensaje >> $ruta
            }
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
