interface="wlan0"

#default configuration file
DEFAULT_CONFIG_FILE="/etc/wifish/wifish.conf"
LOG_LEVEL=7

#a small help function
help(){
    echo
    echo "`basename $0` configures a wifi network or connects your computer to it"
    echo
    echo "usage: `basename $0` [-h] [-f <path/to/configuration/file>] [-n <network's name>]"
    echo
    echo "without option it prompts you forms to configure a network"
    echo "-h: displays this help"
    echo "-f: permits to specifies another configuration file"
    echo "-n: permits the connexion to an already configured network"
    echo
}

#a small function selecting a separator for sed
select_separator(){
    local potental_separators="@ \` ! # $ % & : ; + { , < / | - = ] } . > ^ ~ ? _"
    for sep in `echo "$potental_separators"`
    do
        echo "$sep"
        echo "$1" |grep -vq "$sep"
        ret=$?
        if [ $ret -eq 0 ]
        then
            echo "$sep"
            return 0
        fi
    done
    simple_logger err "no separator found (you're an evil doer)"
    exit 1
}

#test the existance of a file + print error and exit 1 if file doesn't exist
test_file(){
    local file=$1
    if ! [ -e $file ]
    then
        simple_logger err "$file doesn't exist"
        exit 1
    fi
}

#create a selection menu of available networks
#if the selected network doesn't have a configuration
#it interactively configures it
choose_and_configure(){
    #we need some template to create the .cfg
    if ! [ -d $TEMPLATES_DIR ]
    then 
        simple_logger err "missing $TEMPLATES_DIR (template directory)"
        exit 1 
    fi

    #just to be sure
    mkdir -p $USER_NETWORK_DIR

    simple_logger debug "scanning networks"

    #create the menu listing the APs, return the chosen essid (ugly line I know)
    NETWORK=`iwlist $IWLAN  scan |grep "ESSID\|WPA\|WEP\|Signal"|\
        sed "s/^\ .*/&azp5/"|sed "s/Quality.*/\n&/"|sed "s/^\ *&//"\
        |sed "s/\ *//"| sed ':a;N;$!ba;s/azp5\n/ /g'|sed s/azp5//|\
        sed "s/  Signal level=.*dBm//"|sort -r|dmenu -l 5|sed s/.*:\"//|\
        sed "s/\".*//"`

    #if no network is selected
    if [ "$NETWORK" = "" ]
    then 
        simple_logger warning  "no network selected by user"
        exit 0
    fi

    #if the essid is not configure, ask for configuration.
    if ! [ -f $USER_NETWORK_DIR/$NETWORK.cfg ]
    then
        #choose the template from the templates directory
        type=`ls $TEMPLATES_DIR|dmenu -l 5`

        #copy the template
        cp $TEMPLATES_DIR/$type $USER_NETWORK_DIR/$NETWORK.cfg

        #set restrited access (clear passwd)
        chown root:root $USER_NETWORK_DIR/$NETWORK.cfg
        chmod 600 $USER_NETWORK_DIR/$NETWORK.cfg

        #configure the ESSID in the template copy
        sep=`select_separator "$NETWORK"`
        sed -i  s${sep}\$_ESSID${sep}$NETWORK${sep}g $USER_NETWORK_DIR/$NETWORK.cfg

        #get the other parameters name
        arglist=`grep "\\$_" $TEMPLATES_DIR/$type|grep -v ESSID |\
            sed "s/^.*=//"|sed "s/\"//g"` 	 				

        for i in $arglist;
        do
            arg_name=`echo $i|sed "s/\$_//"`
            #configure parameter in the template copy
            data=`echo ""|dmenu -p "$arg_name:"` #ask parameter
            sep=`select_separator "$data"`
            sed -i s${sep}$i${sep}$data${sep}g $USER_NETWORK_DIR/$NETWORK.cfg
        done
        simple_logger info "$NETWORK configured by user"
    fi
}

#reinitialization of the wlan interface
reinit(){
    #it stops the wpa_supplicant process
    #if it exists
    if [ -f $WPA_SUPPLICANT_PID_FILE ]
    then
        simple_logger info  "stopping the former connexion"
        kill `cat $WPA_SUPPLICANT_PID_FILE`
        rm $WPA_SUPPLICANT_PID_FILE
    fi

    #if wlan interface is down,
    #it ups it and wait few seconds
    make_interface_up

    #it stop the dhcp client process
    #if it exists
    if [ -f $DHCP_PID_FILE ]
    then
        simple_logger debug  "stopping the dhcp client"
        pid=`cat $DHCP_PID_FILE` 
        #kill dhcpcd on $interface
        kill  $pid 
        rm $DHCP_PID_FILE
    fi
}



start_wifi(){

    simple_logger info  "connecting to network \"$NETWORK\""
    test_file $USER_NETWORK_DIR/$NETWORK.cfg

    #start wpa supplicant
    simple_logger debug "starting wpa_supplicant"
    wpa_supplicant -B -Dwext -i$IWLAN \
        -c$USER_NETWORK_DIR/$NETWORK.cfg \
        -P $WPA_SUPPLICANT_PID_FILE 2>/dev/null

    #wait until interface is associated, to be sure wpa_supplicant has made its job
    simple_logger debug "testing if $IWLAN is associated"
    ret=0
    while [ $ret -eq 0 ]
    do
        test_interface_associated
        ret=$?
    done


    simple_logger debug "starting dhcp client"
    #start the dhcp client on the new connection
    $DHCP_CMD $interface  2>/dev/null
}

while getopts ":hf:n:" opt; do
    case $opt in

        h) 
            #display the help
            help
            exit 0
            ;;
        f)
            #path to the configuration file
            CONFIG_FILE=`readlink -m $OPTARG`
            ;;
        n)
            #the name of the network
            NETWORK=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            help
            exit 1
            ;;
    esac
done

if [ `id -u` -ne 0 ]
then
    echo "[ERROR] must be run as root"
    exit 1
fi

if [ -z "$CONFIG_FILE" ]
then CONFIG_FILE="$DEFAULT_CONFIG_FILE"
fi

test_file $CONFIG_FILE

. $CONFIG_FILE

NUM_LOG_LEVEL=`get_level_number $LOG_LEVEL`

if [ "$NETWORK" = "" ]
then
    choose_and_configure
    reinit
    start_wifi
else
    reinit
    start_wifi
fi
