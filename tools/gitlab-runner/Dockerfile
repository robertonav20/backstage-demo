FROM gitlab/gitlab-runner:alpine3.19

ARG GITLAB_URL
ARG GITLAB_API_KEY

ENV GITLAB_URL=$GITLAB_URL
ENV GITLAB_API_KEY=glrt-t1_hzBXihr1V7pv4f2MuvCc

RUN cat <<EOF | tee -a /etc/gitlab-runner/config.toml -
    [[runners]]
    name = "docker-runner"
    url = "${GITLAB_URL}"
    token = "${GITLAB_API_KEY}"
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