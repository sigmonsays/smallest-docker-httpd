#!/bin/bash

docker rm -f httpd
docker run -d --name httpd httpd /httpd

container_ip="$(docker inspect httpd | jq -r '.[] | .NetworkSettings.IPAddress')"
container_pid="$(docker inspect -f '{{.State.Pid}}' httpd)"
echo "container pid $container_pid"
echo "container ip $container_ip"
