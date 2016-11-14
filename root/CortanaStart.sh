function print_info () {
    echo -e "\x1B[01;34m[*AITP*]\x1B[0m $1 \x1B[01;34m[*AITP*]\x1B[0m"
}
function print_error () {
    echo -e "\x1B[01;31m[*AITP*]\x1B[0m $1 \x1B[01;31m[*AITP*]\x1B[0m"
}
function armitage_interfaces () {
INTERFACES=$(ifconfig | awk '{print $1}' | grep : | sed 's/://')
[[ $INTERFACES ]] && 
if grep -q "tun" <<<$INTERFACES
then
        PRE=$(ifconfig | awk '{print $1}' | grep tun)
        IP_NIC=(${PRE//:/})
        IP=$(ifconfig | grep $IP_NIC -A 1 |grep inet |awk '{print $2}')
elif grep -q "eth" <<<$INTERFACES
then
        PRE=$(ifconfig | awk '{print $1}' | grep eth)
        IP_NIC=(${PRE//:/})
        IP=$(ifconfig | grep $IP_NIC -A 1 |grep inet |awk '{print $2}')
else
	print_info "Can not find an [eth] or [tun] NIC."
fi
}
############################################################
#Set up local.prop file
if [[ ! $1 ]]
then
print_error "Missing password, format should be ./cortanaStart.sh [password]"
fi
armitage_interfaces
cat << EOF > /usr/share/armitage/local.prop
host=$IP
port=55553
user=msf
pass=$1
nick=BOT_automationISlife
EOF
############################################################
cd /usr/share/armitage
java -jar cortana.jar local.prop main.cna
