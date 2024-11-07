# Ansible Config for Next.js Todo Application

This project is used to configure our EC2 instance in order to deploy our Next.js after Terraform has provisioned the resources.

## Ansible Installation Windows

Installlation of Ansible is straight forward except for Windows. For Windows, you need to install wsl or install a VM and run Ansible from there. To simplify things, we will use wsl.

First, open a Powershell and run the command below.

```bash
wsl --install
```

After the installation, you might need to restart your machine for the installation to take effect.

Open the Ubuntu Application, you can search for the app in your windows search bar.

Once Ubuntu is opened, run the commands below.

```bash
sudo apt update && sudo apt install ansible
```

After this, mount the driver where the project is located.

```bash
cd /mnt/c
```

Next, cd into the root of the ansible project where the playbook is located.

Remember to update the ansible.cfg and inventory.ini based on your setup.

Then run the command below.

```bash
ansible-playbook playbook.yml
```