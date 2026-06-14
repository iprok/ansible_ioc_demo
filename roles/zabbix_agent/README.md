# zabbix_agent

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [zabbix_agent_config_path](#zabbix_agent_config_path)
  - [zabbix_agent_package](#zabbix_agent_package)
  - [zabbix_agent_state](#zabbix_agent_state)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### zabbix_agent_config_path

#### Default value

```YAML
zabbix_agent_config_path: /etc/zabbix/zabbix_agentd.conf
```

### zabbix_agent_package

#### Default value

```YAML
zabbix_agent_package: zabbix-agent
```

### zabbix_agent_state

#### Default value

```YAML
zabbix_agent_state: present
```

## Discovered Tags

**_add_repo_**

**_bootstrap_**

**_config_**

**_configure_agent_**

**_install_agent_**

**_register_monitoring_**

**_start_agent_**

## Dependencies

None.
