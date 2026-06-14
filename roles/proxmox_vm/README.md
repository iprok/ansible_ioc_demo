# proxmox_vm

## Table of contents

- [Requirements](#requirements)
- [Default Variables](#default-variables)
  - [pve_bridge](#pve_bridge)
  - [pve_node](#pve_node)
  - [pve_storage](#pve_storage)
  - [pve_template](#pve_template)
  - [pve_vm_cores](#pve_vm_cores)
  - [pve_vm_disk_size](#pve_vm_disk_size)
  - [pve_vm_ram](#pve_vm_ram)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## Requirements

None.

## Default Variables

### pve_bridge

#### Default value

```YAML
pve_bridge: "{{ pve_default_bridge | default('vmbr0') }}"
```

### pve_node

#### Default value

```YAML
pve_node: "{{ pve_default_node | default('pve-01') }}"
```

### pve_storage

#### Default value

```YAML
pve_storage: "{{ pve_default_storage | default('local-lvm') }}"
```

### pve_template

#### Default value

```YAML
pve_template: "{{ pve_default_template | default('ubuntu-22.04-cloudinit-template') }}"
```

### pve_vm_cores

#### Default value

```YAML
pve_vm_cores: 1
```

### pve_vm_disk_size

#### Default value

```YAML
pve_vm_disk_size: 10G
```

### pve_vm_ram

#### Default value

```YAML
pve_vm_ram: 1024
```

## Discovered Tags

**_provision_**

**_vm_clone_**

**_vm_config_**

**_vm_network_**

**_vm_start_**

## Dependencies

None.
