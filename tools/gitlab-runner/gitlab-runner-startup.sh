LOG_FILE=$GITLAB_SCRIPTS_DIR/gitlab-runner-startup.log

echo "Startup - GitLab Runner trying to register it!" 2>&1 | tee -a "$LOG_FILE"

GITLAB_GROUP_ID=$(curl -v --request GET \
    --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
    "$GITLAB_URL/api/v4/groups" | jq -r '.[0] .id')

GITLAB_RUNNER_API_KEY=$(curl --request GET \
    --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
    "$GITLAB_URL/api/v4/groups/2" | jq -r '.runners_token')

# Check if the api key is present
if [[ "$GITLAB_RUNNER_API_KEY" = null || "$GITLAB_RUNNER_API_KEY" == "" ]]; then
    echo "Startup - Failed to retrieve runner api key, impossible to proceed." 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

GITLAB_RUNNER_REGISTRATION_TOKEN=$(curl -v \
    --form "token=$GITLAB_RUNNERS_API_KEY" --form "description=backstage-demo-runner" \
    --form "run_untagged=true" \
    "$GITLAB_URL/api/v4/runners" | jq '.token')

# Check if the token was created successfully
if [[ "$GITLAB_RUNNER_REGISTRATION_TOKEN" = null || "$GITLAB_RUNNER_REGISTRATION_TOKEN" == "" ]]; then
    echo "Startup - Failed to retrieve registration token, impossible to proceed." 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

echo "Startup - GitLab Runner registration token '$GITLAB_RUNNER_REGISTRATION_TOKEN'" 2>&1 | tee -a "$LOG_FILE"