# Development Container (Dev-Container)

## 📌 **Overview**

This project provides a **fully equipped development container** (`dev-container`) using **Docker and Docker Compose**. The container includes **essential DevOps tools** such as:

- **Programming Languages:** Python, Go
- **Infrastructure Tools:** Terraform, Ansible, Kubernetes CLI (kubectl), Skaffold, AWS CLI, Azure CLI
- **Development Utilities:** Vim, Nano, fzf, jq, htop, tree
- **Security & SSH:** SSH pass, PowerShell
- **Custom CLI Enhancements:** pyenv, kubectx, kubens

## 🚀 **Getting Started**

### 1️⃣ **Prerequisites**

Ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### 2️⃣ **Clone the Repository**

```sh
 git clone https://github.com/sohaib1khan/dev_container.git
 cd Dev_Container_workspace
```

### 3️⃣ **Build & Start the Dev Container**

Run the `build-dev-container.sh` script to **build and start the container**:

```sh
 ./build-dev-container.sh
```

You'll see a menu with the following options:

- `1) Build or Rebuild the Container`
- `2) Start the Container (Use Existing Image)`
- `3) Exec into the Running Container`
- `4) Cleanup Docker (Keep Mounted Data)`
- `5) Exit`

Choose an option based on your needs.

### 4️⃣ **Exec into the Container**

To enter the container and start working:

```sh
 docker exec -it dev-container bash
```

### 5️⃣ **Stop the Container**

```sh
 docker compose down
```

## 🔧 **Container Details**

### 🛠 **Technologies Installed**

| Category | Tools Installed |
| --- | --- |
| 🖥 OS | Ubuntu 22.04 |
| 🔧 DevOps Tools | Terraform, Ansible, AWS CLI, Azure CLI, Skaffold, Kubernetes CLI (kubectl) |
| 📜 Scripting | Python3, GoLang, PowerShell |
| 🔍 Debugging | htop, jq, tree, net-tools, iputils-ping, dnsutils |
| 💡 Development | Vim, Nano, fzf (Ctrl+R enabled), Make |
| 🔑 Security & SSH | SSH Pass, OpenSSH |

### 📂 **Mounted Volumes**

The container mounts several **host directories** to persist user settings:

| Host Path | Container Path | Purpose |
| --- | --- | --- |
| `~/.aws` | `/home/devuser/.aws` | AWS CLI configuration |
| `~/.kube` | `/home/devuser/.kube` | Kubernetes config |
| `~/.ssh` | `/home/devuser/.ssh` | SSH keys for authentication |
| `~/.vimrc` | `/home/devuser/.vimrc` | Vim configuration |
| `$PWD` | `/workspace` | Development workspace |

### 🛠 **Container Networking & Ports**

The following ports are exposed for development needs:

| Port | Purpose |
| --- | --- |
| 3000 | Example for Node.js development |
| 8080 | Example for custom tools |

## 🧹 **Cleanup & Maintenance**

To remove containers, images, and networks but keep mounted data:

```sh
 ./build-dev-container.sh
```

Select option **4) Cleanup Docker (Keep Mounted Data)**.

To remove **everything**, including mounted data:

```sh
 docker compose down --volumes
 docker system prune -af
```

* * *

## 🎯 **Summary**

This **Dev Container** is a **preconfigured development environment** for DevOps engineers, making it easy to develop, debug, and test infrastructure automation tools.

✅ **Automates setup with Docker**  
✅ **Provides essential DevOps & CLI tools**  
✅ **Supports Kubernetes, Terraform, AWS, Azure, Python, Go**  
✅ **Persists user settings & SSH keys**  
✅ **Allows easy cleanup and maintenance**

* * *

🚀 **Start coding inside your isolated, portable dev environment today!**

## **Demo**

![Demo Image](images/demo.png)