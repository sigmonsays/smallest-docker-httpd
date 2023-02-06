#!/bin/bash

container_ip="$(docker inspect httpd | jq -r '.[] | .NetworkSettings.IPAddress')"
container_pid="$(docker inspect -f '{{.State.Pid}}' httpd)"

container_port="$(
sudo nsenter -t $container_pid  -n ss -lnt \
    | awk -F'[ :]+' '/^LISTEN/ {print $5}' )"

echo "container pid $container_pid"
echo "container ip $container_ip"
echo "container port $container_port"
