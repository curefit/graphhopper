#!/usr/bin/env bash

if [ "$DEPLOYMENT_GROUP_NAME" == "graphhopper-traffic" ]
then
  PORT=5203
else
  PORT=5203
fi
echo ${PORT}

while true
do
  result=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:5203/route?point=12.980269%2C77.694232&point=12.979178%2C77.69725&type=json&locale=en-GB&vehicle=car&weighting=fastest&elevation=false")
  if [ "$result" == "200" ]; then
    break
  fi
  sleep 10
done


