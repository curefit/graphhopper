#!/bin/bash
set -x
set -e

name="graphhopper"
BUILD_DIR_PATH=$1
ENV=$2
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4

if [ -z ${AWS_ACCESS_KEY_ID} ]
then
    echo "AWS_ACCESS_KEY_ID is Mandatory"
    exit 1
fi

if [ -z ${AWS_SECRET_ACCESS_KEY} ]
then
    echo "AWS_SECRET_ACCESS_KEY is Mandatory"
    exit 1
fi

if [ -z ${BUILD_DIR_PATH} ]
then
    echo "Build Directory Path is Mandatory"
    exit 1
fi

if [ -z ${ENV} ]
then
    echo "Enviroment is necessary for build"
    exit 1
fi

echo "Building App"

rm -rf osrm_location*

echo "aws configuration"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile default && aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile default && aws configure set region "ap-south-1" --profile default && aws configure set output "json" --profile default
aws s3 cp s3://cf-distance-service-curefoods/osrm/latest_pbf/stage/osrm_location.osm.pbf ./ --region ap-south-1

./graphhopper.sh -a clean -i ./osrm_location.osm.pbf
./graphhopper.sh -a build -i ./osrm_location.osm.pbf
./graphhopper.sh -a import -i ./osrm_location.osm.pbf

mkdir -p ${BUILD_DIR_PATH}

cp web/target/*.jar ${BUILD_DIR_PATH}
cp newrelic/* ${BUILD_DIR_PATH}
cp entrypoint.sh ${BUILD_DIR_PATH}

cp -r osrm_location.osm.pbf ${BUILD_DIR_PATH}
cp config.yml ${BUILD_DIR_PATH}
cp -r osrm_location.osm-gh ${BUILD_DIR_PATH}
cp graphhopper_run.sh ${BUILD_DIR_PATH}




