#!/bin/bash

#external git repo for storing state files (make sur it's private and not public)
INSTALL_DIR="$HOME/.terraform-automation"
STATE_REPO="git@github.com:yourusername/terraform-state-storage.git"
LOCAL_STATE_DIR="$HOME/.terraform-state-backups"
SCTIPR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#detect shell from arhument or use default
SHELL_TYPE="$1"

if [[ -z "$SHELL_TYPE" ]]; then
echo "No shell type provided. Using default $SHELL"
SHELL_TYPE=$(basename "$SHELL")
fi

#determine the correct shell config file
case "$SHELL_TYPE" in
    bash)
    SHELL_CONFIG="$HOME/.bashrc"
    ;;
    zsh)
    SHELL_CONFIG="$HOME/.zshrc"
    ;;
    fish)
    SHELL_CONFIG="$HOME/.config/fish/config.fish"
    ;;
    *)
    echo "Unsupported shell: $SHELL_TYPE"
    exit 1
    ;;
esac

#create an install directory
mkdir -p "$INSTALL_DIR"

#copy the tf wrapper/sync scripts - make them executable
cp "$SCRIPT_DIR/terraform-wrapper.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/terraform-sinc.sh" "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/terraform-wrapper.sh"
chmod +x "$INSTALL_DIR/terraform-sync.sh"

#clone the github repo if it's not there already
if [[ ! -d "$LOCAL_STATE_DIR/.git" ]]; then
echo "Cloning private TFstate backup repo..."
git clone "$STATE_REPO" "$LOCAL_STATE_DIR"
else
echo "TFstate backup repo already exists. Pulling latest changes..."
cd "$LOCAL_STATE_DIR" && git pull origin main
fi

#add tf-wrapper alias (overriedes Terraform with our auto-backup version)
if ! grep -q "alias terraform-sync=" "$SHELL_CONFIG"; then
echo "alias terraform='$INSTALL_DIR/terraform-wrapper.sh'" >> "$SHELL_CONFIG"
fi

if ! grep -q "alias terraform-sync=" "$SHELL_CONFIG"; then
echo "alias terraform-sync='$INSTALL_DIR/terraform-sync.sh'" >> "$SHELL_CONFIG"
fi

#ensure tf sync runs at startup
(crontab -l 2>/dev/null | grep -Fq "@reboot $INSTALL_DIR/terraform-sync.sh") || \
(crontab -l 2>/dev/null; echo "@reboot $INSTALL_DIR/terraform-sync.sh") | crontab -

#apply alias changes
source "$HSHELL_CONFIG

echo "TF state sync setup complete!"
echo "✅ Private state repository cloned at $LOCAL_STATE_DIR"
echo "✅ Run 'terraform' for normal Terraform commands with an auto-backup feature."
echo "✅ Run 'terraform-sync' to sync the latest state files."