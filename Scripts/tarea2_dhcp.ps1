echo "----------------------------------------------------"
echo "                DHCP Server"

if (-not (Get-WindowsFeature -Name DHCP | Where-Object {$_.Installed})) {
    echo "[+] Instalando rol DHCP Server"
    Install-WindowsFeature -Name DHCP -IncludeManagementTools -Verbose
    echo "[-] DHCP se instalo correctamente"
} else {
    echo "[-] DHCP Server esta instalado"
}

$ScopeName = Read-Host "Nombre del Scope"
$StartIP = Read-Host "IP inicial del rango"
$EndIP = Read-Host "IP final del rango"
$Subnet = "255.255.255.0"
$Gateway = Read-Host "Puerta de enlace"
$DNS = Read-Host "DNS del servidor"
$LeaseMin = Read-Host "Tiempo del servidor"

if (-not (Get-DhcpServer4Scope | Where-Object {$_.Name -eq $ScopeName})) {
    Add-DhcpServer4Scope -Name $ScopeName -StartRange $StartIP -EndRange $EndIP -SubnetMask $Subnet -State Active
    echo "[+] Scope '$ScopeName' creado."
} else {
    echo "[-] Scope '$ScopeName' ya existe."
}

$ScopeId = "192.168.100.0"

Set-DhcpServerv4OptionValue -ScopeId $ScopeId -Router $Gateway -DnsServer $DNS

echo "[+] Tiempo de concesion configurado a $LeaseMin minutos."

Start-Service -Name DHCPServer
Set-Service -Name DHCPServer -StartupType Automatic
echo "[+] Servicio DHCP iniciado."

echo "----------------------------------------------------"
