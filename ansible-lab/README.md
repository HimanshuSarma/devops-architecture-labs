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