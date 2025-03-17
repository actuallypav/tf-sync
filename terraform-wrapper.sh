#!/bin/bash

#external git repo for storing state files (make sur it's private and not public)
STATE_REPO="git@github.com:yourusername/terraform-state-storage.git"
LOCAL_STATE_DIR="$HOME/.terraform-state-backups"

#get the name of the current project
PROJECT_NAME=$(basename "$PWD")

#ensure the local backup directory exists
mkdir -p "$LOCAL_STATE_DIR"

#clone the state repo id it does not exist
if [[ ! -d "$LOCAL_STATE_DIR/.git" ]]; then
    echo "Cloning TF State Backup repo..."
    git clone "$STATE_REPO" $LOCAL_STATE_DIR
fi

#run terraform command
terraform "$@"

#list of commands that modify the tfstate
if [[ "$1" == "apply" || "$1" == "destroy" || "$1" == "import" || "$1" == "state" ]]; then
    TIMESTAMP=$(date + "%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="$LOCAL_STATE_DIR/$PROJECT_NAME/backups/$TIMESTAMP"

    cs "$LOCAL_STATE_DIR"

    git add "$BACKUP_DIR/terraform.tfstate"
    git commit -m "Backup TFstate for $PROJECT_NAME after $1 at $TIMESTAMP"

    #push to the external repo
    git push origin main

    echo "Terraform state successfully backed up to $STATE_REPO in $PROJECT_NAME folder."
fi