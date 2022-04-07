FROM maven:3-jdk-8-slim as intermediate

ARG APP_NAME

ARG ENVIRONMENT

ARG AWS_ACCESS_KEY_ID

ARG AWS_SECRET_ACCESS_KEY

RUN apt-get update -y && apt-get install -y python python3-pip
RUN pip install --upgrade awscli s3cmd python-magic
RUN apt-get remove -y --purge python3-pip

ADD . /${APP_NAME}

WORKDIR /${APP_NAME}

RUN ./build_k8s.sh  /${APP_NAME}-deploy ${ENVIRONMENT} ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}


FROM openjdk:8-alpine

ARG APP_NAME

ARG ENVIRONMENT

ENV destination='/home/ubuntu/deployment'

ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=intermediate /${APP_NAME}-deploy/  ${destination}

RUN mkdir -p /logs/${APP_NAME}

RUN apk add --update bash && rm -rf /var/cache/apk/*

ARG CACHEBUST=1

WORKDIR ${destination}

ENV ENVIRONMENT=${ENVIRONMENT}

RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh ${ENVIRONMENT}