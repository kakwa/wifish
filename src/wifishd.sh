#path to the default configuration file
DEFAULT_CONFIG_FILE="/etc/wifish/wifish.conf"

#creation of the pid file
mkdir -p /var/run/wifishd/
echo $$ >/var/run/wifishd/wifishd.pid

not_associated=1
ESSID=""

#function testing if we are associated with an AP
is_not_associated(){
	ifconfig $IWLAN up
	test=`iwconfig $IWLAN|grep "Access Point"`
	state=`echo $test |sed "s/.*Point:\ *//"|sed "s/\ *Tx-Power.*//"`
	if [ "$state" = 'Not-Associated' ];
	then
		not_associated=1
	else
		not_associated=0
	fi
}

#function scanning the APs and returning the first that has been configured
search_AP(){
    AP_list=`iwlist $IWLAN scan |grep "ESSID"|sed s/ESSID:\"//|sed "s/\"//"`

    for i in $AP_list;
	do
		if [ -f $USER_NETWORK_DIR/$i.cfg ]
		then
			ESSID=$i
			return
		fi
	done
	ESSID=""
}

#load the configuration
. $DEFAULT_CONFIG_FILE

make_interface_up
#infinite loop
while [ 1 ];
do
    #every 30 secondes, it tests if laptop is assiociated with a network
	is_not_associated
	if [ $not_associated -eq 1 ];
	then
        #if we are not, it searches a network
		search_AP
		if ! [ "$ESSID" = "" ]
		then
            #if it has found one, it launch wifish-cfg to connect to it
			wifish-cfg -n $ESSID
            #reset of $ESSID
            ESSID=""
		fi
	fi
	sleep 30
done
