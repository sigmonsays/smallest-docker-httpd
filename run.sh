#!/bin/bash

docker rm -f httpd
docker run -d --name httpd httpd /httpd

