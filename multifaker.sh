#!/bin/bash

# Title: Advanced DNS Configuration Tool for Kali Linux
# Author: Zatiel
# Purpose: Ethical use in controlled environments only

# banner
banner() {

printf "\e[1;94m     ███╗   ███╗██╗   ██╗██╗  ████████╗██╗███████╗ █████╗ ██╗  ██╗███████╗██████╗      \e[0m\n"
printf "\e[1;94m     ████╗ ████║██║   ██║██║  ╚══██╔══╝██║██╔════╝██╔══██╗██║ ██╔╝██╔════╝██╔══██╗      \e[0m\n"
printf "\e[1;94m     ██╔████╔██║██║   ██║██║     ██║   ██║█████╗  ███████║█████╔╝ █████╗  ██████╔╝      \e[0m\n"
printf "\e[1;94m     ██║╚██╔╝██║██║   ██║██║     ██║   ██║██╔══╝  ██╔══██║██╔═██╗ ██╔══╝  ██╔══██╗      \e[0m\n"
printf "\e[1;94m     ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██║     ██║  ██║██║  ██╗███████╗██║  ██║      \e[0m\n"
printf "\e[1;94m     ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝     \e[0m\n"
printf "\e[1;77m\e[45m   :: Kali DNS Tool :: github.com/callmezatiel  \e[0m\n"
    printf "\n"
}
banner
                                                                             

set -e  # Exit on any error

main() {
# 1. Backup original DNS configuration
backup_file="/etc/resolvconf/resolv.conf.d/head.backup.$(date +%s)"
cp /etc/resolvconf/resolv.conf.d/head "$backup_file"
echo "[+] Backup created at $backup_file"

# 2. Install necessary package if not installed
if ! command -v resolvconf &> /dev/null; then
    echo "[+] Installing resolvconf..."
if [ -f /usr/bin/apt ]; then
    apt install resolvconf -y
fi
if [ -f /usr/bin/dnf ]; then
    dnf install resolvconf -y
fi
if [ -f /usr/bin/pacman ]; then
    pacman -Sy resolvconf -noconfirm 
fi
fi

# 3. Enable and start the service
systemctl enable resolvconf.service
systemctl start resolvconf.service

# 4. Show menu to user for DNS options
echo -e "\nChoose a DNS provider:"
echo "1) Google (8.8.8.8, 8.8.4.4)"
echo "2) Cloudflare (1.1.1.1, 1.0.0.1)"
echo "3) OpenDNS (208.67.222.222, 208.67.220.220)"
echo "4) Quad9 (9.9.9.9, 149.112.112.112)"
echo "5) Custom"
echo "6) Restore original DNS"
read -p "Selection [1-6]: " choice

# 5. Clear current DNS settings
> /etc/resolvconf/resolv.conf.d/head

case $choice in
    1)
        echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head
        echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head
        ;;
    2)
        echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/head
        echo "nameserver 1.0.0.1" >> /etc/resolvconf/resolv.conf.d/head
        ;;
    3)
        echo "nameserver 208.67.222.222" >> /etc/resolvconf/resolv.conf.d/head
        echo "nameserver 208.67.220.220" >> /etc/resolvconf/resolv.conf.d/head
        ;;
    4)
        echo "nameserver 9.9.9.9" >> /etc/resolvconf/resolv.conf.d/head
        echo "nameserver 149.112.112.112" >> /etc/resolvconf/resolv.conf.d/head
        ;;
    5)
        read -p "Enter primary DNS: " custom1
        read -p "Enter secondary DNS: " custom2
        echo "nameserver $custom1" >> /etc/resolvconf/resolv.conf.d/head
        echo "nameserver $custom2" >> /etc/resolvconf/resolv.conf.d/head
        ;;
    6)
        cp "$backup_file" /etc/resolvconf/resolv.conf.d/head
        echo "[+] DNS settings restored from backup."
        ;;
    *)
        echo "[-] Invalid choice. Exiting."
        exit 1
        ;;
esac

# 6. Optionally add IPv6 DNS
read -p "Do you want to add IPv6 DNS? (y/n): " ipv6choice
if [[ "$ipv6choice" == "y" ]]; then
    echo "Adding common IPv6 DNS..."
    echo "nameserver 2001:4860:4860::8888" >> /etc/resolvconf/resolv.conf.d/head
    echo "nameserver 2606:4700:4700::1111" >> /etc/resolvconf/resolv.conf.d/head
fi

# 7. Restart service to apply DNS changes
systemctl restart resolvconf.service

# 8. Flush DNS (Linux systems often use `systemd-resolve` or `nscd`)
if command -v systemd-resolve &> /dev/null; then
    systemd-resolve --flush-caches
    echo "[+] DNS cache flushed with systemd-resolve."
elif command -v resolvectl &> /dev/null; then
    resolvectl flush-caches
    echo "[+] DNS cache flushed with resolvectl."
elif command -v nscd &> /dev/null; then
    service nscd restart
    echo "[+] DNS cache flushed with nscd."
else
    echo "[!] Could not determine DNS cache flush method. Please restart your network manually if needed."
fi

# 9. Optional: NetworkManager compatibility
if systemctl is-active NetworkManager &> /dev/null; then
    nmcli networking off && nmcli networking on
    echo "[+] NetworkManager restarted."
fi

# 10. Logging the change
log_file="/var/log/dns_change_$(date +%Y%m%d_%H%M%S).log"
echo "DNS changed by script at $(date)" > "$log_file"
cat /etc/resolvconf/resolv.conf.d/head >> "$log_file"
echo "[+] DNS changes logged at $log_file"

echo -e "\n[✓] DNS configuration completed successfully."
}
# check if user its root
if [[ $EUID -eq 0 ]]; then
main
else
echo "[!] You must run as root!"
fi