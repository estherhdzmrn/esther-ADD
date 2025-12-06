param(
    # Parámetro obligatorio: ruta completa del fichero de bajas
    # Ejemplo: .\esther-adam03.ps1 -FicheroBajas "C:\temp\bajas.txt"
    [Parameter(Mandatory=$false)]
    [string]$FicheroBajas,
    
    # Parámetro opcional: modo simulación (no ejecuta cambios reales)
    # Ejemplo: .\esther-adam03.ps1 -FicheroBajas "C:\temp\bajas.txt" -DryRun
    [switch]$DryRun
)

# BLOQUE 2: CONFIGURACIÓN DE RUTAS Y VARIABLES GLOBALES

# Definimos las rutas de los archivos de log donde se registrarán las operaciones

# Carpeta donde se guardarán los logs (más accesible y sin problemas de permisos)
$CarpetaLogs = "C:\ScriptLogs"

# Verificar si la carpeta de logs existe, si no, crearla
if (-not (Test-Path $CarpetaLogs)) {
    try {
        New-Item -Path $CarpetaLogs -ItemType Directory -Force | Out-Null
    } catch {
        # Si no se puede crear en C:\, intentar en directorio del usuario
        $CarpetaLogs = "$env:USERPROFILE\ScriptLogs"
        New-Item -Path $CarpetaLogs -ItemType Directory -Force | Out-Null
    }
}

# Ruta del log de errores (usuarios que no existen)
$LogErrores = Join-Path $CarpetaLogs "bajaserror.log"

# Ruta del log de bajas exitosas
$LogBajas = Join-Path $CarpetaLogs "bajas.log"

# Carpeta base donde se moverán los archivos de los usuarios
$CarpetaProyecto = "C:\Users\proyecto"

# Nombre del directorio de trabajo dentro del perfil del usuario
$NombreDirectorioTrabajo = "trabajo"

# BLOQUE 3: MOSTRAR INFORMACIÓN INICIAL

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SCRIPT DE BAJAS - esther-adam03.ps1  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Mostrar modo de ejecución
if ($DryRun) {
    Write-Host "MODO: SIMULACIÓN (DRY-RUN)" -ForegroundColor Magenta
    Write-Host "No se realizarán cambios reales en el sistema." -ForegroundColor Yellow
} else {
    Write-Host "MODO: EJECUCIÓN REAL" -ForegroundColor Green
    Write-Host "Se aplicarán cambios permanentes en Active Directory." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Carpeta de logs: $CarpetaLogs" -ForegroundColor Cyan
Write-Host ""

# BLOQUE 4: VALIDACIÓN DEL PARÁMETRO

# Verificamos que el usuario haya pasado el parámetro del fichero

if (-not $FicheroBajas) {
    # No se pasó ningún parámetro
    Write-Host "ERROR: No se ha especificado el fichero de bajas." -ForegroundColor Red
    Write-Host "Uso correcto: .\esther-adam03.ps1 -FicheroBajas 'ruta\al\fichero.txt' [-DryRun]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "EJEMPLOS:" -ForegroundColor Cyan
    Write-Host "  Modo REAL:       .\esther-adam03.ps1 -FicheroBajas 'C:\temp\bajas.txt'" -ForegroundColor White
    Write-Host "  Modo SIMULACIÓN: .\esther-adam03.ps1 -FicheroBajas 'C:\temp\bajas.txt' -DryRun" -ForegroundColor White
    Write-Host ""
    return
}

Write-Host "Fichero de bajas especificado: $FicheroBajas" -ForegroundColor Cyan
Write-Host ""

# BLOQUE 5: VALIDACIÓN DE EXISTENCIA DEL FICHERO

# Verificamos que el fichero realmente exista en el sistema

if (-not (Test-Path $FicheroBajas)) {
    # El fichero no existe
    Write-Host "ERROR: El fichero '$FicheroBajas' no existe." -ForegroundColor Red
    Write-Host "Verifica la ruta e intenta nuevamente." -ForegroundColor Yellow
    Write-Host ""
    return
}

Write-Host " Fichero encontrado correctamente." -ForegroundColor Green
Write-Host ""

# BLOQUE 6: VALIDACIÓN DE QUE ES UN FICHERO (NO UN DIRECTORIO)

# Comprobamos que la ruta apunta a un fichero y no a una carpeta

if (-not (Test-Path $FicheroBajas -PathType Leaf)) {
    # La ruta existe pero es una carpeta, no un fichero
    Write-Host "ERROR: La ruta '$FicheroBajas' no es un fichero." -ForegroundColor Red
    Write-Host "Debes proporcionar la ruta a un archivo de texto." -ForegroundColor Yellow
    Write-Host ""
    return
}

Write-Host " La ruta corresponde a un fichero válido." -ForegroundColor Green
Write-Host ""

# BLOQUE 7: CREAR CARPETA DE PROYECTO SI NO EXISTE

# Verificamos que exista la carpeta donde se moverán los archivos

if (-not (Test-Path $CarpetaProyecto)) {
    Write-Host "La carpeta '$CarpetaProyecto' no existe." -ForegroundColor Yellow
    
    if ($DryRun) {
        Write-Host "[SIMULACIÓN] Se crearía la carpeta: $CarpetaProyecto" -ForegroundColor Magenta
    } else {
        Write-Host "Creándola..." -ForegroundColor Yellow
        try {
            New-Item -Path $CarpetaProyecto -ItemType Directory -Force | Out-Null
            Write-Host " Carpeta creada correctamente." -ForegroundColor Green
        } catch {
            Write-Host "ERROR: No se pudo crear la carpeta: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }
    Write-Host ""
}

# BLOQUE 8: LEER EL FICHERO DE BAJAS

# Leemos todas las líneas del fichero en un array

Write-Host "Leyendo fichero de bajas..." -ForegroundColor Cyan
Write-Host ""

try {
    # Get-Content lee el fichero línea por línea y lo guarda en un array
    $lineas = Get-Content -Path $FicheroBajas -ErrorAction Stop
    
    Write-Host " Fichero leído correctamente." -ForegroundColor Green
    Write-Host "Total de líneas encontradas: $($lineas.Count)" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "ERROR al leer el fichero: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    return
}

# BLOQUE 9: PROCESAR CADA LÍNEA DEL FICHERO

# Recorremos cada línea del fichero para procesar cada usuario

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INICIANDO PROCESO DE BAJAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Contador para estadísticas
$totalProcesados = 0
$totalExitosos = 0
$totalErrores = 0

foreach ($linea in $lineas) {
    
    # Incrementar contador
    $totalProcesados++
    
    # Mostrar qué línea estamos procesando
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host "Procesando línea $totalProcesados de $($lineas.Count)" -ForegroundColor Cyan
    Write-Host "Contenido: $linea" -ForegroundColor White
    Write-Host ""
    
    # PASO 1: EXTRAER DATOS DE LA LÍNEA

    # Formato esperado: nombre:apellido1:apellido2:login
    # Usamos Split para separar por ":" y obtener cada campo
    
    $campos = $linea -split ":"
    
    # Validar que la línea tenga exactamente 4 campos
    if ($campos.Count -ne 4) {
        Write-Host "ERROR: Formato incorrecto en la línea." -ForegroundColor Red
        Write-Host "Se esperaba: nombre:apellido1:apellido2:login" -ForegroundColor Yellow
        Write-Host ""
        
        # Registro de error de formato
        if (-not $DryRun) {
            $fechaHora = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
            $mensajeError = "$fechaHora-FORMATO_INVALIDO-$linea-ERROR:Formato incorrecto (se esperaban 4 campos)"
            Add-Content -Path $LogErrores -Value $mensajeError
        } else {
            Write-Host "[SIMULACIÓN] Se registraría error de formato en: $LogErrores" -ForegroundColor Magenta
        }
        
        $totalErrores++
        continue  # Saltar a la siguiente línea
    }
    
    # Extraer cada campo
    $nombre = $campos[0].Trim()
    $apellido1 = $campos[1].Trim()
    $apellido2 = $campos[2].Trim()
    $login = $campos[3].Trim()
    
    Write-Host "Datos extraídos:" -ForegroundColor Cyan
    Write-Host "  Nombre: $nombre" -ForegroundColor White
    Write-Host "  Apellido1: $apellido1" -ForegroundColor White
    Write-Host "  Apellido2: $apellido2" -ForegroundColor White
    Write-Host "  Login: $login" -ForegroundColor White
    Write-Host ""
    
    # PASO 2: VERIFICAR SI EL USUARIO EXISTE EN ACTIVE DIRECTORY
    
    Write-Host "Verificando si el usuario '$login' existe..." -ForegroundColor Cyan
    
    try {
        # Intentar obtener el usuario de Active Directory
        $usuario = Get-ADUser -Identity $login -ErrorAction Stop
        
        # Si llegamos aquí, el usuario SÍ existe
        Write-Host " Usuario encontrado en Active Directory." -ForegroundColor Green
        Write-Host ""
        
    } catch {
        # El usuario NO existe
        Write-Host " ERROR: El usuario '$login' NO EXISTE en Active Directory." -ForegroundColor Red
        Write-Host ""
        
        # Registro en log de errores
        # Formato: fecha-hora-login-nombre-apellidos-motivo_de_error
        $fechaHora = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
        $nombreCompleto = "$nombre-$apellido1-$apellido2"
        $mensajeError = "$fechaHora-$login-$nombreCompleto-ERROR:login no existe en el sistema"
        
        if ($DryRun) {
            Write-Host "[SIMULACIÓN] Se registraría en ${LogErrores}:" -ForegroundColor Magenta
            Write-Host "  $mensajeError" -ForegroundColor Gray
        } else {
            # Escribir en el archivo de log de errores
            Add-Content -Path $LogErrores -Value $mensajeError
            Write-Host "Registrado en: $LogErrores" -ForegroundColor Yellow
        }
        Write-Host ""
        
        $totalErrores++
        continue  # Saltar al siguiente usuario
    }
    
    # PASO 3: OBTENER RUTA DEL DIRECTORIO PERSONAL DEL USUARIO
    
    # Construir la ruta del directorio personal
    # Normalmente: C:\Users\[login]
    $directorioPersonal = "C:\Users\$login"
    
    Write-Host "Directorio personal del usuario: $directorioPersonal" -ForegroundColor Cyan
    
    # Verificar que el directorio personal exista
    if (-not (Test-Path $directorioPersonal)) {
        Write-Host "ADVERTENCIA: El directorio personal no existe: $directorioPersonal" -ForegroundColor Yellow
        Write-Host "Se continuará con la eliminación del usuario de AD." -ForegroundColor Yellow
        Write-Host ""
    }
 
    # PASO 4: CREAR CARPETA DESTINO PARA LOS ARCHIVOS
 
    
    # Carpeta destino: C:\Users\proyecto\[login]
    $carpetaDestino = Join-Path $CarpetaProyecto $login
    
    Write-Host "Carpeta destino: $carpetaDestino" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "[SIMULACIÓN] Se crearía/verificaría la carpeta destino" -ForegroundColor Magenta
        Write-Host ""
    } else {
        Write-Host "Creando carpeta destino..." -ForegroundColor Cyan
        try {
            # Crear la carpeta (si ya existe, -Force no da error)
            New-Item -Path $carpetaDestino -ItemType Directory -Force | Out-Null
            Write-Host " Carpeta destino creada/verificada." -ForegroundColor Green
            Write-Host ""
        } catch {
            Write-Host "ERROR al crear carpeta destino: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            
            # Registrar error
            $fechaHora = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
            $nombreCompleto = "$nombre-$apellido1-$apellido2"
            $mensajeError = "$fechaHora-$login-$nombreCompleto-ERROR:No se pudo crear carpeta destino"
            Add-Content -Path $LogErrores -Value $mensajeError
            
            $totalErrores++
            continue
        }
    }

    # PASO 5: MOVER ARCHIVOS DEL DIRECTORIO TRABAJO
    
    # Ruta completa del directorio trabajo: C:\Users\[login]\trabajo
    $directorioTrabajo = Join-Path $directorioPersonal $NombreDirectorioTrabajo
    
    Write-Host "Buscando archivos en: $directorioTrabajo" -ForegroundColor Cyan
    
    # Variable para almacenar la lista de archivos movidos
    $archivosMovidos = @()
    
    if (Test-Path $directorioTrabajo) {
        
        # Obtener todos los archivos (no subcarpetas) del directorio trabajo
        $archivos = Get-ChildItem -Path $directorioTrabajo -File -ErrorAction SilentlyContinue
        
        if ($archivos.Count -gt 0) {
            
            Write-Host "Se encontraron $($archivos.Count) archivo(s) para mover." -ForegroundColor Green
            Write-Host ""
            
            if ($DryRun) {
                # Modo simulación: solo mostrar qué se movería
                Write-Host "[SIMULACIÓN] Se moverían los siguientes archivos:" -ForegroundColor Magenta
                foreach ($archivo in $archivos) {
                    Write-Host "  → $($archivo.Name) → $carpetaDestino" -ForegroundColor Gray
                    $archivosMovidos += $archivo.Name
                }
                Write-Host ""
                
            } else {
                # Modo real: mover cada archivo
                foreach ($archivo in $archivos) {
                    
                    try {
                        # Ruta destino del archivo
                        $destinoArchivo = Join-Path $carpetaDestino $archivo.Name
                        
                        # Mover el archivo
                        Move-Item -Path $archivo.FullName -Destination $destinoArchivo -Force
                        
                        Write-Host "   Movido: $($archivo.Name)" -ForegroundColor Green
                        
                        # Añadir a la lista de archivos movidos
                        $archivosMovidos += $archivo.Name
                        
                    } catch {
                        Write-Host "   Error al mover: $($archivo.Name)" -ForegroundColor Red
                        Write-Host "    Motivo: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                }
                
                Write-Host ""
            }
            
        } else {
            Write-Host "No se encontraron archivos en el directorio trabajo." -ForegroundColor Yellow
            Write-Host ""
        }
        
    } else {
        Write-Host "El directorio trabajo no existe: $directorioTrabajo" -ForegroundColor Yellow
        Write-Host ""
    }

    # PASO 6: CAMBIAR PROPIETARIO DE LOS ARCHIVOS AL ADMINISTRADOR

    # Implementación DryRun
    
    if ($archivosMovidos.Count -gt 0) {
        
        Write-Host "Cambiando propietario de archivos al Administrador..." -ForegroundColor Cyan
        
        if ($DryRun) {
            Write-Host "[SIMULACIÓN] Se cambiaría el propietario de $($archivosMovidos.Count) archivo(s):" -ForegroundColor Magenta
            foreach ($nombreArchivo in $archivosMovidos) {
                Write-Host "  → $nombreArchivo (propietario: Administrador)" -ForegroundColor Gray
            }
            Write-Host ""
            
        } else {
            # Modo real: cambiar propietario
            foreach ($nombreArchivo in $archivosMovidos) {
                
                try {
                    $rutaArchivo = Join-Path $carpetaDestino $nombreArchivo
                    
                    # Obtener el objeto ACL (Access Control List) del archivo
                    $acl = Get-Acl -Path $rutaArchivo
                    
                    # Crear un objeto de propietario (Administrador)
                    $administrador = New-Object System.Security.Principal.NTAccount("Administrador")
                    
                    # Establecer el nuevo propietario
                    $acl.SetOwner($administrador)
                    
                    # Aplicar los cambios
                    Set-Acl -Path $rutaArchivo -AclObject $acl
                    
                    Write-Host "   Propietario cambiado: $nombreArchivo" -ForegroundColor Green
                    
                } catch {
                    Write-Host "   Error al cambiar propietario de: $nombreArchivo" -ForegroundColor Red
                    Write-Host "    Motivo: $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
            
            Write-Host ""
        }
    }

    # PASO 7: REGISTRAR EN EL LOG DE BAJAS EXITOSAS
    
    Write-Host "Registrando operación en log de bajas..." -ForegroundColor Cyan
    
    # Obtener fecha y hora actual
    $fechaHora = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
    
    # Crear el contenido del log
    $logContent = @()
    $logContent += "$fechaHora-$login-$carpetaDestino"
    
    if ($archivosMovidos.Count -gt 0) {
        # Listar archivos movidos numerados
        for ($i = 0; $i -lt $archivosMovidos.Count; $i++) {
            $logContent += "$($i + 1):$($archivosMovidos[$i])"
        }
        $logContent += "Total de ficheros movidos: $($archivosMovidos.Count)"
    } else {
        $logContent += "Total de ficheros movidos: 0"
    }
    
    if ($DryRun) {
        Write-Host "[SIMULACIÓN] Se registraría en ${LogBajas}:" -ForegroundColor Magenta
        foreach ($linea in $logContent) {
            Write-Host "  $linea" -ForegroundColor Gray
        }
        Write-Host ""
    } else {
        # Escribir en el archivo de log
        $logContent | ForEach-Object { Add-Content -Path $LogBajas -Value $_ }
        Write-Host "✓ Operación registrada en: $LogBajas" -ForegroundColor Green
        Write-Host ""
    }
    
    # PASO 8: ELIMINAR USUARIO DE ACTIVE DIRECTORY

    # Implementación DryRun
    
    Write-Host "Eliminando usuario '$login' de Active Directory..." -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
        Write-Host "  Remove-ADUser -Identity '$login' -Confirm:`$false" -ForegroundColor Gray
        Write-Host ""
        
    } else {
        # Modo real: eliminar usuario
        try {
            # Eliminar el usuario
            Remove-ADUser -Identity $usuario -Confirm:$false -ErrorAction Stop
            
            Write-Host " Usuario eliminado correctamente de AD." -ForegroundColor Green
            Write-Host ""
            
        } catch {
            Write-Host "ERROR al eliminar usuario: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            
            # Registrar error
            $fechaHora = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
            $nombreCompleto = "$nombre-$apellido1-$apellido2"
            $mensajeError = "$fechaHora-$login-$nombreCompleto-ERROR:No se pudo eliminar de AD"
            Add-Content -Path $LogErrores -Value $mensajeError
            
            $totalErrores++
            continue
        }
    }

    # PASO 9: ELIMINAR DIRECTORIO PERSONAL DEL USUARIO

    # Implementación DryRun
    
    if (Test-Path $directorioPersonal) {
        
        Write-Host "Eliminando directorio personal: $directorioPersonal" -ForegroundColor Cyan
        
        if ($DryRun) {
            Write-Host "[SIMULACIÓN] Se ejecutaría:" -ForegroundColor Magenta
            Write-Host "  Remove-Item -Path '$directorioPersonal' -Recurse -Force" -ForegroundColor Gray
            Write-Host ""
            
        } else {
            # Modo real: eliminar directorio
            try {
                # Eliminar todo el directorio y su contenido
                Remove-Item -Path $directorioPersonal -Recurse -Force -ErrorAction Stop
                
                Write-Host " Directorio personal eliminado." -ForegroundColor Green
                Write-Host ""
                
            } catch {
                Write-Host "ERROR al eliminar directorio: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "El usuario fue eliminado de AD pero su directorio persiste." -ForegroundColor Yellow
                Write-Host ""
            }
        }
    }

    # FIN DEL PROCESAMIENTO DE ESTE USUARIO
    
    if ($DryRun) {
        Write-Host " SIMULACIÓN COMPLETADA: $login" -ForegroundColor Magenta
    } else {
        Write-Host " BAJA COMPLETADA: $login" -ForegroundColor Green
    }
    Write-Host ""
    
    $totalExitosos++
}
# Fin del bucle foreach]

# BLOQUE 10: RESUMEN FINAL


Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PROCESO DE BAJAS FINALIZADO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "MODO: SIMULACIÓN (sin cambios reales)" -ForegroundColor Magenta
    Write-Host ""
}

Write-Host "ESTADÍSTICAS:" -ForegroundColor Yellow
Write-Host "  Total procesados: $totalProcesados" -ForegroundColor White
Write-Host "  Bajas exitosas: $totalExitosos" -ForegroundColor Green
Write-Host "  Errores: $totalErrores" -ForegroundColor Red
Write-Host ""
Write-Host "ARCHIVOS DE LOG:" -ForegroundColor Yellow
Write-Host "  Bajas exitosas: $LogBajas" -ForegroundColor Cyan
Write-Host "  Errores: $LogErrores" -ForegroundColor Cyan
Write-Host ""
Write-Host "UBICACIONES:" -ForegroundColor Yellow
Write-Host "  Carpeta de proyecto: $CarpetaProyecto" -ForegroundColor Cyan
Write-Host "  Carpeta de logs: $CarpetaLogs" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
