param(
    # Parámetro principal: indica QUÉ acción queremos hacer
    # Ejemplos: "-G" para crear grupo, "-U" para crear usuario, etc.
    [string]$Accion,
    
    # Segundo parámetro: su significado cambia según la acción
    # Por ejemplo: nombre de grupo, nombre de usuario, nueva contraseña...
    [string]$Param2,
    
    # Tercer parámetro: también cambia según la acción
    # Por ejemplo: tipo de grupo, unidad organizativa, estado de cuenta...
    [string]$Param3,
    
    # Parámetro especial: si se activa, NO ejecuta nada real, solo SIMULA
    # Se usa así: .\esther-adam02.ps1 -Accion "-G" -Param2 "Global" -DryRun
    [switch]$DryRun
)

# BLOQUE 2: FUNCIÓN AUXILIAR PARA MOSTRAR AYUDA
# Esta función muestra al usuario cómo usar el script cuando no sabe qué hacer

function Mostrar-Ayuda {
    Write-Host ""
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host "  SCRIPT DE ADMINISTRACIÓN - esther-adam02  " -ForegroundColor Cyan
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "USO: .\esther-adam02.ps1 -Accion <ACCION> -Param2 <VALOR> -Param3 <VALOR> [-DryRun]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "ACCIONES DISPONIBLES:" -ForegroundColor Green
    Write-Host ""
    Write-Host "  -G  → Crear GRUPO" -ForegroundColor White
    Write-Host "        Param2: Ámbito del grupo (Global, Universal, DomainLocal)"
    Write-Host "        Param3: Tipo de grupo (Security, Distribution)"
    Write-Host "        Ejemplo: .\esther-adam02.ps1 -Accion '-G' -Param2 'Global' -Param3 'Security'"
    Write-Host ""
    Write-Host "  -U  → Crear USUARIO" -ForegroundColor White
    Write-Host "        Param2: Nombre del usuario"
    Write-Host "        Param3: Unidad Organizativa (OU) donde crearlo"
    Write-Host "        Ejemplo: .\esther-adam02.ps1 -Accion '-U' -Param2 'juan' -Param3 'OU=Usuarios,DC=empresa,DC=local'"
    Write-Host ""
    Write-Host "  -M  → MODIFICAR usuario" -ForegroundColor White
    Write-Host "        Param2: Nueva contraseña"
    Write-Host "        Param3: Estado de la cuenta (Enable o Disable)"
    Write-Host "        Ejemplo: .\esther-adam02.ps1 -Accion '-M' -Param2 'P@ssw0rd123!' -Param3 'Enable'"
    Write-Host ""
    Write-Host "  -AG → ASIGNAR usuario a grupo" -ForegroundColor White
    Write-Host "        Param2: Nombre del usuario"
    Write-Host "        Param3: Nombre del grupo"
    Write-Host "        Ejemplo: .\esther-adam02.ps1 -Accion '-AG' -Param2 'juan' -Param3 'Administradores'"
    Write-Host ""
    Write-Host "  -LIST → LISTAR usuarios/grupos" -ForegroundColor White
    Write-Host "        Param2: Qué listar (Usuarios, Grupos, Ambos)"
    Write-Host "        Param3: Filtro por OU (opcional)"
    Write-Host "        Ejemplo: .\esther-adam02.ps1 -Accion '-LIST' -Param2 'Usuarios'"
    Write-Host ""
    Write-Host "PARÁMETRO ESPECIAL:" -ForegroundColor Magenta
    Write-Host "  -DryRun → Modo simulación: muestra qué haría sin ejecutar nada"
    Write-Host ""
}

# BLOQUE 3: VERIFICACIÓN INICIAL - ¿El usuario pasó alguna acción?

# Si el usuario ejecuta el script SIN indicar ninguna acción, mostramos ayuda

if (-not $Accion) {
    # El parámetro $Accion está vacío, mostramos la ayuda
    Write-Host ""
    Write-Host "ERROR: No has indicado ninguna acción." -ForegroundColor Red
    Write-Host "El script necesita saber QUÉ quieres hacer." -ForegroundColor Yellow
    Mostrar-Ayuda
    return  # Terminamos la ejecución del script aquí
}


# BLOQUE 4: MOSTRAR MODO DE EJECUCIÓN (Real o Simulación)

# Informamos al usuario si estamos en modo simulación o modo real

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO SCRIPT esther-adam02.ps1  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($DryRun) {
    # El usuario activó el modo DryRun, solo vamos a simular
    Write-Host "MODO: SIMULACIÓN (DRY-RUN)" -ForegroundColor Magenta
    Write-Host "No se realizarán cambios reales en el sistema." -ForegroundColor Yellow
} else {
    # Modo normal, vamos a hacer cambios reales
    Write-Host "MODO: EJECUCIÓN REAL" -ForegroundColor Green
    Write-Host "Se aplicarán cambios en Active Directory." -ForegroundColor Yellow
}
Write-Host ""

# BLOQUE 5: LÓGICA PRINCIPAL - DECISIÓN DE QUÉ ACCIÓN EJECUTAR

# Aquí usamos IF-ELSEIF para decidir qué hacer según el parámetro -Accion

# ACCIÓN 1: CREAR GRUPO (-G)
if ($Accion -eq "-G") {
    
    Write-Host "ACCIÓN SELECCIONADA: Crear Grupo" -ForegroundColor Cyan
    Write-Host "Ámbito solicitado: $Param2" -ForegroundColor White
    Write-Host "Tipo solicitado: $Param3" -ForegroundColor White
    Write-Host ""
    
    # Paso 1: Validar que los parámetros no estén vacíos
    if (-not $Param2 -or -not $Param3) {
        Write-Host "ERROR: Faltan parámetros para crear el grupo." -ForegroundColor Red
        Write-Host "Necesitas indicar Param2 (Ámbito) y Param3 (Tipo)." -ForegroundColor Yellow
        return
    }
    
    # Paso 2: Pedir el nombre del grupo al usuario
    $NombreGrupo = Read-Host "Introduce el NOMBRE del grupo a crear"
    
    # Paso 3: Intentar verificar si el grupo ya existe
    try {
        # Intentamos buscar el grupo en Active Directory
        $grupoExistente = Get-ADGroup -Identity $NombreGrupo -ErrorAction Stop
        
        # Si llegamos aquí, el grupo SÍ existe
        Write-Host "RESULTADO: El grupo '$NombreGrupo' YA EXISTE." -ForegroundColor Red
        Write-Host "No se puede crear un grupo con un nombre duplicado." -ForegroundColor Yellow
        
    } catch {
        # Si Get-ADGroup da error, es porque el grupo NO existe
        # Esto es lo que queremos: poder crearlo
        
        Write-Host "El grupo '$NombreGrupo' no existe. Procediendo a crearlo..." -ForegroundColor Green
        
        # Path dinámico para compatibilidad universal]
        # Obtener automáticamente la ruta del dominio actual
        # Esto hace que el script funcione en CUALQUIER dominio
        try {
            $dominioPath = (Get-ADDomain).DistinguishedName
            $pathGrupo = "CN=Users,$dominioPath"
        } catch {
            Write-Host "ERROR: No se puede obtener información del dominio." -ForegroundColor Red
            Write-Host "Asegúrate de que el módulo Active Directory esté disponible." -ForegroundColor Yellow
            return
        }
        
        # Verificar si estamos en modo DryRun
        if ($DryRun) {
            # Solo mostrar qué haríamos
            Write-Host ""
            Write-Host "[SIMULACIÓN] Se ejecutaría el siguiente comando:" -ForegroundColor Magenta
            Write-Host "New-ADGroup -Name '$NombreGrupo' -GroupScope $Param2 -GroupCategory $Param3 -Path '$pathGrupo'" -ForegroundColor Gray
            Write-Host ""
            
        } else {
            # Modo real: crear el grupo de verdad
            try {
                # Comando real para crear el grupo en Active Directory
                New-ADGroup -Name $NombreGrupo `
                           -GroupScope $Param2 `
                           -GroupCategory $Param3 `
                           -Path $pathGrupo
                
                Write-Host ""
                Write-Host "ÉXITO: Grupo '$NombreGrupo' creado correctamente." -ForegroundColor Green
                Write-Host "  Ubicación: $pathGrupo" -ForegroundColor Cyan
                Write-Host ""
                
            } catch {
                # Si algo sale mal al crear el grupo
                Write-Host ""
                Write-Host "ERROR al crear el grupo: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
            }
        }
    }
}

# ACCIÓN 2: CREAR USUARIO (-U)
elseif ($Accion -eq "-U") {
    
    Write-Host "ACCIÓN SELECCIONADA: Crear Usuario" -ForegroundColor Cyan
    Write-Host "Nombre de usuario: $Param2" -ForegroundColor White
    Write-Host "Unidad Organizativa: $Param3" -ForegroundColor White
    Write-Host ""
    
    # Paso 1: Validar parámetros
    if (-not $Param2) {
        Write-Host "ERROR: Falta el parámetro Param2 (nombre de usuario)." -ForegroundColor Red
        return
    }
    
    $NombreUsuario = $Param2
    
    # OU dinámico si no se especifica]
    # Si no se especifica OU, usamos CN=Users del dominio actual
    if (-not $Param3) {
        try {
            $dominioPath = (Get-ADDomain).DistinguishedName
            $UO = "CN=Users,$dominioPath"
            Write-Host "No se especificó OU. Usando ubicación predeterminada: $UO" -ForegroundColor Yellow
        } catch {
            Write-Host "ERROR: No se puede obtener información del dominio." -ForegroundColor Red
            return
        }
    } else {
        $UO = $Param3
    }
    
    # Paso 2: Verificar si el usuario ya existe
    try {
        $usuarioExistente = Get-ADUser -Identity $NombreUsuario -ErrorAction Stop
        
        # Si llegamos aquí, el usuario YA existe
        Write-Host "RESULTADO: El usuario '$NombreUsuario' YA EXISTE." -ForegroundColor Red
        Write-Host "No se puede crear un usuario duplicado." -ForegroundColor Yellow
        
    } catch {
        # El usuario NO existe, podemos crearlo
        
        Write-Host "El usuario '$NombreUsuario' no existe. Procediendo a crearlo..." -ForegroundColor Green
        
        # Paso 3: Generar una contraseña aleatoria segura
        # [MANUAL: INICIO - Generación de contraseña simplificada]
        $contrasenaTemporal = "Pass" + (Get-Random -Minimum 1000 -Maximum 9999) + "!"
        Write-Host "Contraseña generada: $contrasenaTemporal" -ForegroundColor Yellow
        
        # Convertir la contraseña a formato seguro (SecureString)
        $contrasenaSegura = ConvertTo-SecureString $contrasenaTemporal -AsPlainText -Force
        
        if ($DryRun) {
            Write-Host ""
            Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
            Write-Host "New-ADUser -Name '$NombreUsuario' -SamAccountName '$NombreUsuario' -AccountPassword [SEGURA] -Enabled `$true -Path '$UO'" -ForegroundColor Gray
            Write-Host ""
            
        } else {
            # Crear el usuario de verdad
            try {
                New-ADUser -Name $NombreUsuario `
                          -SamAccountName $NombreUsuario `
                          -AccountPassword $contrasenaSegura `
                          -Enabled $true `
                          -Path $UO
                
                Write-Host ""
                Write-Host " ÉXITO: Usuario '$NombreUsuario' creado." -ForegroundColor Green
                Write-Host "  Contraseña asignada: $contrasenaTemporal" -ForegroundColor Cyan
                Write-Host "  Ubicación: $UO" -ForegroundColor Cyan
                Write-Host "  (El usuario deberá cambiarla en el primer inicio de sesión)" -ForegroundColor Yellow
                Write-Host ""
                
            } catch {
                Write-Host ""
                Write-Host "ERROR al crear usuario: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
            }
        }
    }
}

# ACCIÓN 3: MODIFICAR USUARIO (-M)

elseif ($Accion -eq "-M") {
    
    Write-Host "ACCIÓN SELECCIONADA: Modificar Usuario" -ForegroundColor Cyan
    Write-Host "Nueva contraseña: [OCULTA POR SEGURIDAD]" -ForegroundColor White
    Write-Host "Acción con la cuenta: $Param3" -ForegroundColor White
    Write-Host ""
    
    # Paso 1: Validar parámetros
    if (-not $Param2 -or -not $Param3) {
        Write-Host "ERROR: Faltan parámetros." -ForegroundColor Red
        Write-Host "Necesitas Param2 (contraseña) y Param3 (Enable/Disable)." -ForegroundColor Yellow
        return
    }
    
    # Paso 2: Pedir el nombre del usuario a modificar
    $NombreUsuario = Read-Host "Introduce el nombre del USUARIO a modificar"
    
    # Paso 3: Verificar que el usuario existe
    try {
        $usuario = Get-ADUser -Identity $NombreUsuario -ErrorAction Stop
        
        Write-Host "Usuario '$NombreUsuario' encontrado. Procediendo..." -ForegroundColor Green
        
        # Validación de complejidad de contraseña]
        # Paso 4: Validar que la contraseña cumple requisitos mínimos
        $nuevaContrasena = $Param2
        $esValida = $true
        $razones = @()
        
        # Comprobar longitud mínima (8 caracteres)
        if ($nuevaContrasena.Length -lt 8) {
            $esValida = $false
            $razones += "- Debe tener al menos 8 caracteres"
        }
        
        # Comprobar que tiene al menos una mayúscula
        if ($nuevaContrasena -cnotmatch "[A-Z]") {
            $esValida = $false
            $razones += "- Debe contener al menos una letra MAYÚSCULA"
        }
        
        # Comprobar que tiene al menos una minúscula
        if ($nuevaContrasena -cnotmatch "[a-z]") {
            $esValida = $false
            $razones += "- Debe contener al menos una letra minúscula"
        }
        
        # Comprobar que tiene al menos un número
        if ($nuevaContrasena -cnotmatch "[0-9]") {
            $esValida = $false
            $razones += "- Debe contener al menos un número"
        }
        
        # Comprobar que tiene al menos un carácter especial
        if ($nuevaContrasena -cnotmatch "[!@#$%^&*()_+\-=\[\]{};:,.<>?]") {
            $esValida = $false
            $razones += "- Debe contener al menos un carácter especial (!@#$...)"
        }
        
        # Paso 5: Actuar según si la contraseña es válida o no
        if (-not $esValida) {
            Write-Host ""
            Write-Host "ERROR: La contraseña NO cumple los requisitos de complejidad:" -ForegroundColor Red
            foreach ($razon in $razones) {
                Write-Host "  $razon" -ForegroundColor Yellow
            }
            Write-Host ""
            return
        }
        
        # La contraseña es válida, continuamos
        Write-Host " Contraseña válida (cumple requisitos de complejidad)." -ForegroundColor Green
        
        # Convertir a SecureString
        $contrasenaSegura = ConvertTo-SecureString $nuevaContrasena -AsPlainText -Force
        
        if ($DryRun) {
            Write-Host ""
            Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
            Write-Host "Set-ADAccountPassword -Identity '$NombreUsuario' -NewPassword [SEGURA] -Reset" -ForegroundColor Gray
            
            if ($Param3 -eq "Enable") {
                Write-Host "Enable-ADAccount -Identity '$NombreUsuario'" -ForegroundColor Gray
            } elseif ($Param3 -eq "Disable") {
                Write-Host "Disable-ADAccount -Identity '$NombreUsuario'" -ForegroundColor Gray
            }
            Write-Host ""
            
        } else {
            # Modo real: cambiar la contraseña
            try {
                Set-ADAccountPassword -Identity $usuario -NewPassword $contrasenaSegura -Reset
                Write-Host " Contraseña cambiada correctamente." -ForegroundColor Green
                
                # Habilitar o deshabilitar la cuenta según Param3
                if ($Param3 -eq "Enable") {
                    Enable-ADAccount -Identity $usuario
                    Write-Host " Cuenta HABILITADA." -ForegroundColor Green
                    
                } elseif ($Param3 -eq "Disable") {
                    Disable-ADAccount -Identity $usuario
                    Write-Host " Cuenta DESHABILITADA." -ForegroundColor Green
                    
                } else {
                    Write-Host "Advertencia: Param3 debe ser 'Enable' o 'Disable'." -ForegroundColor Yellow
                }
                
                Write-Host ""
                
            } catch {
                Write-Host ""
                Write-Host "ERROR al modificar usuario: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
            }
        }
        
    } catch {
        # El usuario no existe
        Write-Host "ERROR: El usuario '$NombreUsuario' NO EXISTE." -ForegroundColor Red
        Write-Host ""
    }
}


# ACCIÓN 4: ASIGNAR USUARIO A GRUPO (-AG)

elseif ($Accion -eq "-AG") {
    
    Write-Host "ACCIÓN SELECCIONADA: Asignar Usuario a Grupo" -ForegroundColor Cyan
    Write-Host "Usuario: $Param2" -ForegroundColor White
    Write-Host "Grupo: $Param3" -ForegroundColor White
    Write-Host ""
    
    # Paso 1: Validar parámetros
    if (-not $Param2 -or -not $Param3) {
        Write-Host "ERROR: Faltan parámetros." -ForegroundColor Red
        Write-Host "Necesitas Param2 (usuario) y Param3 (grupo)." -ForegroundColor Yellow
        return
    }
    
    $NombreUsuario = $Param2
    $NombreGrupo = $Param3
    
    # Paso 2: Verificar que el USUARIO existe
    $usuarioExiste = $false
    try {
        Get-ADUser -Identity $NombreUsuario -ErrorAction Stop | Out-Null
        $usuarioExiste = $true
        Write-Host " Usuario '$NombreUsuario' encontrado." -ForegroundColor Green
    } catch {
        Write-Host " ERROR: El usuario '$NombreUsuario' NO EXISTE." -ForegroundColor Red
    }
    
    # Paso 3: Verificar que el GRUPO existe
    $grupoExiste = $false
    try {
        Get-ADGroup -Identity $NombreGrupo -ErrorAction Stop | Out-Null
        $grupoExiste = $true
        Write-Host " Grupo '$NombreGrupo' encontrado." -ForegroundColor Green
    } catch {
        Write-Host " ERROR: El grupo '$NombreGrupo' NO EXISTE." -ForegroundColor Red
    }
    
    Write-Host ""
    
    # Paso 4: Solo continuar si ambos existen
    if ($usuarioExiste -and $grupoExiste) {
        
        if ($DryRun) {
            Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
            Write-Host "Add-ADGroupMember -Identity '$NombreGrupo' -Members '$NombreUsuario'" -ForegroundColor Gray
            Write-Host ""
            
        } else {
            # Asignar de verdad
            try {
                Add-ADGroupMember -Identity $NombreGrupo -Members $NombreUsuario
                
                Write-Host " ÉXITO: Usuario '$NombreUsuario' añadido al grupo '$NombreGrupo'." -ForegroundColor Green
                Write-Host ""
                
            } catch {
                Write-Host "ERROR al asignar: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
            }
        }
        
    } else {
        Write-Host "RESULTADO: No se puede realizar la asignación." -ForegroundColor Red
        Write-Host "Verifica que tanto el usuario como el grupo existan." -ForegroundColor Yellow
        Write-Host ""
    }
}


# ACCIÓN 5: LISTAR USUARIOS Y/O GRUPOS (-LIST)

elseif ($Accion -eq "-LIST") {
    
    Write-Host "ACCIÓN SELECCIONADA: Listar Objetos" -ForegroundColor Cyan
    Write-Host "Tipo a listar: $Param2" -ForegroundColor White
    
    if ($Param3) {
        Write-Host "Filtro por OU: $Param3" -ForegroundColor White
    } else {
        Write-Host "Sin filtro de OU (se listarán todos)" -ForegroundColor White
    }
    Write-Host ""
    
    # Paso 1: Validar que se indicó qué listar
    if (-not $Param2) {
        Write-Host "ERROR: Debes indicar qué listar en Param2." -ForegroundColor Red
        Write-Host "Opciones: 'Usuarios', 'Grupos', 'Ambos'" -ForegroundColor Yellow
        return
    }
    
    if ($DryRun) {
        Write-Host "[SIMULACIÓN] Se listarían los objetos solicitados." -ForegroundColor Magenta
        Write-Host ""
        return
    }
    
    # Paso 2: Listar USUARIOS si se pidió
    if ($Param2 -eq "Usuarios" -or $Param2 -eq "Ambos") {
        
        Write-Host "========== USUARIOS ==========" -ForegroundColor Yellow
        
        try {
            if ($Param3) {
                # Listar solo de una OU específica
                Get-ADUser -Filter * -SearchBase $Param3 | 
                    Select-Object Name, SamAccountName, Enabled | 
                    Format-Table -AutoSize
            } else {
                # Listar todos los usuarios del dominio
                Get-ADUser -Filter * | 
                    Select-Object Name, SamAccountName, Enabled | 
                    Format-Table -AutoSize
            }
        } catch {
            Write-Host "ERROR al listar usuarios: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
    }
    
    # Paso 3: Listar GRUPOS si se pidió
    if ($Param2 -eq "Grupos" -or $Param2 -eq "Ambos") {
        
        Write-Host "========== GRUPOS ==========" -ForegroundColor Yellow
        
        try {
            if ($Param3) {
                # Listar solo de una OU específica
                Get-ADGroup -Filter * -SearchBase $Param3 | 
                    Select-Object Name, GroupScope, GroupCategory | 
                    Format-Table -AutoSize
            } else {
                # Listar todos los grupos del dominio
                Get-ADGroup -Filter * | 
                    Select-Object Name, GroupScope, GroupCategory | 
                    Format-Table -AutoSize
            }
        } catch {
            Write-Host "ERROR al listar grupos: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
    }
}


# CASO POR DEFECTO: Acción no reconocida

else {
    Write-Host ""
    Write-Host "ERROR: Acción '$Accion' no reconocida." -ForegroundColor Red
    Write-Host "Las acciones válidas son: -G, -U, -M, -AG, -LIST" -ForegroundColor Yellow
    Write-Host ""
    Mostrar-Ayuda
}


# FIN DEL SCRIPT

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SCRIPT FINALIZADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
