#!/bin/bash

if [ "$1" == 'MECH' ]; then
    iptables-restore natTable-mech.v4
elif [ "$1" == 'Cloud' ]; then
    iptables-restore natTable-cloud.v4
else
    echo "Expected argument as 'MECH' or 'Cloud'" && exit 1
fi
