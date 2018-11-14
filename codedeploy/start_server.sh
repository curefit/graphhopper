#!/bin/bash

# Build Docker Image from Dockerfile
sudo docker build -t graphhopper-traffic-curefit:latest /home/ubuntu/graphhopper-traffic/


echo "Will run Docker container for graphhopper-traffic"
sudo docker run --name graphhopper-traffic --memory="2048m" --log-driver=awslogs --log-opt awslogs-group=eatfit/graphhopper-traffic -v /home/ubuntu/graphhopper-traffic:/app -d -p 5203:8989 graphhopper-traffic-curefit:latest


sleep 60   # sleeping 60 seconds so the code-deploy waits here before picking up the next box. This 60 seconds ensure that the service inside the container is up and running. (if no errors)

echo "Docker container started..."