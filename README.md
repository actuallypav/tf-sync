# Terraform Synchronisation Tool
## Overview  
This system automates **Terraform state backup and sync** using AWS S3. It ensures:  
- Automatic state backups on every `terraform apply`, `destroy`, etc.  
- State sync from S3 before running Terraform to ensure consistency.  
- Easy deployment using `make install`.  
- **Support for multiple shells (Bash, Zsh, Fish)**
**Note:** This setup **does not support Windows**. It is designed for Linux and macOS systems.
Additionally, it does not use lock files - therefore multiple applies to the same files at the same time could cause issues.
## Installation  
Run the following command to install the Terraform state sync system:  
```bash
make install SHELL_TYPE=<shell>
```
Replace `<shell>` with one of:
- `bash` → for Linux (default shell on many distributions)
- `zsh` → for macOS (default shell)
- `fish` → for Fish shell users
If you don't specify a shell, it will default to Bash.
This will:  
- Install Terraform wrapper (`terraform-wrapper.sh`)  
- Set up aliases (`terraform → wrapper`)  
- Store Terraform state in an AWS S3 bucket  
- Enable state retrieval before running Terraform commands  
## How It Works  
### 1. Automatic State Backup  
Every time you run:
```bash
terraform apply
terraform destroy
terraform import ...
terraform state mv ...
terraform state rm ...
terraform plan
```
The system automatically backs up the Terraform state to an **AWS S3 bucket**.  
### 2. State Sync from S3  
Before running Terraform commands (`apply`, `destroy`, `import`), the wrapper script:
- Checks if a local state file exists.
- If not, it fetches the latest state from **S3**.
- Ensures the latest state is always available.
This prevents **state loss** and **conflicts**.
### 3. Project Name & S3 Structure  
Your Terraform project folder name must match the folder name in the S3 bucket.  
For example, if your Terraform project is in `~/repos/MyProject`, state backups will be stored in:  
```bash
s3://my-terraform-state-bucket/MyProject/terraform.tfstate
```
If your Terraform project is named `foobar`, the script will store the state in `foobar` inside the S3 bucket.  
## Uninstall  
To remove everything:  
```bash
rm -rf ~/.terraform-automation

# Remove aliases based on the shell
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.bashrc
fi
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.zshrc
fi
if [ -f "$HOME/.config/fish/config.fish" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.config/fish/config.fish
fi
```
