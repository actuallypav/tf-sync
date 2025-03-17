#!/bin/bash

#external git repo for storing state files (make sur it's private and not public)
STATE_REPO="git@github.com:yourusername/terraform-state-storage.git"
LOCAL_STATE_DIR="$HOME/.terraform-state-backups"

#get the name of the current project
PROJECT_NAME=$(basename "$PWD")

#ensure the local backup directory exists
mkdir -p "$LOCAL_STATE_DIR"

if [[ ! -d "$LOCAL_STATE_DIR/.git" ]]; then
    echo "Cloning TFstate backup repo..."
    git clone "$STATE_REPO" "$LOCAL_STATE_DIR"
else
    echo "Updating  TFstate repo..."
    cd "$LOCAL_STATE_DIR"
    git pull origin main
fi

#locate the latest state backup for the current project
LATEST_STATE=$(ls -td "$LOCAL_STATE_DIR/$PROJECT_NAME/backups/"*/ | head -1)
if [[ -z "$LATEST_STATE" ]]; then
    echo "No state backup found for project $PROJECT_NAME."
    exit 1
fi

#copy latest state file into the current project
cp "$LATEST_STATE/terraform.tfstate" "$PWD/terraform.tfstate"

echo "TFstate successfully synced for $PROJECT_NAME."