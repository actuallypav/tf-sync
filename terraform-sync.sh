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

#ensure the project directory exists in the state backup repo
if [[ ! -d "$LOCAL_STATE_DIR/$PROJECT_NAME" ]]; then
    echo "No backup directory found for project $PROJECT_NAME. Creating it..."
    mkdir -p "$LOCAL_STATE_DIR/$PROJECT_NAME/backups"
fi

#copy latest state file into the current project
cp "$LOCAL_STATE_DIR/terraform.tfstate" "$PWD/terraform.tfstate"

echo "TFstate successfully synced for $PROJECT_NAME."