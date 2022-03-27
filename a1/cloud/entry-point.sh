#!/bin/bash

echo hello world

ip route del default &&
ip route add default via ${upf_ip} # Setting UPF as the gateway

exec tcpdump -i any icmp --immediate-mode -l -n
