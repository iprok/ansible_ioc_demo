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
  |  |--pve-02.example.com
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
*   **ProxMox Integration**: The `community.proxmox.proxmox` inventory plugin can query your hypervisors directly to build groups of active virtual machines on-the-fly.
*   **Zabbix Integration**: You can use the `community.zabbix.zabbix` inventory plugin to query Zabbix hosts, host groups, and statuses to dynamically build your target node list.
*   **Custom Dynamic Inventories**: If you have a legacy database or custom API, you can write a simple python or shell script that outputs a standard JSON structure of groups and variables. If you pass this executable script to Ansible as an inventory (`ansible-playbook -i custom_inventory.py site.yml`), Ansible will execute it and use the dynamic output.

This guarantees that your playbooks always target the exact active configuration without requiring manual files updates.

### 2. Execution Flowchart (Playbook Graphing)
To visualize the execution order, roles, and tasks defined in your playbook, use the **`ansible-playbook-grapher`** tool.

This utility parses `site.yml` and renders an SVG or PNG flowchart:

```bash
# Install the visualizer tool
pip install ansible-playbook-grapher

# Generate an SVG graph of the playbook with collapsible nodes
ansible-playbook-grapher site.yml --include-role-tasks --collapsible-nodes -o infrastructure_flow.svg
```

The resulting file [infrastructure_flow.svg](infrastructure_flow.svg) can be opened in any web browser to view an interactive flowchart showing:
* Target hosts for each phase.
* Triggered roles.
* Tasks executed sequentially.
* Tags attached to tasks for selective execution.

### 3. Role and Variables Documentation
To document input variables, defaults, and tags of your roles automatically, you can use **`ansible-doctor`**. It parses your `roles/` directory and creates readable markdown documentation:

```bash
# Generate markdown documentation for roles
pip install ansible-doctor
ansible-doctor -f -r roles/
```

### 4. Dynamic Infrastructure Fact Audit
Instead of documenting system configurations manually, you can query live facts from all targets in a single run:

```bash
ansible all -m setup --tree /tmp/facts_documentation
```
Ansible gathers detailed JSON parameters from each machine (OS version, disk allocation, network interfaces, CPU cores, RAM). These logs can be formatted into an HTML summary report to view live asset specifications in one click.

---

## 🏢 Centralized Execution Platforms (Ansible Tower / AWX & Semaphore)

In enterprise environments, running playbooks from local developer terminals is usually discouraged. Instead, centralized automation platforms are used to orchestrate runs, manage credentials, and audit executions.

### 1. Red Hat Ansible Tower (AWX / Automation Controller)
**Ansible Tower** (and its open-source upstream version **AWX**, now officially called **Automation Controller**) is the standard enterprise control plane for Ansible.
*   **Web Console & REST API**: Provides a graphic user interface and REST API to trigger, monitor, and schedule playbooks.
*   **Role-Based Access Control (RBAC)**: Restricts who can execute specific playbooks on specific host groups.
*   **Centralized Credential Store**: Integrates with external vaults (like HashiCorp Vault, CyberArk, or Bitwarden) to inject SSH keys and vault credentials securely into execution contexts at runtime, without developers ever seeing them.
*   **Audit Logging**: Logs every task execution and output for enterprise compliance.

### 2. Ansible Semaphore
**Ansible Semaphore** is a modern, lightweight, open-source web UI alternative to Ansible Tower.
*   **Resource Friendly**: Written in Go, it requires very little CPU and memory, making it ideal for smaller teams, edge environments, or resource-constrained deployments where AWX/Tower is too heavy.
*   **Simple Web UI**: Offers a clean, minimal dashboard to manage keys, repositories, inventories, and task templates.
*   **REST API**: Includes a full API for triggering playbook runs from external hooks (such as GitLab CI/CD webhooks).
