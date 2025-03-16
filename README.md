# Terraform State Sync & Backup (`tf-sync-setup.sh`)

## Overview  
This script automates **Terraform state backup and sync** using GitHub. It ensures:  
- Automatic state backups on every `terraform apply`, `destroy`, etc.  
- State sync from GitHub on system boot or when running `terraform-sync`.  
- Easy deployment with a single script.  

---

## Installation  
Run the following commands to install the Terraform state sync system:  

```bash
chmod +x tf-sync-setup.sh
./tf-sync-setup.sh
```

This will:  
- Install Terraform wrapper (`terraform-wrapper.sh`)  
- Install Sync script (`terraform-sync.sh`)  
- Set up aliases (`terraform → wrapper, terraform-sync`)  
- Enable auto-sync on system startup  

---

## How It Works  

### 1. Automatic State Backup  
Every time you run:

```bash
terraform apply
terraform destroy
terraform import ...
terraform state mv ...
terraform state rm ...
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

If your Terraform project is named `"foobar"`, the script will store the state in `"foobar"` inside the backup repository.  

---

### 3. State Sync (`terraform-sync`)  
To pull the latest Terraform state from GitHub, run:  

```bash
terraform-sync
```

or simply restart your system (sync runs automatically on boot).  

---

## Uninstall  
To remove everything:  

```bash
rm -rf ~/.terraform-automation
sed -i '/terraform-wrapper.sh/d' ~/.bashrc
sed -i '/terraform-sync.sh/d' ~/.bashrc
crontab -l | grep -v 'terraform-sync.sh' | crontab -
```

---

## Next Steps  
- Want encryption before pushing state files?  
- Need backups on multiple platforms (GitHub + S3)?  

Let me know what you need.
