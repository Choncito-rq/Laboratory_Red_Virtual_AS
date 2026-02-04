Write-Host "===== DIAGNOSTICO DEL SISTEMA ====="

Write-Host "Nombre del equipo:"
hostname

Write-Host "`nDirecciones IP:"
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"}

Write-Host "`nEspacio en disco:"
Get-PSDrive C
