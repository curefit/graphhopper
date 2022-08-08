#!/bin/bash


set -x
set -e

APP_NAME=$1
APP_ENV=$2
TAG_NAME=$3
SA_JSON=$4
AWS_ACCESS_KEY_ID=$5
AWS_SECRET_ACCESS_KEY=$6
REPOSITORY=$7

if [ -z ${APP_NAME} ] || [ -z ${APP_ENV} ] || [ -z ${TAG_NAME} ] || [ -z ${SA_JSON} ];
then
    echo "APP_NAME, APP_ENV, TAG_NAME and SA_JSON are Mandatory"
    exit 1
fi

if [ -z ${AWS_ACCESS_KEY_ID} ] || [ -z ${AWS_SECRET_ACCESS_KEY} ];
then
    echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are Mandatory"
    exit 1
fi

if [ -z ${REPOSITORY} ];
then
    echo "REPOSITORY is Mandatory"
    exit 1
fi

echo "Cheking node is installed or not"
NODE_COMMAND=node
if hash -- "$NODE_COMMAND" 2> /dev/null; 
then
    ($NODE_COMMAND --version)
else
    echo "installing node"
    sudo apt-get install -y nodejs  
fi

echo "Cheking npm is installed or not"
NPM_COMMAND=npm
if hash -- "$NPM_COMMAND" 2> /dev/null; 
then
    ($NPM_COMMAND --version)
else
    echo "installing npm"
    sudo apt-get install -y npm
fi

REPO_NAME="curefoods-k8s-templates"
git clone -b node_scale_down git@github.com:curefit/${REPO_NAME}.git ${REPO_NAME}

cd ${REPO_NAME}
cd chart

echo "Cheking merge-yaml is installed or not"
YML_COMMAND=merge-yaml
if hash -- "$YML_COMMAND" 2> /dev/null; 
then
    echo "merge-yaml is already installed"
else
    echo "installing merge-yaml"
    sudo npm i -g merge-yaml-cli
fi

VALUES_FILE="values.yaml"
echo "Merging application values.yaml with base values.yaml"
merge-yaml -i values.yaml ../../../values-${APP_ENV}.yaml -o ${VALUES_FILE}

echo "Setting app name in values.yaml"
sed -i -e "s/<APP_NAME>/${APP_NAME}/g" "${VALUES_FILE}"

echo "Setting app env in values.yaml"
sed -i -e "s/<APP_ENV>/${APP_ENV}/g" ${VALUES_FILE}

echo "Setting REPOSITORY in values.yaml"
tmp_repo=${REPOSITORY//\//\\\/} 
sed -i -e "s/<REPOSITORY>/${tmp_repo}/g" ${VALUES_FILE}

echo "Setting aws cred in values.yaml"
sed -i -e "s/<AWS_ACCESS_KEY_ID>/${AWS_ACCESS_KEY_ID}/g" ${VALUES_FILE}
sed -i -e "s/<AWS_SECRET_ACCESS_KEY>/${AWS_SECRET_ACCESS_KEY}/g" ${VALUES_FILE}

echo "Setting tag in values.yaml"
sed -i -e "s/<TAG_NAME>/${TAG_NAME}/g" ${VALUES_FILE}
cat ${VALUES_FILE}

echo "Setting app name in chart/templates/fluentdconfigmap.yaml"
sed -i -e "s/<APP_NAME>/${APP_NAME}/g" templates/fluentdconfigmap.yaml

echo "need to set chart/templates/secret.yaml"
sed -i -e "s/<SA_JSON>/${SA_JSON}/g" templates/secret.yaml

# get cred of cluster

if [ $APP_ENV == "prod" ];
then 
    echo "Get prod cluster cred"
    KUBECONFIG=config gcloud container clusters get-credentials curefoods-prod-cluster --region asia-south1 --project curefoods-infra-prod
else 
    echo "Get stage cluster cred"
    KUBECONFIG=config gcloud container clusters get-credentials anthos --zone asia-south1-a --project curefoods-infra
fi

helm version
helm upgrade --install --kubeconfig=config "${APP_NAME}" -n "${APP_NAME}" .

set +x
set +e