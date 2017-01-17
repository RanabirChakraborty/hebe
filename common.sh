#!/bin/bash
# Common functions for builds

function set_ip_addresses() {
   DEFAULT_INTERFACE=`netstat -rn | awk '{ if ($1 == "0.0.0.0") print $NF}'`
   CHECKED_IP_ADDRESS=$(ifconfig $DEFAULT_INTERFACE | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
   export MYTESTIP_1=$CHECKED_IP_ADDRESS
   export MYTESTIP_2=127.0.0.1
   export MCAST_ADDR=$(echo $CHECKED_IP_ADDRESS | sed 's/^[0-9]*\./239./')
}




