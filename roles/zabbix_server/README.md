# zabbix_server

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [zabbix_db_host](#zabbix_db_host)
  - [zabbix_db_packages](#zabbix_db_packages)
  - [zabbix_server_package_state](#zabbix_server_package_state)
  - [zabbix_server_packages](#zabbix_server_packages)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### zabbix_db_host

#### Default value

```YAML
zabbix_db_host: localhost
```

### zabbix_db_packages

#### Default value

```YAML
zabbix_db_packages:
  - mariadb-server
  - python3-pymysql
```

### zabbix_server_package_state

#### Default value

```YAML
zabbix_server_package_state: present
```

### zabbix_server_packages

#### Default value

```YAML
zabbix_server_packages:
  - zabbix-server-mysql
  - zabbix-frontend-php
  - zabbix-apache-conf
  - zabbix-sql-scripts
```

## Discovered Tags

**_add_repo_**

**_bootstrap_**

**_check_db_**

**_config_**

**_configure_db_**

**_configure_settings_**

**_import_schema_**

**_install_app_**

**_install_db_**

**_start_services_**

## Dependencies

None.
