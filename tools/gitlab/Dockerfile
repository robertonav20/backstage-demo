FROM gitlab/gitlab-ce:17.5.0-ce.0

RUN mkdir -p ./scripts

COPY ./gitlab-startup.sh ./scripts

RUN chmod +xr ./scripts/gitlab-startup.sh