# ELV780 Assignment 1

Submitted by Arpit Saxena, 2018MT10742

## Running

This code requires Docker and Docker Compose to run. When these are available, run the following in the root directory of this assignment:

```sh
docker-compose up --build
```

This will build the containers, connect them as specified in the assignment and then start them. To stop them, simply run Ctrl-C.

### The Switch

The reroute target of UPF is controlled through the variable `ROUTE_DEST` defined in `.env` present in the root directory. If set to `MECH`, UPF will redirect traffic to MECH and if set to `Cloud`, UPF will redirect traffic to Cloud machine. Note that after changing the variable in `.env`, the containers have to restarted for the changes to take place.

## How it works

This section aims to explain the workings of this assignment. There are 4 containers namely Client, UPF, MECH and Cloud and their code are in the directories `client/`, `upf/`, `mech/` and `cloud/` respectively. Each of these directories contain a `Dockerfile` which specifies what to install in the containers and commands to run and also an `entry-point.sh` which runs the commands which produce the output.

Client runs a ping to IP of Cloud, UPF just sits idly and MECH & Cloud run a `tcpdump` process for ICMP packets appearing on any interface.

### Connections

The connections between the machines were specified to be made like this:

```txt
                    |--> MECH
Client <---> UPF <--
                    |--> Cloud
```

To make these connections, three separate networks are made as seen in the networks section of `docker-compose.yml` in the root directory of the submission. The network with IP addresses of the interfaces finally looks like:

```txt
               Client
           (172.240.11.2)
                  |
                  |
                  |
           (172.240.11.3)
                 UPF
                /   \
               /     (172.240.13.3)
      (172.240.12.3)  \
             /         \
            /           \
            |            |
            |            |
      (172.240.12.2)     |
          Cloud     (172.240.13.2)
                        MECH
```

### Routing table modifications

We want to use UPF as the gateway on Client, Cloud and MECH devices so that packets go to it where it can make routing decisions. To accomplish this, we have the following piece of code in `{client,mech,cloud}/entry-point.sh`

```sh
ip route del default &&
ip route add default via ${upf_ip} # Setting UPF as the gateway
```

### Forwarding

With the configuration so far, UPF can forward packets destined to the IP address of Cloud machine to it. To have it forward packets to MECH instead, we make use of that `nat` table in `iptables`.

For a packet coming from Client and destined for Cloud, we do a DNAT to change its destination address to IP of MECH in the PREROUTING chain and do a SNAT to change the source address to IP of UPF in the POSTROUTING chain. The SNAT is essential, otherwise the Cloud machine sends the ICMP ECHO response back to the wrong place.

The following lines of code can be used on the UPF machine to make these entries:

```sh
iptables -A PREROUTING -s 172.240.11.2 -d 172.240.12.2 -j DNAT --to-destination 172.240.13.2
iptables -A POSTROUTING -s 172.240.11.2 -d 172.240.13.2 -j SNAT --to-source 172.240.13.3
```

Note that 172.240.11.2 is Client's IP, 172.240.12.2 is Cloud's IP, 172.240.13.2 is MECH's IP and 172.240.13.3 is UPF's IP on the UPF-Cloud network.

In the implementation, output of `iptables-save` has been saved in `upf/{natTable-mech.v4,natTable-cloud.v4}` so that we can restore the required table using `iptables-restore`.
