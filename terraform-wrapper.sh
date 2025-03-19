#!/bin/bash

source "$HOME/.terraform-automation/env.sh"

S3_BUCKET="$S3_BUCKET_TF"
PROJECT_NAME=$(basename "$PWD")
S3_STATE_FILE="s3://$S3_BUCKET/$PROJECT_NAME/terraform.tfstate"
LOCAL_STATE_FILE="$PWD/terraform.tfstate"
LOCAL_STATE_FILE_BACKUP="$PWD/terraform.tfstate.backup"

if ! command -v aws &>/dev/null; then
    echo "AWS CLI not found. Please install and configure it."
    exit 1
fi

if [[ "$1" == "apply" || "$1" == "destroy" || "$1" == "import" ]]; then
    if [[ ! -f "$LOCAL_STATE_FILE" ]]; then
        if aws s3 ls "$S3_STATE_FILE" &>/dev/null; then
            echo "Fetching latest Terraform state from S3..."
            aws s3 cp "$S3_STATE_FILE" "$LOCAL_STATE_FILE"
        else
            echo "No Terraform state found in S3. Proceeding without it."
        fi
    else
        echo "Local Terraform state already exists. Skipping S3 download."
    fi
fi


terraform "$@"
EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
    echo "Terraform command failed with exit code $EXIT_CODE. Keeping local state file for debugging."
    exit $EXIT_CODE 
fi

if [[ "$1" == "apply" || "$1" == "destroy" || "$1" == "import" ]]; then
    if [[ -f "$LOCAL_STATE_FILE" ]]; then
        if ! aws s3 ls "$S3_STATE_FILE" &>/dev/null; then
            echo "Creating empty Terraform state file in S3..."
            touch temp-empty.tfstate
            aws s3 cp temp-empty.tfstate "$S3_STATE_FILE"
            rm temp-empty.tfstate
        fi

        echo "Uploading updated Terraform state to S3..."
        aws s3 cp "$LOCAL_STATE_FILE" "$S3_STATE_FILE"

        rm -f "$LOCAL_STATE_FILE"
        rm -f "$LOCAL_STATE_FILE_BACKUP"
        echo "Local Terraform state file removed."
    else
        echo "No local Terraform state file found. Nothing to upload."
    fi
fi
