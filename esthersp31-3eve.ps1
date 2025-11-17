# Script: esthersp31-3eve.ps1
# Descripción: Menú para mostrar los últimos 12 registros de cada tipo de log de eventos
Clear-Host
do {

    Write-Host "MENU DE REGISTROS DE EVENTOS"
    Write-Host ""
    
    # Obtener todos los logs de eventos disponibles en el sistema
    $logs = Get-EventLog -List | Where-Object { $_.Entries.Count -gt 0 }
    
    # Mostrar cada log con su número
    $contador = 1
    foreach ($log in $logs) {
        Write-Host "$contador. $($log.Log) - $($log.Entries.Count) eventos"
        $contador++
    }
    
    Write-Host "0. Salir"
    Write-Host ""
    
    $opcion = Read-Host "Seleccione una opción"
    
    # Si NO es 0, procesar la opción
    if ($opcion -ne '0') {
        # Convertir opción a número
        $numeroOpcion = 0
        if ([int]::TryParse($opcion, [ref]$numeroOpcion)) {
            # Verificar que la opción sea válida
            if ($numeroOpcion -ge 1 -and $numeroOpcion -le $logs.Count) {
                # Obtener el log seleccionado
                $logSeleccionado = $logs[$numeroOpcion - 1]
                
                Write-Host ""
                Write-Host "ULTIMOS 12 REGISTROS DE: $($logSeleccionado.Log)"
                Write-Host ""
                
                try {
                    # Mostrar los últimos 12 registros del log seleccionado
                    Get-EventLog -LogName $logSeleccionado.Log -Newest 12 |
                        Select-Object TimeGenerated, EntryType, Source, EventID, Message |
                        Format-Table -AutoSize -Wrap
                    
                    Write-Host "Total de registros mostrados: 12 (de $($logSeleccionado.Entries.Count) disponibles)"
                }
                catch {
                    Write-Host "Error al obtener los registros: $_"
                }
                
                Write-Host ""
                Read-Host "Presione Enter para continuar"
            }
            else {
                Write-Host ""
                Write-Host "Opción no válida. Seleccione un número entre 1 y $($logs.Count), o 0 para salir."
                Start-Sleep -Seconds 2
            }
        }
        else {
            Write-Host ""
            Write-Host "Opción no válida. Debe ingresar un número."
            Start-Sleep -Seconds 2
        }
    }
    
} while ($opcion -ne '0')

Write-Host ""
Write-Host "Saliendo del programa..."
Start-Sleep -Seconds 1
