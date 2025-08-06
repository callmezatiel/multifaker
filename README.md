# Multifaker 

DNS Change Script

## TOP 10 Features Added:

1.- Backup existing DNS config

2.- Interactive menu to choose DNS providers

3.- Automatic detection of active network interface

4.- Option to restore the original DNS

5.- Logs for changes

6.- DNS flush after changes

7.- IPv6 DNS support

8.- User input for custom DNS

9.- NetworkManager compatibility

10.- Error handling and status output

## Requirements
- Kali Linux / Parrot Security OS

apt install resolvconf -y
systemctl enable resolvconf.service
systemctl start resolvconf.service

## How Each Feature Works


| Feature | Description |
| ------ | ------ |
| Backup | Creates a timestamped backup of current DNS for safety. |
| Interactive Menu |	Lets user pick from top DNS providers or enter custom DNS. |
| DNS Providers	| Offers Google, Cloudflare, OpenDNS, Quad9 – known for speed/security. |
| Custom DNS	| Allows user input for flexibility. |
| IPv6 Support	| Adds modern DNS over IPv6 for compatibility. |
| Restore Option	| Can undo all changes using the backup file. |
| DNS Flush	| Clears cache so changes apply immediately. |
| NetworkManager Restart | Ensures GUI network tools reflect DNS change. |
| Logging	| Tracks changes for audit or rollback. |
| Error Handling | Exits if anything goes wrong to avoid misconfigurations. |

## Installation

```
# Enter In Super User
sudo su

# Clone Repository
git clone http://github.com/callmezatiel/multifaker

# Enter The Container Folder
cd multifaker

# Add Execute Permissions
chmod +x multifaker.sh

# Add The Script To The Binaries For Use By The System
sudo mv multifaker.sh /bin 

```

# Run

## Open New Terminal and type:

```
sudo multifaker.sh
```
