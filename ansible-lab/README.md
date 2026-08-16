# Ansible Multi-Node Container Configuration Lab

---

## 📄 Project Overview & Purpose

> ### **System Purpose**
> **Core Objective:** A hands-on configuration management lab demonstrating automated SSH orchestration and group-based variable inheritance across isolated container targets on `localhost`. The lab simulates multi-environment server fleets by configuring custom ports, group variables, privileges, and connection properties via **Ansible**.

---

## ⚡ Core Architecture & Key Features

* **Local Multi-Container SSH Orchestration**  
  Simulates multi-node Linux environments on `127.0.0.1` by mapping SSH daemon ports (`2221`–`2224`) across distinct container targets (`backend-server-0` to `3`).

* **Group-Based Inventory Management**  
  Organizes target nodes into distinct logical groups (`backend_servers_group1`, `backend_servers_group2`) within `hosts.ini` for targeted playbook execution and modular configuration management.

* **Declarative Variable Inheritance (`group_vars`)**  
  Leverages Ansible's directory hierarchy (`group_vars/`) to declaratively manage environment variables (`app_port`, `max_connections`, `ssl_enabled`, `env`) and SSH authentication credentials per server group.

* **Non-Interactive Privilege Escalation**  
  Configures `ansible_become_password` alongside standard SSH auth properties to allow seamless, non-interactive `sudo` privilege escalation during playbook execution.

---

## 🏗️ Implementation Flow & Component Breakdown

### 1. Configuration & Inventory Structure
├── ansible.cfg                          # Central Ansible settings (default inventory, SSH key checks disabled)
├── hosts.ini                            # INI inventory mapping custom ports to container targets
└── group_vars/
└── backend_servers_group1.yaml      # Group-level variables, SSH credentials & privilege configs

### 2. File Configurations

#### **`ansible.cfg`**
Disables host key prompts and sets automatic Python interpreter discovery for seamless local execution:
```ini
[defaults]
inventory = hosts.ini
host_key_checking = False
interpreter_python = auto_silent


flowchart TD
    subgraph ControlPlane["Ansible Control Node (Local Host)"]
        AC["ansible.cfg"]
        INV["hosts.ini\n(Inventory)"]
        GV["group_vars/backend_servers_group1.yaml\n(Variables & Credentials)"]
        Engine["Ansible Orchestration Engine"]
        
        AC --> Engine
        INV --> Engine
        GV --> Engine
    end

    subgraph ContainerFleet["Target Container Fleet (Localhost)"]
        subgraph Group1["backend_servers_group1"]
            C0["backend-server-0\n(127.0.0.1:2221)"]
            C1["backend-server-1\n(127.0.0.1:2222)"]
        end

        subgraph Group2["backend_servers_group2"]
            C2["backend-server-2\n(127.0.0.1:2223)"]
            C3["backend-server-3\n(127.0.0.1:2224)"]
        end
    end

    %% SSH Connections
    Engine -->|SSH Auth + Become Pass| C0
    Engine -->|SSH Auth + Become Pass| C1
    Engine -->|SSH Auth| C2
    Engine -->|SSH Auth| C3