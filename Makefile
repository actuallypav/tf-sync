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

.PHONY: install terraform-setup tfsave-alias

install: terraform-setup tfsave-alias
	@echo "Creating installation directory..."
	@mkdir -p $(INSTALL_DIR)
	@echo "Copying scripts..."
	@cp terraform-wrapper.sh $(INSTALL_DIR)/terraform-wrapper.sh
	@chmod +x $(INSTALL_DIR)/terraform-wrapper.sh
	@echo "Terraform automation setup complete!"

terraform-setup:
	@echo "Initializing Terraform..."
	@terraform init
	@echo "Applying Terraform configuration to create S3 bucket..."
	@terraform apply -auto-approve > tf_output.log
	@echo "Extracting S3 bucket name..."
	@BUCKET_NAME=$$(terraform output -raw s3_bucket_name); \
		echo "S3 Bucket Name: $$BUCKET_NAME"; \
		echo "export S3_BUCKET_TF=$$BUCKET_NAME" >> $(HOME)/.terraform-automation/env.sh
	@echo "Terraform setup complete!"

tfsave-alias:
	@echo "Adding terraform alias..."
	@if ! grep -q "source $(HOME)/.terraform-automation/env.sh" $(SHELL_CONFIG); then \
		echo "source $(HOME)/.terraform-automation/env.sh" >> $(SHELL_CONFIG); \
	fi
	@if ! grep -q "alias terraform=" $(SHELL_CONFIG); then \
		echo "alias terraform='$(INSTALL_DIR)/terraform-wrapper.sh'" >> $(SHELL_CONFIG); \
	fi
