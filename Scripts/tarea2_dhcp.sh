echo "----------------------------------------------"
echo "                DHCP Server"

if ! rpm -q dhcp-server >/dev/null 2>&1; then
    echo "[+] instalando DHCP Server"
    sudo dnf install dhcp-server -y >/dev/null 2>&1
else
    echo "[-] DHCP Server, Esta instalado"
fi

echo "Interfaces disponibles :"
ip -o link show | awk -F': ' '{ print $2 }'

IFACE="enp0s8"
IP_SERVER="192.168.100.10"
PREFIX="24"

CON_NAME=$(nmcli -t -f NAME,DEVICE con show --active | grep ":$IFACE" | cut -d: -f1)
nmcli con mod "$CON_NAME" ipv4.method manual ipv4.addresses $IP_SERVER/$PREFIX
nmcli con up "$CON_NAME"

# Nota: En versiones nuevas de Fedora/RHEL, este archivo puede no usarse,
# pero se mantiene según tu imagen:
sudo sed -i "s/^DHCPDARGS=.*/DHCPDARGS=\"$IFACE\"/" /etc/sysconfig/dhcpd

read -p "IP inicial del rango: " START_IP
read -p "IP final del rango: " END_IP
read -p "Gateway: " GATEWAY
read -p "DNS: " DNS
read -p "Tiempo de concesion (minutos): " LEASE_MIN

sudo tee /etc/dhcp/dhcpd.conf >/dev/null << EOF
default-lease-time $((LEASE_MIN*60));
max-lease-time $((LEASE_MIN*120));
authoritative;

subnet 192.168.100.0 netmask 255.255.255.0 {
    range $START_IP $END_IP;
    option routers $GATEWAY;
    option domain-name-servers $DNS;
}
EOF

sudo systemctl enable dhcpd
sudo systemctl restart dhcpd

echo "DHCP Configurado y funcionando"
