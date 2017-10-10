#!/bin/bash

#LANGUAGE="en"
#user='apurv'
#loc='/org/freedesktop/UPower/devices/battery_BAT0'
#queryState='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep state | grep "\(charging\|discharging\)" --only-matching'
#maxCharge=90
#lowLevel=31
#criticalAction='on'
#alarm='on'

if [ $USER == $user ]
then
    # tests if the script is already running or not
    if [ -f "/tmp/_bat_monitor_lockfile" ];
    then
        exit 0
    fi
 
    # creates a lockfile if the script starts to run
    touch "/tmp/_bat_monitor_lockfile";
    
    while true;
    do
        STAT=$(upower -i $loc | grep state | grep "\(charging\|discharging\|fully-charged\)" --only-matching)
        BAT=$(upower -i $loc | grep percentage | grep '[0-9][0-9]' --only-matching)
        
        ##################################################
        # status: charging and power is above max charge #
        ##################################################
        if [ "$STAT" = "charging" ] && [ "$BAT" -gt "$maxCharge" ];
        then
            ./notification.sh 0 &
            NOTIFICATION=$(echo $!)
            if [ "$alarm" = "on" ]
            then
                ./alarm.sh &
                alarm_id=$(echo $!)
            fi
                    
            while true;
            do
                STAT=$(upower -i $loc | grep state | grep "\(charging\|discharging\|fully-charged\)" --only-matching)
                
                if [ "$STAT" = "discharging" ];
                then
                    if [ "$alarm" = 'on' ]
                    then
                        kill -9 $alarm_id
                    fi
                    
                    kill -9 $NOTIFICATION
                    break
                fi
                sleep 1s;
            done
        fi
        
        ####################################################
        # status: full-charged & power is above max charge #
        ####################################################
        if [ "$STAT" == 'fully-charged' ] && [ "$BAT" -gt "$maxCharge" ];
        then
            ./notification.sh 1 &
            NOTIFICATION=$(echo $!)
            
            if [ "$alarm" = "on" ]
            then
                ./alarm.sh &
                alarm_id=$(echo $!)
            fi
            
            while true;
            do
                STAT=$(upower -i $loc | grep state | grep "\(charging\|discharging\|fully-charged\)" --only-matching)
                
                if [ "$STAT" == 'discharging' ];
                then
                    if [ "$alarm" = "on" ]
                    then
                        kill -9 $alarm_id
                    fi
                    
                    kill -9 $NOTIFICATION
                    break
                fi
                sleep 1s;
            done
        fi
        
        ###################################################
        # status: discharging & power is below low charge #
        ###################################################
        if [ "$STAT" = 'discharging' ] && [ "$BAT" -lt "$minCharge" ];
        then
            ./notification.sh 2 &
            NOTIFICATION=$(echo $!)
            
            if [ "$criticalAction" = 'on' ]
            then
                ./critical_battery.sh & 
                CRITCAL_ACTION=$(echo $!)
            fi
            
            if [ "$alarm" = "on" ]
            then
                ./alarm.sh &
                alarm_id=$(echo $!)
            fi
            
            while true;
            do
                STAT=$(upower -i $loc | grep state | grep "\(charging\|discharging\|fully-charged\)" --only-matching)
                
                if [ "$STAT" = "charging" ];
                then
                    if [ "$alarm" = 'on' ]
                    then
                        kill -9 $alarm_id
                    fi
                    
                    if [ "$criticalAction" = 'on' ]
                    then
                        kill -9 $CRITCAL_ACTION
                    fi
                    
                    kill -9 $NOTIFICATION
                    
                    break
                fi
                sleep 1s;
            done
        fi
        sleep 1s;
    done
fi
