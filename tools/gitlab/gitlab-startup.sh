#!/bin/bash

# Path to the log file where output will be redirected
LOG_FILE=$GITLAB_SCRIPTS_DIR/gitlab-startup.log

# Path to the flag file to track if the script has been executed
FLAG_FILE=$GITLAB_SCRIPTS_DIR/.gitlab_rails_executed

# Files to track gitlab rails execution
GITLAB_TOKEN_FILE=$GITLAB_SCRIPTS_DIR/gitlab.token
GITLAB_APPLICATION_CLIENT_ID_FILE=$GITLAB_SCRIPTS_DIR/gitlab.client-id
GITLAB_APPLICATION_CLIENT_SECRET_FILE=$GITLAB_SCRIPTS_DIR/gitlab.client-secret

# Function to check if GitLab is ready
function wait_for_gitlab() {
    echo "Startup - Waiting for GitLab to be ready..."

    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost/-/readiness)" != "200" ]]; do
        echo "Startup - GitLab is not ready yet, waiting..." 2>&1 | tee -a "$LOG_FILE"
        sleep 30
    done

    echo "Startup - GitLab is up and running!" 2>&1 | tee -a "$LOG_FILE"
}

function wait_and_configure_gitlab() {
    # Check if the flag file exists
    if [ -f "$FLAG_FILE" ]; then
        echo "Startup - gitlab-rails runner has already been executed, skipping..."
    else
        echo "Startup - Executing gitlab-rails runner for the first time..."

        # Wait for GitLab to be ready
        wait_for_gitlab

        # Execute the GitLab Rails runner command (replace 'YourRailsCode' with actual code)
        GITLAB_TOKEN=$(gitlab-rails runner "
            user = User.find_by(username: '$GITLAB_USER');
            token = user.personal_access_tokens.create(
                name: 'backstage',
                scopes: ['api', 'read_repository', 'write_repository', 'read_registry', 'write_registry', 'read_user', 'k8s_proxy', 'create_runner', 'manage_runner', 'admin_mode'],
                expires_at: 1.year.from_now
            );
            token.set_token('$GITLAB_API_KEY');
            token.save!
            puts token.token;
        "2>&1)

        GITLAB_CREDENTIALS=$(gitlab-rails runner "
            application = Doorkeeper::Application.create(
                name: 'backstage',
                redirect_uri: 'http://localhost:7007/api/auth/gitlab/handler/frame',
                scopes: 'api read_user',
                confidential: true,
                trusted: true,
                uid: '$GITLAB_CLIENT_ID',
                secret: '$GITLAB_CLIENT_SECRET'
            );
            application.save!
            puts \"#{application.uid}@#{application.secret}\";
        "2>&1)

        # Initialize backstage templates repo
        exec $GITLAB_SCRIPTS_DIR/gitlab-templates.sh

        # Mark the script as executed by creating a flag file
        echo $GITLAB_TOKEN > $GITLAB_TOKEN_FILE
        echo $GITLAB_CREDENTIALS | cut -d "@" -f 1 > $GITLAB_APPLICATION_CLIENT_ID_FILE
        echo $GITLAB_CREDENTIALS | cut -d "@" -f 2 > $GITLAB_APPLICATION_CLIENT_SECRET_FILE

        # Mark the script as executed by creating a flag file
        touch "$FLAG_FILE"
    fi
}

wait_and_configure_gitlab &

exec /assets/wrapper