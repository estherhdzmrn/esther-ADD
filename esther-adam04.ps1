# BLOQUE 1: PARÁMETROS Y VARIABLES GLOBALES

# Parámetro para modo simulación
param(
    [switch]$DryRun
)

# Ruta del script a evaluar (debe estar en la misma carpeta)
$RutaScript3 = ".\esther-adam03.ps1"

# Ruta del fichero de pruebas que crearemos
$FicheroPruebas = "C:\temp\bajas_test.txt"

# Contadores para la calificación
$TotalPruebas = 10
$PruebasExitosas = 0
$PruebasFalladas = 0

# Array para almacenar los errores detectados
$Errores = @()

# Usuarios de prueba que crearemos
$UsuarioPrueba1 = "testuser001"
$UsuarioPrueba2 = "testuser002"
$UsuarioInexistente = "usuarionoexiste999"

# BLOQUE 2: FUNCIÓN PARA REGISTRAR RESULTADOS DE PRUEBAS

function Registrar-Prueba {
    param(
        [int]$NumeroPrueba,
        [string]$Descripcion,
        [bool]$Exitosa,
        [string]$Mensaje
    )
    
    if ($Exitosa) {
        Write-Host "  ✓ PRUEBA $NumeroPrueba : $Descripcion" -ForegroundColor Green
        $script:PruebasExitosas++
    } else {
        Write-Host "  ✗ PRUEBA $NumeroPrueba : $Descripcion" -ForegroundColor Red
        Write-Host "    Motivo: $Mensaje" -ForegroundColor Yellow
        $script:PruebasFalladas++
        $script:Errores += "Prueba $NumeroPrueba - $Descripcion : $Mensaje"
    }
}

# BLOQUE 3: MOSTRAR ENCABEZADO Y MODO DE EJECUCIÓN

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SCRIPT DE CALIFICACIÓN" -ForegroundColor Cyan
Write-Host "  esther-adam04.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Mostrar modo de ejecución
if ($DryRun) {
    Write-Host "MODO: SIMULACIÓN (DRY-RUN)" -ForegroundColor Magenta
    Write-Host "No se realizarán cambios reales en el sistema." -ForegroundColor Yellow
} else {
    Write-Host "MODO: EJECUCIÓN REAL" -ForegroundColor Green
    Write-Host "Se aplicarán cambios en Active Directory y sistema de archivos." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Este script evaluará automáticamente el funcionamiento" -ForegroundColor White
Write-Host "del script esther-adam03.ps1 mediante 10 pruebas." -ForegroundColor White
Write-Host ""

# BLOQUE 4: VERIFICAR QUE EXISTE EL SCRIPT 3

Write-Host "Verificando que existe el script a evaluar..." -ForegroundColor Cyan

if (-not (Test-Path $RutaScript3)) {
    Write-Host "ERROR: No se encuentra el script $RutaScript3" -ForegroundColor Red
    Write-Host "Asegúrate de que esther-adam03.ps1 está en la misma carpeta." -ForegroundColor Yellow
    Write-Host ""
    return
}

Write-Host "✓ Script encontrado: $RutaScript3" -ForegroundColor Green
Write-Host ""

# BLOQUE 5: PREPARAR ENTORNO DE PRUEBAS

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FASE 1: PREPARANDO ENTORNO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Limpiar entorno anterior (si existe)

Write-Host "Limpiando entorno anterior (si existe)..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "[SIMULACIÓN] Se verificaría y limpiaría:" -ForegroundColor Magenta
    Write-Host "  - Usuarios: $UsuarioPrueba1, $UsuarioPrueba2" -ForegroundColor Gray
    Write-Host "  - Carpetas: C:\Users\testuser*, C:\Users\proyecto\testuser*" -ForegroundColor Gray
    Write-Host "  - Logs: C:\ScriptLogs\bajas*.log" -ForegroundColor Gray
} else {
    # Eliminar usuarios de prueba anteriores
    try {
        Get-ADUser -Identity $UsuarioPrueba1 -ErrorAction Stop | Out-Null
        Remove-ADUser -Identity $UsuarioPrueba1 -Confirm:$false
        Write-Host "  Usuario anterior eliminado: $UsuarioPrueba1" -ForegroundColor Gray
    } catch { }

    try {
        Get-ADUser -Identity $UsuarioPrueba2 -ErrorAction Stop | Out-Null
        Remove-ADUser -Identity $UsuarioPrueba2 -Confirm:$false
        Write-Host "  Usuario anterior eliminado: $UsuarioPrueba2" -ForegroundColor Gray
    } catch { }

    # Eliminar carpetas anteriores
    if (Test-Path "C:\Users\$UsuarioPrueba1") {
        Remove-Item "C:\Users\$UsuarioPrueba1" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "C:\Users\$UsuarioPrueba2") {
        Remove-Item "C:\Users\$UsuarioPrueba2" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "C:\Users\proyecto\$UsuarioPrueba1") {
        Remove-Item "C:\Users\proyecto\$UsuarioPrueba1" -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "C:\Users\proyecto\$UsuarioPrueba2") {
        Remove-Item "C:\Users\proyecto\$UsuarioPrueba2" -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Eliminar logs anteriores
    if (Test-Path "C:\ScriptLogs\bajas.log") {
        Remove-Item "C:\ScriptLogs\bajas.log" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "C:\ScriptLogs\bajaserror.log") {
        Remove-Item "C:\ScriptLogs\bajaserror.log" -Force -ErrorAction SilentlyContinue
    }

    Write-Host "✓ Entorno limpio" -ForegroundColor Green
}

Write-Host ""

# Paso 2: Crear usuarios de prueba en Active Directory

Write-Host "Creando usuarios de prueba en Active Directory..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[SIMULACIÓN] Se crearían los siguientes usuarios:" -ForegroundColor Magenta
    Write-Host "  New-ADUser -Name 'Test User 001' -SamAccountName '$UsuarioPrueba1' ..." -ForegroundColor Gray
    Write-Host "  New-ADUser -Name 'Test User 002' -SamAccountName '$UsuarioPrueba2' ..." -ForegroundColor Gray
} else {
    try {
        # Crear primer usuario de prueba
        New-ADUser -Name "Test User 001" `
                   -GivenName "Test" `
                   -Surname "User001" `
                   -SamAccountName $UsuarioPrueba1 `
                   -UserPrincipalName "$UsuarioPrueba1@$((Get-ADDomain).DNSRoot)" `
                   -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ErrorAction Stop
        
        Write-Host "  ✓ Usuario creado: $UsuarioPrueba1" -ForegroundColor Green
        
        # Crear segundo usuario de prueba
        New-ADUser -Name "Test User 002" `
                   -GivenName "Test" `
                   -Surname "User002" `
                   -SamAccountName $UsuarioPrueba2 `
                   -UserPrincipalName "$UsuarioPrueba2@$((Get-ADDomain).DNSRoot)" `
                   -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
                   -Enabled $true `
                   -ErrorAction Stop
        
        Write-Host "  ✓ Usuario creado: $UsuarioPrueba2" -ForegroundColor Green
        
    } catch {
        Write-Host "ERROR al crear usuarios: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "No se puede continuar sin usuarios de prueba." -ForegroundColor Yellow
        return
    }
}

Write-Host ""

# Paso 3: Crear estructura de carpetas y archivos

Write-Host "Creando estructura de carpetas y archivos..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[SIMULACIÓN] Se crearían:" -ForegroundColor Magenta
    Write-Host "  - C:\Users\$UsuarioPrueba1\trabajo\" -ForegroundColor Gray
    Write-Host "    → archivo1.txt, archivo2.txt, archivo3.txt" -ForegroundColor Gray
    Write-Host "  - C:\Users\$UsuarioPrueba2\trabajo\" -ForegroundColor Gray
    Write-Host "    → archivoA.txt, archivoB.txt" -ForegroundColor Gray
} else {
    try {
        # Crear carpeta personal del usuario 1
        New-Item -Path "C:\Users\$UsuarioPrueba1" -ItemType Directory -Force | Out-Null
        New-Item -Path "C:\Users\$UsuarioPrueba1\trabajo" -ItemType Directory -Force | Out-Null
        
        # Crear archivos en carpeta trabajo del usuario 1
        "Contenido archivo 1" | Out-File "C:\Users\$UsuarioPrueba1\trabajo\archivo1.txt"
        "Contenido archivo 2" | Out-File "C:\Users\$UsuarioPrueba1\trabajo\archivo2.txt"
        "Contenido archivo 3" | Out-File "C:\Users\$UsuarioPrueba1\trabajo\archivo3.txt"
        
        Write-Host "  ✓ Estructura creada para: $UsuarioPrueba1 (3 archivos)" -ForegroundColor Green
        
        # Crear carpeta personal del usuario 2
        New-Item -Path "C:\Users\$UsuarioPrueba2" -ItemType Directory -Force | Out-Null
        New-Item -Path "C:\Users\$UsuarioPrueba2\trabajo" -ItemType Directory -Force | Out-Null
        
        # Crear archivos en carpeta trabajo del usuario 2
        "Contenido archivo A" | Out-File "C:\Users\$UsuarioPrueba2\trabajo\archivoA.txt"
        "Contenido archivo B" | Out-File "C:\Users\$UsuarioPrueba2\trabajo\archivoB.txt"
        
        Write-Host "  ✓ Estructura creada para: $UsuarioPrueba2 (2 archivos)" -ForegroundColor Green
        
    } catch {
        Write-Host "ERROR al crear estructura: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
}

Write-Host ""

# Paso 4: Crear fichero de bajas de prueba

Write-Host "Creando fichero de bajas de prueba..." -ForegroundColor Cyan

$contenidoFichero = @"
Test:User:001:$UsuarioPrueba1
Test:User:002:$UsuarioPrueba2
NoExiste:Usuario:Falso:$UsuarioInexistente
"@

if ($DryRun) {
    Write-Host "[SIMULACIÓN] Se crearía fichero: $FicheroPruebas" -ForegroundColor Magenta
    Write-Host "  Contenido:" -ForegroundColor Gray
    Write-Host "    Test:User:001:$UsuarioPrueba1" -ForegroundColor Gray
    Write-Host "    Test:User:002:$UsuarioPrueba2" -ForegroundColor Gray
    Write-Host "    NoExiste:Usuario:Falso:$UsuarioInexistente" -ForegroundColor Gray
} else {
    $contenidoFichero | Out-File -FilePath $FicheroPruebas -Encoding UTF8 -Force

    Write-Host "  ✓ Fichero creado: $FicheroPruebas" -ForegroundColor Green
    Write-Host "  Contenido:" -ForegroundColor Gray
    Write-Host "    - $UsuarioPrueba1 (existe)" -ForegroundColor Gray
    Write-Host "    - $UsuarioPrueba2 (existe)" -ForegroundColor Gray
    Write-Host "    - $UsuarioInexistente (NO existe)" -ForegroundColor Gray
}

Write-Host ""

if ($DryRun) {
    Write-Host "✓ SIMULACIÓN: Entorno preparado" -ForegroundColor Magenta
} else {
    Write-Host "✓ Entorno de pruebas preparado correctamente" -ForegroundColor Green
}

Write-Host ""

# BLOQUE 6: EJECUTAR LAS 10 PRUEBAS

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FASE 2: EJECUTANDO PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[SIMULACIÓN] En modo real se ejecutarían las 10 pruebas:" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  1. Validación de parámetros obligatorios" -ForegroundColor Gray
    Write-Host "  2. Validación que el fichero existe" -ForegroundColor Gray
    Write-Host "  3. Verificación usuarios en Active Directory" -ForegroundColor Gray
    Write-Host "  4. Registro en bajaserror.log" -ForegroundColor Gray
    Write-Host "  5. Creación de carpetas destino" -ForegroundColor Gray
    Write-Host "  6. Movimiento de archivos" -ForegroundColor Gray
    Write-Host "  7. Cambio de propietario a Administrador" -ForegroundColor Gray
    Write-Host "  8. Registro en bajas.log con formato correcto" -ForegroundColor Gray
    Write-Host "  9. Eliminación de usuarios de Active Directory" -ForegroundColor Gray
    Write-Host "  10. Eliminación de directorios personales" -ForegroundColor Gray
    Write-Host ""
    Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
    Write-Host "  $RutaScript3 -FicheroBajas '$FicheroPruebas'" -ForegroundColor Gray
    Write-Host ""
    
    # En modo DryRun, simular nota perfecta
    $script:PruebasExitosas = 10
    $script:PruebasFalladas = 0
    
} else {

# PRUEBA 1: Validación de parámetros (sin parámetros)

Write-Host "PRUEBA 1: Validación de parámetros..." -ForegroundColor Cyan

try {
    # Ejecutar script sin parámetros y capturar salida
    $salida = & $RutaScript3 2>&1
    $salidaTexto = $salida | Out-String
    
    # Verificar que muestra error cuando falta el parámetro
    if ($salidaTexto -like "*ERROR*No se ha especificado*" -or $salidaTexto -like "*FicheroBajas*") {
        Registrar-Prueba -NumeroPrueba 1 -Descripcion "Valida parámetros obligatorios" `
                         -Exitosa $true -Mensaje ""
    } else {
        Registrar-Prueba -NumeroPrueba 1 -Descripcion "Valida parámetros obligatorios" `
                         -Exitosa $false -Mensaje "No muestra error cuando falta el parámetro"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 1 -Descripcion "Valida parámetros obligatorios" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 2: Validación de fichero existe

Write-Host "PRUEBA 2: Validación fichero existe..." -ForegroundColor Cyan

try {
    # Ejecutar con fichero que NO existe
    $salida = & $RutaScript3 -FicheroBajas "C:\fichero_que_no_existe.txt" 2>&1
    $salidaTexto = $salida | Out-String
    
    # Verificar que muestra error de fichero no encontrado
    if ($salidaTexto -like "*ERROR*no existe*" -or $salidaTexto -like "*Fichero*no*encontr*") {
        Registrar-Prueba -NumeroPrueba 2 -Descripcion "Valida que el fichero existe" `
                         -Exitosa $true -Mensaje ""
    } else {
        Registrar-Prueba -NumeroPrueba 2 -Descripcion "Valida que el fichero existe" `
                         -Exitosa $false -Mensaje "No detecta que el fichero no existe"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 2 -Descripcion "Valida que el fichero existe" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 3: Verificación de usuarios en Active Directory

Write-Host "PRUEBA 3: Verificación usuarios en AD..." -ForegroundColor Cyan

try {
    # Ejecutar el script con el fichero de pruebas
    $salida = & $RutaScript3 -FicheroBajas $FicheroPruebas 2>&1
    $salidaTexto = $salida | Out-String
    
    # Verificar que encuentra los usuarios que existen
    if ($salidaTexto -like "*Usuario encontrado*$UsuarioPrueba1*" -or 
        $salidaTexto -like "*$UsuarioPrueba1*encontrado*") {
        Registrar-Prueba -NumeroPrueba 3 -Descripcion "Verifica usuarios en Active Directory" `
                         -Exitosa $true -Mensaje ""
    } else {
        Registrar-Prueba -NumeroPrueba 3 -Descripcion "Verifica usuarios en Active Directory" `
                         -Exitosa $false -Mensaje "No verifica correctamente usuarios en AD"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 3 -Descripcion "Verifica usuarios en Active Directory" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 4: Registro en bajaserror.log

Write-Host "PRUEBA 4: Registro en bajaserror.log..." -ForegroundColor Cyan

try {
    Start-Sleep -Seconds 2  # Esperar a que se escriban los logs
    
    if (Test-Path "C:\ScriptLogs\bajaserror.log") {
        $contenidoLog = Get-Content "C:\ScriptLogs\bajaserror.log"
        
        # Verificar que el usuario inexistente está registrado
        if ($contenidoLog -like "*$UsuarioInexistente*ERROR*") {
            # Verificar formato: fecha-hora-login-nombre-apellidos-ERROR
            if ($contenidoLog -match "\d{2}/\d{2}/\d{4}-\d{2}:\d{2}:\d{2}-.*-.*-.*-ERROR:") {
                Registrar-Prueba -NumeroPrueba 4 -Descripcion "Registra errores en bajaserror.log" `
                                 -Exitosa $true -Mensaje ""
            } else {
                Registrar-Prueba -NumeroPrueba 4 -Descripcion "Registra errores en bajaserror.log" `
                                 -Exitosa $false -Mensaje "Formato de log incorrecto"
            }
        } else {
            Registrar-Prueba -NumeroPrueba 4 -Descripcion "Registra errores en bajaserror.log" `
                             -Exitosa $false -Mensaje "No registra usuario inexistente"
        }
    } else {
        Registrar-Prueba -NumeroPrueba 4 -Descripcion "Registra errores en bajaserror.log" `
                         -Exitosa $false -Mensaje "No se creó el archivo bajaserror.log"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 4 -Descripcion "Registra errores en bajaserror.log" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 5: Creación de carpeta destino

Write-Host "PRUEBA 5: Creación carpeta destino..." -ForegroundColor Cyan

try {
    # Verificar que se crearon las carpetas destino
    $carpeta1Existe = Test-Path "C:\Users\proyecto\$UsuarioPrueba1"
    $carpeta2Existe = Test-Path "C:\Users\proyecto\$UsuarioPrueba2"
    
    if ($carpeta1Existe -and $carpeta2Existe) {
        Registrar-Prueba -NumeroPrueba 5 -Descripcion "Crea carpetas destino correctamente" `
                         -Exitosa $true -Mensaje ""
    } else {
        $mensaje = "Faltan carpetas: "
        if (-not $carpeta1Existe) { $mensaje += "$UsuarioPrueba1 " }
        if (-not $carpeta2Existe) { $mensaje += "$UsuarioPrueba2 " }
        Registrar-Prueba -NumeroPrueba 5 -Descripcion "Crea carpetas destino correctamente" `
                         -Exitosa $false -Mensaje $mensaje
    }
} catch {
    Registrar-Prueba -NumeroPrueba 5 -Descripcion "Crea carpetas destino correctamente" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 6: Movimiento de archivos

Write-Host "PRUEBA 6: Movimiento de archivos..." -ForegroundColor Cyan

try {
    # Verificar que los archivos se movieron
    $archivosMovidos1 = Get-ChildItem "C:\Users\proyecto\$UsuarioPrueba1" -File -ErrorAction SilentlyContinue
    $archivosMovidos2 = Get-ChildItem "C:\Users\proyecto\$UsuarioPrueba2" -File -ErrorAction SilentlyContinue
    
    # Usuario 1 debería tener 3 archivos
    # Usuario 2 debería tener 2 archivos
    if ($archivosMovidos1.Count -eq 3 -and $archivosMovidos2.Count -eq 2) {
        Registrar-Prueba -NumeroPrueba 6 -Descripcion "Mueve archivos correctamente" `
                         -Exitosa $true -Mensaje ""
    } else {
        $mensaje = "Archivos movidos incorrectamente. "
        $mensaje += "Usuario1: $($archivosMovidos1.Count)/3, Usuario2: $($archivosMovidos2.Count)/2"
        Registrar-Prueba -NumeroPrueba 6 -Descripcion "Mueve archivos correctamente" `
                         -Exitosa $false -Mensaje $mensaje
    }
} catch {
    Registrar-Prueba -NumeroPrueba 6 -Descripcion "Mueve archivos correctamente" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 7: Cambio de propietario

Write-Host "PRUEBA 7: Cambio de propietario..." -ForegroundColor Cyan

try {
    # Verificar propietario de al menos un archivo
    if (Test-Path "C:\Users\proyecto\$UsuarioPrueba1\archivo1.txt") {
        $acl = Get-Acl "C:\Users\proyecto\$UsuarioPrueba1\archivo1.txt"
        $propietario = $acl.Owner
        
        if ($propietario -like "*Administrador*" -or $propietario -like "*Administrator*") {
            Registrar-Prueba -NumeroPrueba 7 -Descripcion "Cambia propietario a Administrador" `
                             -Exitosa $true -Mensaje ""
        } else {
            Registrar-Prueba -NumeroPrueba 7 -Descripcion "Cambia propietario a Administrador" `
                             -Exitosa $false -Mensaje "Propietario actual: $propietario"
        }
    } else {
        Registrar-Prueba -NumeroPrueba 7 -Descripcion "Cambia propietario a Administrador" `
                         -Exitosa $false -Mensaje "No se encontraron archivos para verificar"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 7 -Descripcion "Cambia propietario a Administrador" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 8: Registro en bajas.log

Write-Host "PRUEBA 8: Registro en bajas.log..." -ForegroundColor Cyan

try {
    if (Test-Path "C:\ScriptLogs\bajas.log") {
        $contenidoLog = Get-Content "C:\ScriptLogs\bajas.log" -Raw
        
        # Verificar que contiene información del usuario
        if ($contenidoLog -like "*$UsuarioPrueba1*") {
            # Verificar formato: debe tener listado numerado y total
            if ($contenidoLog -match "1:.*" -and $contenidoLog -match "Total de ficheros movidos:") {
                Registrar-Prueba -NumeroPrueba 8 -Descripcion "Registra bajas en bajas.log con formato correcto" `
                                 -Exitosa $true -Mensaje ""
            } else {
                Registrar-Prueba -NumeroPrueba 8 -Descripcion "Registra bajas en bajas.log con formato correcto" `
                                 -Exitosa $false -Mensaje "Formato de log incorrecto (falta numeración o total)"
            }
        } else {
            Registrar-Prueba -NumeroPrueba 8 -Descripcion "Registra bajas en bajas.log con formato correcto" `
                             -Exitosa $false -Mensaje "No se registró el usuario en bajas.log"
        }
    } else {
        Registrar-Prueba -NumeroPrueba 8 -Descripcion "Registra bajas en bajas.log con formato correcto" `
                         -Exitosa $false -Mensaje "No se creó el archivo bajas.log"
    }
} catch {
    Registrar-Prueba -NumeroPrueba 8 -Descripcion "Registra bajas en bajas.log con formato correcto" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 9: Eliminación de usuario de Active Directory

Write-Host "PRUEBA 9: Eliminación usuario de AD..." -ForegroundColor Cyan

try {
    # Verificar que los usuarios YA NO existen en AD
    $usuario1Eliminado = $false
    $usuario2Eliminado = $false
    
    try {
        Get-ADUser -Identity $UsuarioPrueba1 -ErrorAction Stop | Out-Null
        # Si llegamos aquí, el usuario AÚN existe (mal)
        $usuario1Eliminado = $false
    } catch {
        # Si da error, es porque NO existe (bien)
        $usuario1Eliminado = $true
    }
    
    try {
        Get-ADUser -Identity $UsuarioPrueba2 -ErrorAction Stop | Out-Null
        $usuario2Eliminado = $false
    } catch {
        $usuario2Eliminado = $true
    }
    
    if ($usuario1Eliminado -and $usuario2Eliminado) {
        Registrar-Prueba -NumeroPrueba 9 -Descripcion "Elimina usuarios de Active Directory" `
                         -Exitosa $true -Mensaje ""
    } else {
        $mensaje = "Usuarios no eliminados: "
        if (-not $usuario1Eliminado) { $mensaje += "$UsuarioPrueba1 " }
        if (-not $usuario2Eliminado) { $mensaje += "$UsuarioPrueba2 " }
        Registrar-Prueba -NumeroPrueba 9 -Descripcion "Elimina usuarios de Active Directory" `
                         -Exitosa $false -Mensaje $mensaje
    }
} catch {
    Registrar-Prueba -NumeroPrueba 9 -Descripcion "Elimina usuarios de Active Directory" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

# PRUEBA 10: Eliminación de directorios personales

Write-Host "PRUEBA 10: Eliminación directorios personales..." -ForegroundColor Cyan

try {
    # Verificar que los directorios personales fueron eliminados
    $dir1Eliminado = -not (Test-Path "C:\Users\$UsuarioPrueba1")
    $dir2Eliminado = -not (Test-Path "C:\Users\$UsuarioPrueba2")
    
    if ($dir1Eliminado -and $dir2Eliminado) {
        Registrar-Prueba -NumeroPrueba 10 -Descripcion "Elimina directorios personales" `
                         -Exitosa $true -Mensaje ""
    } else {
        $mensaje = "Directorios no eliminados: "
        if (-not $dir1Eliminado) { $mensaje += "C:\Users\$UsuarioPrueba1 " }
        if (-not $dir2Eliminado) { $mensaje += "C:\Users\$UsuarioPrueba2 " }
        Registrar-Prueba -NumeroPrueba 10 -Descripcion "Elimina directorios personales" `
                         -Exitosa $false -Mensaje $mensaje
    }
} catch {
    Registrar-Prueba -NumeroPrueba 10 -Descripcion "Elimina directorios personales" `
                     -Exitosa $false -Mensaje $_.Exception.Message
}

Write-Host ""

}  # FIN del bloque else (modo real)

# BLOQUE 7: CALCULAR NOTA Y MOSTRAR RESULTADOS

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FASE 3: RESULTADOS FINALES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Calcular nota final
$NotaFinal = $PruebasExitosas

if ($DryRun) {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║                                        ║" -ForegroundColor Magenta
    Write-Host "║   NOTA SIMULADA: $NotaFinal / 10          ║" -ForegroundColor Magenta
    Write-Host "║                                        ║" -ForegroundColor Magenta
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "[SIMULACIÓN] En modo real se ejecutarían todas las pruebas" -ForegroundColor Magenta
    Write-Host "y se calcularía la nota basándose en los resultados reales." -ForegroundColor Yellow
} else {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                        ║" -ForegroundColor Cyan
    Write-Host "║      NOTA FINAL: $NotaFinal / 10            ║" -ForegroundColor $(if ($NotaFinal -ge 5) { "Green" } else { "Red" })
    Write-Host "║                                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "RESUMEN:" -ForegroundColor Yellow
    Write-Host "  Pruebas aprobadas: $PruebasExitosas" -ForegroundColor Green
    Write-Host "  Pruebas falladas: $PruebasFalladas" -ForegroundColor Red
    Write-Host ""

    if ($Errores.Count -gt 0) {
        Write-Host "ERRORES DETECTADOS:" -ForegroundColor Red
        Write-Host ""
        foreach ($error in $Errores) {
            Write-Host " $error" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "¡EXCELENTE! No se detectaron errores." -ForegroundColor Green
        Write-Host ""
    }
}

# BLOQUE 8: LIMPIEZA FINAL

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FASE 4: LIMPIEZA FINAL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Limpiando entorno de pruebas..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "[SIMULACIÓN] Se eliminarían:" -ForegroundColor Magenta
    Write-Host "  - Usuarios: $UsuarioPrueba1, $UsuarioPrueba2" -ForegroundColor Gray
    Write-Host "  - Carpetas: C:\Users\testuser*, C:\Users\proyecto\testuser*" -ForegroundColor Gray
    Write-Host "  - Fichero: $FicheroPruebas" -ForegroundColor Gray
} else {
    # Eliminar usuarios de prueba (si aún existen)
    try {
        Get-ADUser -Identity $UsuarioPrueba1 -ErrorAction Stop | Out-Null
        Remove-ADUser -Identity $UsuarioPrueba1 -Confirm:$false
        Write-Host " Usuario eliminado: $UsuarioPrueba1" -ForegroundColor Gray
    } catch { }

    try {
        Get-ADUser -Identity $UsuarioPrueba2 -ErrorAction Stop | Out-Null
        Remove-ADUser -Identity $UsuarioPrueba2 -Confirm:$false
        Write-Host " Usuario eliminado: $UsuarioPrueba2" -ForegroundColor Gray
    } catch { }

    # Eliminar carpetas de prueba
    if (Test-Path "C:\Users\$UsuarioPrueba1") {
        Remove-Item "C:\Users\$UsuarioPrueba1" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " Carpeta eliminada: C:\Users\$UsuarioPrueba1" -ForegroundColor Gray
    }
    if (Test-Path "C:\Users\$UsuarioPrueba2") {
        Remove-Item "C:\Users\$UsuarioPrueba2" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " Carpeta eliminada: C:\Users\$UsuarioPrueba2" -ForegroundColor Gray
    }
    if (Test-Path "C:\Users\proyecto\$UsuarioPrueba1") {
        Remove-Item "C:\Users\proyecto\$UsuarioPrueba1" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " Carpeta eliminada: C:\Users\proyecto\$UsuarioPrueba1" -ForegroundColor Gray
    }
    if (Test-Path "C:\Users\proyecto\$UsuarioPrueba2") {
        Remove-Item "C:\Users\proyecto\$UsuarioPrueba2" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " Carpeta eliminada: C:\Users\proyecto\$UsuarioPrueba2" -ForegroundColor Gray
    }

    # Eliminar fichero de pruebas
    if (Test-Path $FicheroPruebas) {
        Remove-Item $FicheroPruebas -Force -ErrorAction SilentlyContinue
        Write-Host "Fichero eliminado: $FicheroPruebas" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Limpieza completada" -ForegroundColor Green
}

Write-Host ""

# FIN DEL SCRIPT

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  EVALUACIÓN FINALIZADA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
