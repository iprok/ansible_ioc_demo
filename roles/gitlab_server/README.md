# gitlab_server

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [gitlab_config_file](#gitlab_config_file)
  - [gitlab_package_state](#gitlab_package_state)
  - [gitlab_prerequisites](#gitlab_prerequisites)
  - [gitlab_runner_description](#gitlab_runner_description)
  - [gitlab_runner_executor](#gitlab_runner_executor)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### gitlab_config_file

#### Default value

```YAML
gitlab_config_file: /etc/gitlab/gitlab.rb
```

### gitlab_package_state

#### Default value

```YAML
gitlab_package_state: present
```

### gitlab_prerequisites

#### Default value

```YAML
gitlab_prerequisites:
  - curl
  - openssh-server
  - ca-certificates
  - tzdata
  - perl
```

### gitlab_runner_description

#### Default value

```YAML
gitlab_runner_description: Shared Executor Runner on ProxMox
```

### gitlab_runner_executor

#### Default value

```YAML
gitlab_runner_executor: shell
```

## Discovered Tags

**_add_repo_**

**_apply_config_**

**_bootstrap_**

**_config_**

**_configure_settings_**

**_install_app_**

**_install_prereqs_**

**_runner_**

**_setup_runner_**

## Dependencies

None.
