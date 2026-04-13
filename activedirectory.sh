# Automatización, políticas del dominio y recursos compartidos

# Importar el modulo de Active Directory
Import-Module ActiveDirectory

$opcion = -1

do {
    Clear-Host
    Write-Host " Automatización, políticas del dominio y recursos compartidos "
    Write-Host " 1. Mostrar información del dominio"
    Write-Host " 2. Crear Unidad Organizativa"
    Write-Host " 3. Ver miembros de una OU"
    Write-Host " 4. Crear grupo"
    Write-Host " 5. Crear usuario"
    Write-Host " 0. Salir"
    $opcion = Read-Host "Selecciona una opcion"

    switch ($opcion) {

        # 1. Mostrar información del dominio
        "1" {
            $nombreEquipo = $env:COMPUTERNAME
            $dominio      = Get-ADDomain
            $numOUs       = (Get-ADOrganizationalUnit -Filter *).Count
            $numGrupos    = (Get-ADGroup -Filter *).Count
            $numUsuarios  = (Get-ADUser -Filter *).Count

            Write-Host "1. Mostrar información del dominio"
            Write-Host "Nombre del equipo  : $nombreEquipo"
            Write-Host "Nombre del dominio : $($dominio.DistinguishedName)"
            Write-Host "Numero de OUs      : $numOUs"
            Write-Host "Numero de grupos   : $numGrupos"
            Write-Host "Numero de usuarios : $numUsuarios"

            Read-Host "Pulsa ENTER para continuar"
        }

        # 2. Crear Unidad Organizativa
        "2" {
            Write-Host "2. Crear Unidad Organizativa"
            $nombreOU = Read-Host "Nombre de la nueva OU"
            $dominio  = Get-ADDomain
            New-ADOrganizationalUnit -Name $nombreOU -Path $dominio.DistinguishedName
            Write-Host "Unidad organizativa '$nombreOU' creada correctamente."

            Read-Host "Pulsa ENTER para continuar"
        }

        "3" {
            Write-Host "3. Ver miembros de una Unidad Organizativa"
            $Lista = Read-Host "Quieres ver la lista de Unidades Organizativas disponibles? (s/n)"
            if ($Lista -eq "s") {
                $ous = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
                $ous | ForEach-Object {
                    Write-Host "  $($_.Name)"
                }
                $nombreOU = Read-Host "Introduce el nombre de la OU"
                $OU       = ($ous | Where-Object { $_.Name -eq $nombreOU }).DistinguishedName
            }

            else {
                $OU = Read-Host "Introduce el nombre de la OU"
                $dominio = Get-ADDomain
                $OU      = "OU=" + $OU + "," + $dominio.DistinguishedName
            }
            $objetos = Get-ADObject -Filter * -SearchBase $OU -SearchScope OneLevel |
                       Select-Object Name
            if ($objetos.Count -eq 0) {
                Write-Host "La OU no contiene miembros."
            }
            else {
                $objetos | Format-Table -AutoSize
            }
            Read-Host "Pulsa ENTER para continuar"
        }

        # 4. Crear grupo
        "4" {
            Write-Host "4. Crear grupo"
            $nombreGrupo = Read-Host "Nombre del nuevo grupo"
            $descripcion = Read-Host "Descripcion del grupo"


            Write-Host "Ambito del grupo:"
            Write-Host "  1. DomainLocal"
            Write-Host "  2. Global"
            Write-Host "  3. Universal"
            $opAmbito = Read-Host "Selecciona ambito (1-3)"
            switch ($opAmbito) {
                "1" { $ambito = "DomainLocal" }
                "3" { $ambito = "Universal"   }
                default { $ambito = "Global"  }
            }


            Write-Host "Categoria del grupo:"
            Write-Host "  1. Security"
            Write-Host "  2. Distribution"
            $opCategoria = Read-Host "Selecciona categoria (1-2)"
            if ($opCategoria -eq "2") {
                $categoria = "Distribution"
            }
            else {
                $categoria = "Security"
            }


            $dominio = Get-ADDomain
            New-ADGroup -Name $nombreGrupo `
                        -GroupScope $ambito `
                        -GroupCategory $categoria `
                        -Description $descripcion `
                        -Path $dominio.DistinguishedName
            Write-Host "Grupo '$nombreGrupo' con el ámbito $ambito y la categoria $categoria creado correctamente."

            Read-Host "Pulsa ENTER para continuar"
        }

        #  5. Crear usuario
        "5" {
            Write-Host "5. Crear usuario"
            $nombre      = Read-Host "Nombre"
            $apellidos   = Read-Host "Apellidos"
            $samAccount  = Read-Host "Nombre de inicio de sesion (SamAccountName)"
            $descripcion = Read-Host "Descripcion"
            $email       = Read-Host "Correo electronico"
            $password    = Read-Host "Escribe una contraseña para el usuario" -AsSecureString
            $dominio     = Get-ADDomain

            # Crear el usuario obligando a cambiar contrasena en el primer inicio de sesion
            New-ADUser -GivenName $nombre `
                       -Surname $apellidos `
                       -Name "$nombre $apellidos" `
                       -SamAccountName $samAccount `
                       -UserPrincipalName "$samAccount@$($dominio.DNSRoot)" `
                       -Description $descripcion `
                       -EmailAddress $email `
                       -AccountPassword $password `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true `
                       -Path $dominio.DistinguishedName

            Write-Host "Usuario '$samAccount' creado correctamente."

            # Mostrar grupos disponibles y asignar el usuario al indicado
            Write-Host "Grupos disponibles en el dominio:"
            Get-ADGroup -Filter * | Select-Object -ExpandProperty Name | ForEach-Object {
                Write-Host "  $_"
            }
            $nombreGrupo = Read-Host "Nombre del grupo al que asignar el usuario"
            Add-ADGroupMember -Identity $nombreGrupo -Members $samAccount
            Write-Host "Usuario '$samAccount' agregado al grupo '$nombreGrupo'."

            Read-Host "Pulsa ENTER para continuar"
        }


        # 0. Salir

        "0" {
            Write-Host "Hasta pronto."
        }

        # Opcion no valida
        default {
            Write-Host "Opción no valida. Introduce un numero del 0 al 5."
            Start-Sleep -Seconds 2
        }
    }

} while ($opcion -ne "0")
