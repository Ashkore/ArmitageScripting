function print_info () {
    echo -e "\x1B[01;34m[*AITP*]\x1B[0m $1 \x1B[01;34m[*AITP*]\x1B[0m"
}
function print_error () {
    echo -e "\x1B[01;31m[-]\x1B[0m $1"
}
function armitage_interfaces () {
INTERFACES=$(ifconfig | awk '{print $1}' | grep : | sed 's/://')
[[ $INTERFACES ]] && 
if grep -q "tun" <<<$INTERFACES
then
	PRE=$(ifconfig | awk '{print $1}' | grep tun)
	IP_NIC=(${PRE//:/})
	print_info "Trying to setup Armitage Team Server on [$IP_NIC]."
	IP=$(ifconfig | grep $IP_NIC -A 1 |grep inet |awk '{print $2}')
elif grep -q "eth" <<<$INTERFACES
then
	PRE=$(ifconfig | awk '{print $1}' | grep eth)
	IP_NIC=(${PRE//:/})
	print_info "Trying to setup Armitage Team Server on \x1B[01;32m[$IP_NIC]\x1B[0m."
	IP=$(ifconfig | grep $IP_NIC -A 1 |grep inet |awk '{print $2}')
else
	echo "No [tun] or [eth] NIC's too set up Armitage Team Server on."
fi
}
############################################################
if [[ ! $1 ]]
then
print_error "Missing Iprange, format should be ./armitage.sh [password] [Iprange]"
print_error "EX: ./armitage.sh SuperSecretPassword 192.168.1.0/24"
exit 0
fi
if [[ ! $2 ]]
then
print_error "Missing Iprange, format should be ./armitage.sh [password] [Iprange]"
print_error "EX: ./armitage.sh SuperSecretPassword 192.168.1.0/24"
exit 0
else
	if grep -q "/" <<<$2
	then
		IPrng=$(echo ${2/'/'/'\/'})
	else
		IPrng=$2
	fi
echo $IPrng
fi
if [[ $(lsof -i:55553 | grep 55553) ]]
then
print_info "Killing anything running on port 55553"
kill -15 $(lsof -i:55553 | grep 55553 | awk '{print $2}')
fi
if [[ $(ps -A | grep $(pidof msfrpcd)) ]]
then
print_info "Killing msfrpcd"
kill -15 $(pidof msfrpcd)
sleep 5
fi
if ! [[ $(ps -A | grep postgres) ]]
then
service postgresql start
fi
armitage_interfaces
cd /usr/share/armitage
./teamserver $IP $1 > /dev/null 2>&1 &
echo $! > /root/armitage.pid
############################################################


sed -i '1 s/^.*$/$IPrange = "REPLACEME";/' /usr/share/armitage/main.cna
sed -i "1 s/REPLACEME/$IPrng/" /usr/share/armitage/main.cna
sleep 60
/root/CortanaStart.sh $1 
