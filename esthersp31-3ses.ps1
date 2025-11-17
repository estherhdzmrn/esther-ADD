# Script: esthersp31-3ses.ps1
# Descripción: Muestra inicios de sesión entre dos fechas (excepto usuario SYSTEM)
# Uso: .\nombresp31-3ses.ps1 01/11/2024 09/11/2024

param(
    [string]$FechaInicio,
    [string]$FechaFin
)

# Verificar que se pasaron los dos parámetros
if (-not $FechaInicio -or -not $FechaFin) {
    Write-Host "Error: Debe proporcionar dos fechas"
    Write-Host "Uso: .\nombresp31-3ses.ps1 01/11/2024 09/11/2024"
    exit
}

# Convertir las cadenas de texto a objetos DateTime
try {
    $fechaIni = [DateTime]::Parse($FechaInicio)
    $fechaFin = [DateTime]::Parse($FechaFin).AddHours(23).AddMinutes(59).AddSeconds(59)
}
catch {
    Write-Host "Error: Formato de fecha incorrecto"
    Write-Host "Uso: .\nombresp31-3ses.ps1 01/11/2024 09/11/2024"
    exit
}

# Verificar que la fecha de inicio sea anterior a la fecha de fin
if ($fechaIni -gt $fechaFin) {
    Write-Host "Error: La fecha de inicio debe ser anterior a la fecha de fin"
    exit
}

Write-Host "Eventos de Inicio de Sesion:"

# Obtener eventos de inicio de sesión del log de seguridad
# EventID 4624 = Inicio de sesión exitoso
try {
    $eventos = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4624
        StartTime = $fechaIni
        EndTime = $fechaFin
    } -ErrorAction SilentlyContinue
    
    if ($eventos -eq $null -or $eventos.Count -eq 0) {
        Write-Host "No se encontraron inicios de sesión en el periodo especificado."
        exit
    }
    
    # Procesar los eventos y extraer información
    foreach ($evento in $eventos) {
        # Convertir el evento a XML para facilitar la extracción de datos
        $eventoXML = [xml]$evento.ToXml()
        
        # Extraer el nombre de usuario del evento
        $usuario = ($eventoXML.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
        $dominio = ($eventoXML.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetDomainName' }).'#text'
        
        # Filtrar el usuario SYSTEM y cuentas de sistema
        if ($usuario -ne "SYSTEM" -and $usuario -ne "" -and $usuario -notlike "*$") {
            $fecha = $evento.TimeCreated.ToString('MM/dd/yyyy HH:mm:ss')
            $usuarioCompleto = if ($dominio -and $dominio -ne "-") { "$dominio\$usuario" } else { $usuario }
            
            # Mostrar en el formato solicitado
            Write-Host "Fecha: $fecha - Usuario: $usuarioCompleto"
        }
    }
}
catch {
    Write-Host "Error al obtener los eventos de seguridad: $_"
    Write-Host ""
    Write-Host "Nota: Este script requiere permisos de administrador para acceder al log de seguridad."
}
