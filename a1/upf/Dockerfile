FROM ubuntu:18.04

RUN mkdir /code
WORKDIR /code

RUN apt-get update && apt-get install -y tcpdump iputils-ping iproute2 iptables traceroute conntrack

COPY . .

RUN chmod +x /code/entry-point.sh /code/set-dest.sh
ENTRYPOINT [ "/code/entry-point.sh" ]