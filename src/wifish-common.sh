#!/bin/sh

get_level_number(){
    case $1 in
        "emerg")    lev=0;;
        "alert")    lev=1;;
        "crit")     lev=2;;
        "err")      lev=3;;
        "warning")  lev=4;;
        "notice")   lev=5;;
        "info")     lev=6;;
        "debug")    lev=7;;
        \?)         lev=8;;
    esac
    echo $lev
}

simple_logger(){
    lev=`get_level_number $1`
    if [ $lev -le $NUM_LOG_LEVEL ]
    then
        logger $LOG_OPT -t wifish -p  user.$1 $2
    fi
}

test_interface_up(){
    ifconfig | grep -q $IWLAN
    ret=$?
    return $ret
}

make_interface_up(){
    simple_logger info "putting $IWLAN up"
    test_interface_up
    ret=$?
    local counter=0
    while [ $ret -ne 0 ] && [ $counter -lt 30 ]
    do
        ifconfig $IWLAN up
        counter=$(( $counter + 1  ))
        test_interface_up
        ret=$?
    done
    if [ $counter -eq 30 ]
    then
        simple_logger err  "$IWLAN couldn't be upped"
        exit 1
    fi
}

#test if the wifi interface is associated
test_interface_associated(){
    iwconfig $IWLAN|grep -q 'ESSID:off/any'
    ret=$?
    return $ret
}

