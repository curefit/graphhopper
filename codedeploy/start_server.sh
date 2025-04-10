#!/bin/bash

# Build Docker Image from Dockerfile
sudo docker build -t graphhopper-curefit:latest /home/ubuntu/graphhopper/


echo "Will run Docker container for graphhopper"
sudo docker run --name graphhopper --memory="2048m" --log-driver=awslogs --log-opt awslogs-group=eatfit/graphhopper -v /home/ubuntu/graphhopper:/app -d -p 5200:8989 graphhopper-curefit:latest


sleep 60   # sleeping 60 seconds so the code-deploy waits here before picking up the next box. This 60 seconds ensure that the service inside the container is up and running. (if no errors)

echo "Docker container started..."