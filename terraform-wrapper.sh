#!/bin/bash

#external Git repo for storing state files (make sure it's private)
STATE_REPO="git@github.com:yourusername/terraform-state-storage.git"
LOCAL_STATE_DIR="$HOME/.terraform-state-backups"

# Get the name of the current project
PROJECT_NAME=$(basename "$PWD")
PROJECT_DIR="$PWD"  # Store the original directory

#ensure the local backup directory exists
mkdir -p "$LOCAL_STATE_DIR"

#clone the state repo if it does not exist
if [[ ! -d "$LOCAL_STATE_DIR/.git" ]]; then
    echo "Cloning TF State Backup repo..."
    git clone "$STATE_REPO" "$LOCAL_STATE_DIR"
else
    echo "Updating TF State Backup repo..."
    cd "$LOCAL_STATE_DIR" && git pull origin main
fi

#ensure project directory and backups folder exist
if [[ ! -d "$LOCAL_STATE_DIR/$PROJECT_NAME/backups" ]]; then
    echo "Creating backup directory for project '$PROJECT_NAME'..."
    mkdir -p "$LOCAL_STATE_DIR/$PROJECT_NAME/backups"
fi

#return to the Terraform project directory before running Terraform commands
cd "$PROJECT_DIR"

#run Terraform command
terraform "$@"

#list of commands that modify the TF state
if [[ "$1" == "apply" || "$1" == "destroy" || "$1" == "import" || "$1" == "state" ]]; then
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="$LOCAL_STATE_DIR/$PROJECT_NAME/backups/$TIMESTAMP"

    mkdir -p "$BACKUP_DIR"

    if [[ -f "terraform.tfstate" ]]; then
        cp terraform.tfstate "$BACKUP_DIR/terraform.tfstate"

        cd "$LOCAL_STATE_DIR"

        git add "$BACKUP_DIR/terraform.tfstate"
        git commit -m "Backup TF state for $PROJECT_NAME after $1 at $TIMESTAMP"
        git push origin main

        echo "Terraform state successfully backed up to $STATE_REPO in $PROJECT_NAME folder."
    else
        echo "⚠️ No terraform.tfstate file found. Backup skipped."
    fi
fi
