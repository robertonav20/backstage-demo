LOG_FILE=$GITLAB_SCRIPTS_DIR/gitlab-runner-startup.log

CONFIG_FILE=/etc/gitlab-runner/config.toml
CI_SERVER_URL_FILE=/etc/gitlab-runner/ci-server.url
RUNNER_TOKEN_FILE=/etc/gitlab-runner/runner.token

function wait_for_gitlab() {
    echo "Startup - Waiting for GitLab to be ready..."

    while [[ "$(curl --silent --request GET --header "PRIVATE-TOKEN: $GITLAB_API_KEY" "$GITLAB_URL/api/v4/groups" | jq -r '.[0] .id')" = "" ]]; do
        echo "Startup - GitLab is not ready yet, waiting..." 2>&1 | tee -a "$LOG_FILE"
        sleep 30
    done

    echo "Startup - GitLab is up and running!" 2>&1 | tee -a "$LOG_FILE"
}

if [ -f "$CONFIG_FILE" ]; then
    echo "Startup - GitLab Runner startup has already been executed, skipping..."
else
    # Wait for GitLab to be ready
    wait_for_gitlab

    # Gitlab runner registration
    echo "Startup - GitLab Runner trying to register it!" 2>&1 | tee -a "$LOG_FILE"

    GITLAB_GROUP_ID=$(curl --silent --request GET \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups" | jq -r '.[0] .id')

    echo "Startup - GitLab Runner group id '$GITLAB_GROUP_ID'!" 2>&1 | tee -a "$LOG_FILE"

    GITLAB_RUNNER_API_KEY=$(curl --silent --request GET \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups/$GITLAB_GROUP_ID" | jq -r '.runners_token')

    # Check if the api key is present
    if [[ "$GITLAB_RUNNER_API_KEY" = null || "$GITLAB_RUNNER_API_KEY" == "" ]]; then
        echo "Startup - Failed to retrieve runner api key, impossible to proceed." 2>&1 | tee -a "$LOG_FILE"
        exit 1
    fi

    echo "Startup - GitLab Runner api key '$GITLAB_RUNNER_API_KEY'!" 2>&1 | tee -a "$LOG_FILE"

    GITLAB_RUNNER_TOKEN=$(curl --silent \
        --form "token=$GITLAB_RUNNER_API_KEY" \
        --form "description=backstage-demo-runner" \
        --form "run_untagged=true" \
        "$GITLAB_URL/api/v4/runners" | jq -r '.token')

    echo "Startup - GitLab Runner registered with token '$GITLAB_RUNNER_TOKEN'!" 2>&1 | tee -a "$LOG_FILE"

    export CI_SERVER_URL=$GITLAB_URL
    export RUNNER_TOKEN=$GITLAB_RUNNER_TOKEN

    echo $CI_SERVER_URL > $CI_SERVER_URL_FILE
    echo $RUNNER_TOKEN > $RUNNER_TOKEN_FILE

cat <<EOF | tee -a /etc/gitlab-runner/config.toml -
    [[runners]]
    name = "backstage-demo-runner"
    url = "${CI_SERVER_URL}"
    token = "${RUNNER_TOKEN}"
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

fi

export CI_SERVER_URL=$(cat $CI_SERVER_URL_FILE)
export RUNNER_TOKEN=$(cat $RUNNER_TOKEN_FILE)

# Start the GitLab Runner using config.toml
gitlab-runner run --config $CONFIG_FILE