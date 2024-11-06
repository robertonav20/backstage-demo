FROM gitlab/gitlab-runner:alpine3.19

RUN apk add --no-cache jq

ARG GITLAB_URL
ARG GITLAB_API_KEY
ARG GITLAB_SCRIPTS_DIR="/scripts"

ENV GITLAB_URL=$GITLAB_URL
ENV GITLAB_API_KEY=$GITLAB_API_KEY
ENV GITLAB_SCRIPTS_DIR=$GITLAB_SCRIPTS_DIR

RUN echo $GITLAB_URL
RUN cat /etc/resolv.conf

RUN mkdir -p $GITLAB_SCRIPTS_DIR

COPY ./gitlab-runner-startup.sh $GITLAB_SCRIPTS_DIR

RUN chmod +xr $GITLAB_SCRIPTS_DIR/gitlab-runner-startup.sh

RUN $GITLAB_SCRIPTS_DIR/gitlab-runner-startup.sh

RUN cat <<EOF | tee -a /etc/gitlab-runner/config.toml -
    [[runners]]
    name = "docker-runner"
    url = "${GITLAB_URL}"
    token = "${GITLAB_RUNNER_REGISTRATION_TOKEN}"
    executor = "docker"
    [runners.docker]
        image = "alpine:latest"
        privileged = true
        tls_verify = false
        network_mode = "host"
        volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    [runners.cache]
        path = "/cache"
        shared = true
EOF