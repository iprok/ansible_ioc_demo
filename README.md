# Infrastructure as Code (IaC) with Ansible

This repository is a demonstration project showcasing the **Infrastructure as Code (IaC)** concept. It describes the automated deployment and configuration of an infrastructure environment consisting of a **ProxMox** hypervisor, a **GitLab** version control system, and a **Zabbix** monitoring platform.

The entire configuration is declarative: the actual state of the servers, virtual machines, and services is driven directly by this codebase.

---

## 📂 Repository Structure

```text
ansible_demo/
├── ansible.cfg          # Global Ansible configuration settings (defines vault script)
├── hosts.yml            # Inventory file (the map of our infrastructure)
├── group_vars/          # Configuration variables for host groups
│   ├── all/
│   │   ├── vars.yml     # Unencrypted global variables (timezone, DNS, etc.)
│   │   └── vault.yml    # Encrypted global secrets (passwords, tokens, API secrets)
│   ├── proxmox.yml      # Hypervisor variables (references vault secrets)
│   ├── gitlab.yml       # GitLab Server and Runner settings (references vault secrets)
│   └── zabbix.yml       # Zabbix Server and Agent settings (references vault secrets)
├── site.yml             # Master orchestrator playbook
├── scripts/
│   └── vault-bws-client.sh # Client script for Bitwarden Secrets Manager integration
└── roles/               # Isolated configuration roles for each component
    ├── proxmox_vm/      # Provisions VMs from templates in ProxMox (uses YAML anchors)
    ├── gitlab_server/   # Installs and configures GitLab + Runner
    ├── zabbix_server/   # Deploys Zabbix Server (safe database checks, templates)
    └── zabbix_agent/    # Installs Zabbix Agent and registers hosts via API
```

---

## 🛠️ How it Works (Sequential Deployment Flow)

The [site.yml](site.yml) master playbook executes configurations in sequence:

1. **Virtual Machine Provisioning**: Connects to the ProxMox API and clones VMs for GitLab, Zabbix, and application servers from templates, using specifications defined in [hosts.yml](hosts.yml).
2. **SSH Connection Check**: Waits for the SSH service to become active on all newly booted virtual machines.
3. **GitLab Deployment**: Installs GitLab on the designated virtual machine and registers a shared shell runner.
4. **Zabbix Server Deployment**: Installs the Zabbix Server, sets up the local MariaDB database, and launches the web dashboard.
5. **Monitoring Setup**: Installs the Zabbix Agent on all host nodes and automatically registers them with the Zabbix Server using the Zabbix API.

---

## 🔐 Secure Secret Management (Ansible Vault & Bitwarden)

For enterprise compliance, all passwords, API keys, and private tokens are isolated from the plaintext code and encrypted in [group_vars/all/vault.yml](group_vars/all/vault.yml).

### 1. Externalizing Decryption Keys

To avoid storing decryption passwords in plaintext files on disks, this repository is configured in [ansible.cfg](ansible.cfg) to query an executable lookup script:

```ini
[defaults]
vault_password_file = ./scripts/vault-bws-client.sh
```

### 2. Integration with Bitwarden Secrets Manager (`bws`)

The script [scripts/vault-bws-client.sh](scripts/vault-bws-client.sh) uses the Bitwarden Secrets Manager CLI (`bws`) to fetch the decryption password on-demand using its API Token:

```bash
#!/usr/bin/env bash
set -e
SECRET_UUID="456b3b29-1234-abcd-abcd-1234567890ab"
bws secret get "$SECRET_UUID" | jq -r '.value'
```

### 3. Execution

To run the playbooks, export your secure access token in your terminal session or CI/CD environment and start the execution:

```bash
export BWS_ACCESS_TOKEN="1.your_bws_access_token_here"
ansible-playbook site.yml
```

Ansible will query Bitwarden to decrypt secrets in memory on-the-fly without exposing them to files or terminal logs.

---

## 📊 Generating Visual Infrastructure Documentation

Ansible allows you to generate visual and interactive documentation of your infrastructure directly from the codebase, ensuring that your network diagrams and server configurations never fall out of date.

### 1. Host Relationships and Groups (Inventory Tree)

You can output a hierarchical visualization of all your host groups and server relationships using `ansible-inventory`:

```bash
ansible-inventory --graph
```

**Example output:**

```text
@all:
  |--@proxmox_hypervisors:
  |  |--pve-01.example.com
  |--@vms:
  |  |--@gitlab_servers:
  |  |  |--gitlab-vm.example.com
  |  |--@zabbix_servers:
  |  |  |--zabbix-vm.example.com
  |  |--@app_servers:
  |  |  |--app-vm-01.example.com
  |  |  |--app-vm-02.example.com
  |--@monitored_nodes:
  |  |--gitlab-vm.example.com
  |  |--zabbix-vm.example.com
  |  |--app-vm-01.example.com
  |  |--app-vm-02.example.com
```

### 1.1 Dynamic Inventories (ProxMox, Zabbix, and Custom Scripts)

While this demo uses a static [hosts.yml](hosts.yml) file, enterprise environments typically replace static inventories with **Dynamic Inventories**.

Ansible can query external systems at runtime to generate the list of target hosts automatically:

* **ProxMox Integration**: The `community.proxmox.proxmox` inventory plugin can query your hypervisors directly to build groups of active virtual machines on-the-fly.
* **Zabbix Integration**: You can use the `community.zabbix.zabbix` inventory plugin to query Zabbix hosts, host groups, and statuses to dynamically build your target node list.
* **Custom Dynamic Inventories**: If you have a legacy database or custom API, you can write a simple python or shell script that outputs a standard JSON structure of groups and variables. If you pass this executable script to Ansible as an inventory (`ansible-playbook -i custom_inventory.py site.yml`), Ansible will execute it and use the dynamic output.

This guarantees that your playbooks always target the exact active configuration without requiring manual files updates.
