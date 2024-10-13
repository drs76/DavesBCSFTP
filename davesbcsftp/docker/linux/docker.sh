#!/bin/bash
#Create network
#docker network create -d transparent --subnet='192.168.1.0/24' --gateway='192.168.1.254' tlan1

docker build . -t funcapp:latest-dockerfile
docker run -d -p 7071:80 --name funcappdockerfile funcapp:latest-dockerfile
