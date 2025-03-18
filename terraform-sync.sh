#!/bin/bash

PROJECT_DIRECTORY=$(pwd)

#get the name of the current project
PROJECT_NAME=$(basename "$PROJECT_DIRECTORY")

#external git repo for storing state files (make sure it's private and not public)
STATE_REPO="git@github.com:yourusername/terraform-state-storage.git"
LOCAL_STATE_DIR="$HOME/.terraform-state-backups"

#ensure the local backup directory exists
mkdir -p "$LOCAL_STATE_DIR"

# Clone or update the remote state repo
if [[ ! -d "$LOCAL_STATE_DIR/.git" ]]; then
    echo "Cloning TFstate backup repo..."
    git clone "$STATE_REPO" "$LOCAL_STATE_DIR"
else
    echo "Updating TFstate repo from VCS..."
    cd "$LOCAL_STATE_DIR"
    git pull origin main
fi

#ensure the project directory exists in the state backup repo
if [[ ! -d "$LOCAL_STATE_DIR/$PROJECT_NAME/backups" ]]; then
    echo "No backup directory found for project $PROJECT_NAME. Creating it..."
    mkdir -p "$LOCAL_STATE_DIR/$PROJECT_NAME/backups"
fi

#find the latest backup directory in VCS
LATEST_BACKUP=$(ls -td "$LOCAL_STATE_DIR/$PROJECT_NAME/backups/"*/ 2>/dev/null | head -1)

if [[ -z "$LATEST_BACKUP" ]]; then
    echo "No backups found in VCS for $PROJECT_NAME. Skipping sync."
    exit 0
fi

LATEST_REMOTE_FILE="$LATEST_BACKUP/terraform.tfstate"

#if no remote state file exists, exit
if [[ ! -f "$LATEST_REMOTE_FILE" ]]; then
    echo "No terraform.tfstate file found in the latest VCS backup for $PROJECT_NAME. Skipping sync."
    exit 0
fi

#check if the local terraform state file exists
LOCAL_STATE_FILE="$PROJECT_DIRECTORY/terraform.tfstate"
if [[ -f "$LOCAL_STATE_FILE" ]]; then
    #compare timestamps of local and remote state files
    REMOTE_TIMESTAMP=$(stat -c %Y "$LATEST_REMOTE_FILE")
    LOCAL_TIMESTAMP=$(stat -c %Y "$LOCAL_STATE_FILE")

    if [[ "$REMOTE_TIMESTAMP" -le "$LOCAL_TIMESTAMP" ]]; then
        echo "Local terraform.tfstate is up to date. No changes needed."
        exit 0
    fi
fi

#if the remote version is newer, update both local backup and project directory
echo "Updating terraform state from VCS..."
cp "$LATEST_REMOTE_FILE" "$LOCAL_STATE_DIR/$PROJECT_NAME/terraform.tfstate"
cp "$LATEST_REMOTE_FILE" "$PROJECT_DIRECTORY/terraform.tfstate"

echo "TFstate successfully updated for $PROJECT_NAME from latest VCS backup."
