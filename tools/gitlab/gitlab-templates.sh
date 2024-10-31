#!/bin/bash

# Path to the log file where output will be redirected
LOG_FILE=$GITLAB_SCRIPTS_DIR/gitlab-startup.log

# Configuration variables
GITLAB_GROUP_FILE=$GITLAB_SCRIPTS_DIR/gitlab.group
GITLAB_GROUP_ID_FILE=$GITLAB_SCRIPTS_DIR/gitlab.group-id
GITLAB_SUB_GROUP_ID_FILE=$GITLAB_SCRIPTS_DIR/gitlab.sub-group-id

# Function to create a GitLab project and upload files
create_project_and_upload_files() {
    local project_name="$1"
    local project_path="$2"
    local folder_path="$3"
    local group_id="$4"

    echo "Startup - Creating project '$project_name'..." 2>&1 | tee -a "$LOG_FILE"

    # Create project under the specified group
    project_id=$(curl --silent \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        --header "Content-Type: application/json" \
        --data "{
            \"name\": \"$project_name\",
            \"namespace_id\": \"$group_id\"
        }" \
        "$GITLAB_URL/api/v4/projects" | jq -r '.id')

    # Check if the project was created successfully
    if [[ "$project_id" = null || "$project_id" = "" ]]; then
        echo "Startup - Failed to create project '$project_name'." 2>&1 | tee -a "$LOG_FILE"
        return
    fi
    echo "Startup - Project '$project_name' created with ID: '$project_id'" 2>&1 | tee -a "$LOG_FILE"

    # Loop through all files in the folder and upload them to the project repository
    find "$folder_path" -type f | while read -r file_path; do
        relative_path=$(realpath --relative-to="$folder_path" "$file_path")
        absolute_path=$file_path
        remote_path=$(printf %s $relative_path | jq -sRr @uri)

        echo "Startup - Uploading file '$relative_path' with content of '$absolute_path' at remote path '$remote_path'." 2>&1 | tee -a "$LOG_FILE"

        # Use GitLab API to upload each file to the repository
        result_file_path=$(curl -v \
            --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
            -F "branch=main" \
            -F "content=<$absolute_path" \
            -F "commit_message=Initial commit" \
            "$GITLAB_URL/api/v4/projects/$project_id/repository/files/$remote_path" | jq -r '.file_path')

        echo "Startup - File uploaded at path: '$result_file_path'" 2>&1 | tee -a "$LOG_FILE"
    done

    echo "Startup - All files from '$folder_path' uploaded to project '$project_name'." 2>&1 | tee -a "$LOG_FILE"
}

# Start script
echo "Startup - Checking existing group '$GITLAB_GROUP'..." 2>&1 | tee -a "$LOG_FILE"

#Checks if group exists
GITLAB_SUB_GROUP_ID=$(curl --silent \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups?search=templates" | jq -r '.[] .id')

if [[ "$GITLAB_SUB_GROUP_ID" != null || "$GITLAB_SUB_GROUP_ID" != "" ]]; then
    echo "Startup - Deleting group 'templates' with ID: $GITLAB_SUB_GROUP_ID" 2>&1 | tee -a "$LOG_FILE"

    curl --silent \
        --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups/$GITLAB_SUB_GROUP_ID" > /dev/null

    GITLAB_SUB_GROUP_ID=null

    sleep 5
fi

#Checks if group exists
GITLAB_GROUP_ID=$(curl --silent \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups?search=$GITLAB_GROUP" | jq -r '.[] .id')

if [[ "$GITLAB_GROUP_ID" != null || "$GITLAB_GROUP_ID" != "" ]]; then
    echo "Startup - Deleting group '$GITLAB_GROUP' with ID: $GITLAB_GROUP_ID" 2>&1 | tee -a "$LOG_FILE"

    curl --silent \
        --request DELETE \
        --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
        "$GITLAB_URL/api/v4/groups/$GITLAB_GROUP_ID" > /dev/null

    GITLAB_GROUP_ID=null

    sleep 5
fi

# Create backstage gitlab group
GITLAB_GROUP_ID=$(curl --silent \
    --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
    --header "Content-Type: application/json" \
    --data "{
        \"name\": \"$GITLAB_GROUP\",
        \"path\": \"$GITLAB_GROUP\",
        \"auto_devops_enabled\": false
    }" \
    "$GITLAB_URL/api/v4/groups" | jq -r '.id')

# Check if the project was created successfully
if [[ "$GITLAB_GROUP_ID" = null || "$GITLAB_GROUP_ID" == "" ]]; then
    echo "Startup - Failed to create group '$GITLAB_GROUP' impossible to proceed." 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

# Create backstage template gitlab sub group
GITLAB_SUB_GROUP_ID=$(curl --silent \
    --header "PRIVATE-TOKEN: $GITLAB_API_KEY" \
    --header "Content-Type: application/json" \
    --data "{
        \"name\": \"templates\",
        \"path\": \"templates\",
        \"parent_id\": \"$GITLAB_GROUP_ID\"
    }" \
    "$GITLAB_URL/api/v4/groups" | jq -r '.id')

# Check if the project was created successfully
if [[ "$GITLAB_SUB_GROUP_ID" = null || "$GITLAB_SUB_GROUP_ID" == "" ]]; then
    echo "Startup - Failed to create sub group 'templates' impossible to proceed." 2>&1 | tee -a "$LOG_FILE"
    exit 1
fi

echo $GITLAB_GROUP > $GITLAB_GROUP_FILE
echo $GITLAB_GROUP_ID > $GITLAB_GROUP_ID_FILE
echo $GITLAB_SUB_GROUP_ID > $GITLAB_SUB_GROUP_ID_FILE

echo "Startup - Group '$GITLAB_GROUP' created with ID: '$GITLAB_GROUP_ID'." 2>&1 | tee -a "$LOG_FILE"
echo "Startup - Sub Group 'templates' created with ID: '$GITLAB_SUB_GROUP_ID'." 2>&1 | tee -a "$LOG_FILE"


# Iterate over each folder in the backstage templates directory
for template_folder in "$GITLAB_TEMPLATES_DIR"/*; do
    if [ -d "$template_folder" ]; then
        project_path=$template_folder
        project_name=$(basename "$template_folder")
        create_project_and_upload_files "$project_name" "$project_path" "$template_folder" "$GITLAB_SUB_GROUP_ID"
    fi
done