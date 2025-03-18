INSTALL_DIR := $(HOME)/.terraform-automation
STATE_REPO := git@github.com:actuallypav/TFsync.git
LOCAL_STATE_DIR := $(HOME)/.terraform-state-backups
SHELL_TYPE := bash

ifeq ($(SHELL_TYPE),bash)
    SHELL_CONFIG := $(HOME)/.bashrc
else ifeq ($(SHELL_TYPE),zsh)
    SHELL_CONFIG := $(HOME)/.zshrc
else ifeq ($(SHELL_TYPE),fish)
    SHELL_CONFIG := $(HOME)/.config/fish/config.fish
else
    SHELL_CONFIG :=
    $(error Unsupported shell: $(SHELL_TYPE))
endif

.PHONY: install backup-alias sync-alias crontab-setup

install:
	@echo "Creating installation directory..."
	@mkdir -p $(INSTALL_DIR)
	@echo "Copying scripts..."
	@sed 's|STATE_REPO=.*|STATE_REPO=$(STATE_REPO)|; s|LOCAL_STATE_DIR=.*|LOCAL_STATE_DIR=$(LOCAL_STATE_DIR)|' terraform-wrapper.sh > $(INSTALL_DIR)/terraform-wrapper.sh
	@sed 's|STATE_REPO=.*|STATE_REPO=$(STATE_REPO)|; s|LOCAL_STATE_DIR=.*|LOCAL_STATE_DIR=$(LOCAL_STATE_DIR)|' terraform-sync.sh > $(INSTALL_DIR)/terraform-sync.sh
	@chmod +x $(INSTALL_DIR)/terraform-wrapper.sh
	@chmod +x $(INSTALL_DIR)/terraform-sync.sh
	@echo "Cloning or updating state repo..."
	@if [ ! -d "$(LOCAL_STATE_DIR)/.git" ]; then \
		git clone $(STATE_REPO) $(LOCAL_STATE_DIR); \
	else \
		cd $(LOCAL_STATE_DIR) && git pull origin main; \
	fi
	@$(MAKE) backup-alias
	@$(MAKE) sync-alias
	@$(MAKE) crontab-setup
	@echo "✅ TF state sync setup complete!"

backup-alias:
	@echo "Adding terraform backup alias..."
	@if ! grep -q "alias terraform=" $(SHELL_CONFIG); then \
		echo "alias terraform='$(INSTALL_DIR)/terraform-wrapper.sh'" >> $(SHELL_CONFIG); \
	fi

sync-alias:
	@echo "Adding terraform sync alias..."
	@if ! grep -q "alias terraform-sync=" $(SHELL_CONFIG); then \
		echo "alias terraform-sync='$(INSTALL_DIR)/terraform-sync.sh'" >> $(SHELL_CONFIG); \
	fi

crontab-setup:
	@echo "Ensuring terraform-sync runs at startup..."
	@(crontab -l 2>/dev/null | grep -Fq "@reboot $(INSTALL_DIR)/terraform-sync.sh") || \
	(crontab -l 2>/dev/null; echo "@reboot $(INSTALL_DIR)/terraform-sync.sh") | crontab -