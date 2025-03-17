# Terraform State Sync & Backup (`tf-sync-setup.sh`)

## Overview  
This script automates **Terraform state backup and sync** using GitHub. It ensures:  
- Automatic state backups on every `terraform apply`, `destroy`, etc.  
- State sync from GitHub on system boot or when running `terraform-sync`.  
- Easy deployment with a single script.  
- **Support for multiple shells (Bash, Zsh, Fish)**

**Note:** This script **does not support Windows**. It is designed for Linux and macOS systems.

---

## Installation  
Run the following commands to install the Terraform state sync system:  

```bash
chmod +x tf-sync-setup.sh
./tf-sync-setup.sh <shell>
```

Replace `<shell>` with one of:
- `bash` → for Linux (default shell on many distributions)
- `zsh` → for macOS (default shell)
- `fish` → for Fish shell users

If you don't specify a shell, the script will detect your current shell automatically.

This will:  
- Install Terraform wrapper (`terraform-wrapper.sh`)  
- Install Sync script (`terraform-sync.sh`)  
- Set up aliases (`terraform → wrapper, terraform-sync`)  
- Enable auto-sync on system startup (for Bash & Zsh)  
- Clone or update the Terraform state backup repository from GitHub  

---

## How It Works  

### 1. Automatic State Backup  
Every time you run:

```bash
terraform apply
tf destroy
tf import ...
tf state mv ...
tf state rm ...
```

The script automatically backs up the Terraform state to a GitHub repository (`terraform-state-storage`).  

---

### 2. Project Name & Repository Structure  
Your Terraform project folder name must match the folder name in the state backup repository.  

For example, if your Terraform project is in `~/repos/MyProject`, state backups will be stored in:  

```bash
terraform-state-storage/
│── MyProject/   
│   ├── backups/
│   │   ├── 2025-03-16_12-00-00/terraform.tfstate
│   │   ├── 2025-03-17_15-30-00/terraform.tfstate
```

If your Terraform project is named `foobar`, the script will store the state in `foobar` inside the backup repository.  

---

### 3. State Sync (`terraform-sync`)  
To pull the latest Terraform state from GitHub, run:  

```bash
terraform-sync
```

or simply restart your system (sync runs automatically on boot for Bash & Zsh users).  

---

## Uninstall  
To remove everything:  

```bash
rm -rf ~/.terraform-automation

# Remove aliases based on the shell
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.bashrc
    sed -i '/terraform-sync.sh/d' ~/.bashrc
fi
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.zshrc
    sed -i '/terraform-sync.sh/d' ~/.zshrc
fi
if [ -f "$HOME/.config/fish/config.fish" ]; then
    sed -i '/terraform-wrapper.sh/d' ~/.config/fish/config.fish
    sed -i '/terraform-sync.sh/d' ~/.config/fish/config.fish
fi

# Remove cron job
crontab -l | grep -v 'terraform-sync.sh' | crontab -
```

---

## Next Steps  
- Encryption before pushing state files?  
- Backups on multiple platforms (GitHub + S3)?  
- Windows version?

Let me know via issues.