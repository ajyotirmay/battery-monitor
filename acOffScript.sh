#!/bin/env bash

# Enter the commands that you'd like to execute at the time external
# AC source is disconnected from the system. Enter your commands or scripts
# that you want to execute before the line saying "exit 0"

sleep 2s

sudo /usr/bin/powertop --auto-tune &> /dev/null &

exit 0
