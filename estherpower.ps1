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
                # pizza
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
                # dias
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
                # menu_usuarios
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
            # menu_grupos
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
            # diskp
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
            # contraseña
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
            # Fibonacci
            #Ponemos los dos primeros numeros de fibonacci
            $n1 = 0
            $n2 = 1
            #El usuario decide cuantos numero quiere imprimir
            $veces = Read-Host "Dime cuantas veces"
        
            Write-Host "Secuencia de Fibonacci:"

        23 { 
            #Fibonacci_recursiva
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
        24 { 
            # monitoreo
            (Get-Counter '\Procesador(_Total)\% de tiempo de procesador' -SampleInterval 5 -MaxSamples 6 ).CounterSamples.CookedValue |
            Measure-Object -Average | 
            ForEach-Object {"Promedio de CPU: $([math]::Round($_.Average,2)) %"}
            }
        25 { 
            # AlertaEspacio
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
        26 {
            # copiasMasivas
            $origen = "C:\Users"
            $destino = "C:\CopiasSeguridad"
            New-Item -ItemType Directory -Path $destino -Force | Out-Null
            
            Get-ChildItem -Path $origen -Directory |
                Where-Object { $omitir -notcontains $_.Name } |
                ForEach-Object {
                    $zip = Join-Path $destino ($_.Name + ".zip")
                    Compress-Archive -Path $_.FullName -DestinationPath $zip -CompressionLevel Optimal -Force
                }
        }    

         }
        27 {
            # automatizarps
            $dir = "C:\usuarios"
            
            # Si no existe, créalo y considéralo vacío
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Write-Host "Listado vacío (no hay documentos en $dir)."
                return
            }
            
            # Obtener documentos del directorio
            $docs = Get-ChildItem -Path $dir -File
            if (-not $docs) {
                Write-Host "Listado vacío (no hay documentos en $dir)."
                return
            }
            
            foreach ($doc in $docs) {
                $usuario = $doc.BaseName                           # nombre de usuario = nombre del documento (sin extensión)
                $home    = Join-Path "C:\Users" $usuario
            
                # Crear usuario local si no existe (sin contraseña)
                if (-not (Get-LocalUser -Name $usuario -ErrorAction SilentlyContinue)) {
                    New-LocalUser -Name $usuario -NoPassword | Out-Null
                }
            
                # Crear carpeta personal del usuario
                New-Item -ItemType Directory -Path $home -Force | Out-Null
            
                # Crear las carpetas listadas en el documento (una por línea)
                $lineas = Get-Content -Path $doc.FullName | Where-Object { $_ -and $_.Trim() -ne "" }
                foreach ($carpeta in $lineas) {
                    New-Item -ItemType Directory -Path (Join-Path $home $carpeta.Trim()) -Force | Out-Null
                }
            
                # Borrar el documento procesado
                Remove-Item -Path $doc.FullName -Force
            }


         }
        28 { 
            # barrido
            # CONFIGURACIÓN (editar a mano)          
            $inicio = "192.168.1.1"      # IP inicial
            $final  = "192.168.1.254"    # IP final
            $timeout = 1                 # tiempo de espera por ping (segundos)
            $salida = "activos.txt"      # archivo de salida
            
            # convertir IPs a números (simplemente separando por puntos)
            $ini = ($inicio.Split('.')[-1])
            $fin = ($final.Split('.')[-1])
            $base = ($inicio.Split('.')[0..2] -join '.')
            
            if (Test-Path $salida) { Remove-Item $salida }
            
            Write-Host "Iniciando barrido desde $inicio hasta $final..."
            
            $total = [int]$fin - [int]$ini + 1
            $cont = 0
            $activos = 0
            
            for ($i = [int]$ini; $i -le [int]$fin; $i++) {
                $ip = "$base.$i"
                $cont++
                Write-Progress -Activity "Barrido de red" -Status "Comprobando $ip ($cont / $total)" -PercentComplete (($cont / $total)*100)
                $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds $timeout
                if ($ping) {
                    "$ip" | Out-File -Append -FilePath $salida
                    Write-Host "-> $ip responde"
                    $activos++
                }
            }
            
            Write-Progress -Activity "Barrido de red" -Completed
            Write-Host ""
            Write-Host "Barrido finalizado. Direcciones activas: $activos"
            Write-Host "Guardadas en: $salida"        
        }
        29 { 
            # evento
            # Si se pasa un número como parámetro, se usa; si no, por defecto 200
            param([int]$cantidad = 200)
            
            Write-Host "Extrayendo los últimos $cantidad eventos críticos o de error de System y Application..."
            
            # Obtener eventos de ambos registros
            $eventosSystem = Get-EventLog -LogName System -EntryType Error, Critical -Newest $cantidad
            $eventosApp    = Get-EventLog -LogName Application -EntryType Error, Critical -Newest $cantidad
            
            # Unir los resultados
            $eventos = $eventosSystem + $eventosApp
            
            # Exportar a CSV
            $archivo = "eventos.csv"
            $eventos | Select-Object TimeGenerated, EntryType, Source, EventID, Message |
                Export-Csv -Path $archivo -NoTypeInformation -Encoding UTF8
            
            Write-Host "Exportados $($eventos.Count) eventos a $archivo"
        }
        30 {
            # agenda
            $agenda = @{}
        
            while ($true) {
                Write-Host ""
                Write-Host "========== AGENDA =========="
                Write-Host "[1] Añadir / Modificar"
                Write-Host "[2] Buscar (por prefijo)"
                Write-Host "[3] Borrar"
                Write-Host "[4] Listar"
                Write-Host "[0] Volver al menú anterior"
                Write-Host "============================"
                $op = Read-Host "Elige opción"
        
                switch ($op) {
                    '1' {
                        $nombre = (Read-Host "Nombre").Trim()
                        if (-not $nombre) { Write-Host "Nombre vacío."; break }
                        if ($agenda.ContainsKey($nombre)) {
                            Write-Host "Existe: $nombre -> $($agenda[$nombre])"
                            $resp = (Read-Host "¿Modificar teléfono? (s/n)").ToLower()
                            if ($resp -in @('s','si','sí')) {
                                $tel = (Read-Host "Nuevo teléfono").Trim()
                                if ($tel) { $agenda[$nombre] = $tel; Write-Host "Actualizado." }
                            }
                        } else {
                            $tel = (Read-Host "Teléfono").Trim()
                            if ($tel) { $agenda[$nombre] = $tel; Write-Host "Añadido." }
                        }
                    }
                    '2' {
                        $pref = (Read-Host "Prefijo").Trim()
                        $coinc = $agenda.Keys | Where-Object { $_ -like "$pref*" } | Sort-Object
                        if ($coinc) { foreach ($n in $coinc) { "{0,-30} {1}" -f $n, $agenda[$n] | Write-Host } }
                        else { Write-Host "Sin resultados." }
                    }
                    '3' {
                        $nombre = (Read-Host "Nombre a borrar").Trim()
                        if ($agenda.ContainsKey($nombre)) {
                            Write-Host "Encontrado: $nombre -> $($agenda[$nombre])"
                            $conf = (Read-Host "¿Confirmar borrado? (s/n)").ToLower()
                            if ($conf -in @('s','si','sí')) { [void]$agenda.Remove($nombre); Write-Host "Borrado." }
                        } else { Write-Host "No existe." }
                    }
                    '4' {
                        if ($agenda.Count -eq 0) { Write-Host "Agenda vacía." }
                        else { foreach ($n in ($agenda.Keys | Sort-Object)) { "{0,-30} {1}" -f $n, $agenda[$n] | Write-Host } }
                    }
                    '0' { break }
                    default { Write-Host "Opción no válida." }
                }
            }
        }

        31 { 
            # limpieza
            param(
            [Parameter(Mandatory=$true)] [string] $Ruta,
            [Parameter(Mandatory=$true)] [int]    $Dias,
            [Parameter(Mandatory=$true)] [string] $Log,
            [switch] $WhatIf
            )
            
            if (-not (Test-Path -LiteralPath $Ruta -PathType Container)) {
            Write-Error "La carpeta indicada no existe: $Ruta"
            exit 1
            }
            
            $umbral = (Get-Date).AddDays(-$Dias)
            $archivos = Get-ChildItem -LiteralPath $Ruta -File | Where-Object { $_.LastWriteTime -lt $umbral }
            
            foreach ($f in $archivos) {
            if ($WhatIf) {
            Write-Host "Se eliminaría: $($f.FullName) (Última escritura: $($f.LastWriteTime))"
            } else {
            Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue
            Write-Host "Eliminado: $($f.FullName) (Última escritura: $($f.LastWriteTime))"
            ("{0},{1},{2}" -f (Get-Date -Format s), $f.FullName, $f.Length) | Out-File -FilePath $Log -Append -Encoding UTF8
            }
            }

}
