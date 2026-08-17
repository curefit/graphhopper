FROM maven:3-jdk-8-slim as intermediate

ARG APP_NAME

ARG ENVIRONMENT

RUN apt-get update -y && apt-get install -y python python3-pip
RUN pip install --upgrade awscli s3cmd python-magic
RUN apt-get remove -y --purge python3-pip

ADD . /${APP_NAME}

WORKDIR /${APP_NAME}

RUN ./build_k8s.sh  /${APP_NAME}-deploy ${ENVIRONMENT}


FROM amazoncorretto:8-alpine@sha256:ed85af3e8c340b3e2c9398634cd7e17b609998404b242781097601e5cb471878

ARG APP_NAME

ARG ENVIRONMENT

ENV destination='/home/ubuntu/deployment'

ENV TZ=Asia/Kolkata
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=intermediate /${APP_NAME}-deploy/  ${destination}

RUN mkdir -p /logs/${APP_NAME}

RUN apk add --update bash && rm -rf /var/cache/apk/*

ARG CACHEBUST=1

WORKDIR ${destination}

ENV ENVIRONMENT=${ENVIRONMENT}

RUN chmod +x entrypoint.sh

ENTRYPOINT ./entrypoint.sh ${ENVIRONMENT}