#!/bin/bash

# Path to the log file where output will be redirected
LOG_FILE="/scripts/gitlab-startup.log"

# Path to the flag file to track if the script has been executed
FLAG_FILE="/scripts/.gitlab_rails_executed"
GITLAB_TOKEN_FILE="/scripts/gitlab.token"
GITLAB_GROUP_FILE="/scripts/gitlab.group"
GITLAB_APPLICATION_CLIENT_ID_FILE="/scripts/gitlab.client-id"
GITLAB_APPLICATION_CLIENT_SECRET_FILE="/scripts/gitlab.client-secret"

# Function to check if GitLab is ready
function wait_for_gitlab() {
    echo "Waiting for GitLab to be ready..."

    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8090/-/readiness)" != "200" ]]; do
        echo "GitLab is not ready yet, waiting..." 2>&1 | tee -a "$LOG_FILE"
        sleep 30
    done

    echo "GitLab is up and running!" 2>&1 | tee -a "$LOG_FILE"
}

function wait_and_configure_gitlab() {
    # Check if the flag file exists
    if [ -f "$FLAG_FILE" ]; then
        echo "gitlab-rails runner has already been executed, skipping..."
    else
        echo "Executing gitlab-rails runner for the first time..."

        # Wait for GitLab to be ready
        wait_for_gitlab

        # Execute the GitLab Rails runner command (replace 'YourRailsCode' with actual code)
        GITLAB_TOKEN=$(gitlab-rails runner "
            user = User.find_by(username: 'root');
            token = user.personal_access_tokens.create(
                name: 'backstage',
                scopes: ['api', 'read_repository', 'write_repository', 'read_registry', 'write_registry', 'read_user', 'k8s_proxy', 'create_runner', 'manage_runner', 'admin_mode'],
                expires_at: 1.year.from_now
            );
            token.set_token('glpat-zQ-yQ8VyW37oRSbEnWAx');
            token.save!
            puts token.token;
        "2>&1)

        GITLAB_GROUP=$(gitlab-rails runner "
            user = User.find_by(username: 'root');
            group = Group.create(
                name: 'backstage-demo',
                path: 'backstage-demo',
                visibility: 'private'
            );
            group.add_owner(user);
            puts group.name;
        "2>&1)

        GITLAB_CREDENTIALS=$(gitlab-rails runner "
            application = Doorkeeper::Application.create(
                name: 'backstage',
                redirect_uri: 'http://localhost:7007/api/auth/gitlab/handler/frame',
                scopes: 'api read_user',
                confidential: true,
                trusted: true,
                uid: 'd3ea15baea5a9d72ed6a5fa2e42c71140a634bc374b0b0aaa01066a87e62ec62',
                secret: 'gloas-b1f8c16b11c2a90737b678ec970e0f0247aee65ae886e7dce89c65ae29a6bf67'
            );
            application.save!
            puts \"#{application.uid}@#{application.secret}\";
        "2>&1)

        # Mark the script as executed by creating a flag file
        echo $GITLAB_TOKEN > $GITLAB_TOKEN_FILE
        echo $GITLAB_GROUP > $GITLAB_GROUP_FILE
        echo $GITLAB_CREDENTIALS | cut -d "@" -f 1 > $GITLAB_APPLICATION_CLIENT_ID_FILE
        echo $GITLAB_CREDENTIALS | cut -d "@" -f 2 > $GITLAB_APPLICATION_CLIENT_SECRET_FILE

        # Mark the script as executed by creating a flag file
        touch "$FLAG_FILE"
    fi
}

wait_and_configure_gitlab &

exec /assets/wrapper