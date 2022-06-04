#!/bin/sh
#Rev 1.0
#June 1, 2022
#Tested on pfsense 2.6.0-RELEASE
#
#jtbright
#user defined variables, edit these before running the script.
#refer to the wireguard documentation for additional information on these values
###############################################################

network="10.17.1."
dns="10.16.1.1, 8.8.8.8"
allowed="0.0.0.0/0"
vpnserver="firewall.hostname.here:51820"
tunnel="tun_wg0"
outdir="/tmp/"

#shouldn't have to touch these, this isn't the wild west of like linux distros....  but just incase
wg="/usr/local/bin/wg"
touch="/usr/bin/touch"
chmod="/bin/chmod"
cat="/bin/cat"
#
###############################################################


privkey="$($wg genkey)"
pubkey="$(echo $privkey | $wg pubkey)"
presharedkey="$($wg genpsk)"
address="$network$lastquad"
clear
read -p "Enter the file name for output, .conf automatically appended: " filename
read -p "Enter the last octet of the client static IP: " lastquad
clear
fullfile="$outdir$filename.conf"
$touch $fullfile
$chmod 700 $fullfile


echo "[Interface]" >$fullfile
echo "PrivateKey = "$privkey >>$fullfile
echo "Address = "$network$lastquad/32 >>$fullfile
echo "DNS = "$dns >>$fullfile
echo >>$fullfile
echo "[Peer]" >>$fullfile
echo "PublicKey = "$($wg show $tunnel public-key) >>$fullfile
echo "PresharedKey = "$presharedkey >>$fullfile
echo "AllowedIPs = "$allowed >>$fullfile
echo "Endpoint = "$vpnserver >>$fullfile

echo "For the firewall administrator."
echo "Use the following values to add the new peer in the PfSense WG configuration page."
echo "###############################################################"
echo "Description: "$filename
echo "Public Key: "$pubkey
echo "Preshared Key: "$presharedkey
echo "Allowed IPs: "$network$lastquad/32
echo "###############################################################"
echo
echo "For the remote access user."
echo "Configuration file can be found at "$fullfile
echo "And displayed here:"
echo
echo "###############################################################"
$cat $fullfile

#If you want to install qrencode on a remote linux machine here is an example on how to generate the mobile png file, adjust as needed
#$cat $fullfile | ssh user@remoteserver qrencode -o - >$outdir$filename.png
