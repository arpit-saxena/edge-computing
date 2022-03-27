#!/bin/bash

echo hello world

ip route del default &&
ip route add default via ${upf_ip} # Setting UPF as the gateway

echo "Sleeping for 2 seconds to allow tcpdump to come online" && sleep 2

exec ping ${cloud_ip}
