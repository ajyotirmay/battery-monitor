#!/bin/env bash

export LANGUAGE="en"

# location of your battery's information.
# The default should work for most, but if it doesn't modify it accordingly
export loc='/org/freedesktop/UPower/devices/battery_BAT0'

# How much should the battery be charged before alerting the user
export maxCharge=90

# How much should the battery be let to discharge before alerting the user
export minCharge=30

# When is the system supposed to take an action before completely draining out
export criticalLevel=10

# Should the system use a critical action e.g. Shutdown
export criticalAction='on'

# Should there be an alarm to let the user know?
# Default is 'on'
export alarm='on'

# Run custom actions when AC OFF
export acOffAction='on'

# Run custom actions when AC ON
export acOnAction='off'

################################
# Visual notification settings #
################################
# Is the notification supposed to flash or be a static sticky one?
# Since KDE Plasma 5.11 flashing notification is not recommended because
# of the new Notification Manager introduced.
# Options 'flash', 'static'
# Recommended: static
export method='static'

# If flashing notification, what should be the rate of flash (in millisecond)
export timeout=1000

# Function to get the battery's charge percentage
function batteryPercentage() {
	#BAT=$(upower -i $loc | grep percentage | grep '[0-9]*' --only-matching)
    BAT=`acpi | awk '{print $4}' | sed 's/\%,//'`
}

# Function to get battery's charging status
function batteryStatus() {
	#STAT=$(upower -i $loc | grep state | grep "\(charging\|discharging\|fully-charged\)" --only-matching)
    STAT=`acpi | awk '{print $3}' | sed 's/,//' | awk '{print tolower($0)}'`
}

function killAlarm() {
    killall alarm.sh && kill -9 `ps -C paplay | awk 'FNR == 2 { print $1 }'`
}
