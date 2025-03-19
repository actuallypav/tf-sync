INSTALL_DIR := $(HOME)/.terraform-automation
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

.PHONY: install terraform-setup backup-alias

install: terraform-setup backup-alias
	@echo "Creating installation directory..."
	@mkdir -p $(INSTALL_DIR)
	@echo "Copying scripts..."
	@chmod +x terraform-wrapper.sh
	@cp terraform-wrapper.sh $(INSTALL_DIR)/terraform-wrapper.sh
	@echo "Terraform automation setup complete!"

terraform-setup:
	@echo "Initializing Terraform..."
	@terraform init
	@echo "Applying Terraform configuration to create S3 bucket..."
	@terraform apply -auto-approve > tf_output.log
	@echo "Extracting S3 bucket name..."
	@BUCKET_NAME=$$(terraform output -raw s3_bucket_name); \
		echo "S3 Bucket Name: $$BUCKET_NAME"; \
		sed -i "s|S3_BUCKET=.*|S3_BUCKET=\"$$BUCKET_NAME\"|" $(INSTALL_DIR)/terraform-wrapper.sh
	@echo "Terraform setup complete!"

backup-alias:
	@echo "Adding terraform alias..."
	@if ! grep -q "alias terraform=" $(SHELL_CONFIG); then \
		echo "alias terraform='$(INSTALL_DIR)/terraform-wrapper.sh'" >> $(SHELL_CONFIG); \
	fi
