# Docker Installation Scripts for Rocky Linux

This directory contains scripts to install Docker and Docker Compose on Rocky Linux.

## Quick Installation

### Automated Script (Recommended)

Run the full installation script:

```bash
sudo ./install-docker-rocky.sh
```

This script will:
- ✅ Remove old Docker installations
- ✅ Install Docker CE and Docker Compose plugin
- ✅ Configure Docker to start on boot
- ✅ Configure firewall rules
- ✅ Optionally add your user to docker group
- ✅ Test the installation

### Manual Installation (One-liner)

If you prefer a quick manual installation:

```bash
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && \
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
docker --version && \
docker compose version
```

### Add User to Docker Group

To run Docker without sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Or log out and log back in.

## Verification

### Automated Verification

Run the verification script:
```bash
./verify-docker.sh
```

This will check:
- ✅ Docker command availability
- ✅ Docker Compose plugin
- ✅ Docker daemon status
- ✅ Auto-start configuration
- ✅ Non-sudo access
- ✅ Container execution

### Manual Tests

Test Docker:
```bash
docker run hello-world
```

Test Docker Compose:
```bash
docker compose version
```

## Troubleshooting

### Check Docker status
```bash
sudo systemctl status docker
```

### View Docker logs
```bash
sudo journalctl -u docker.service
```

### Restart Docker
```bash
sudo systemctl restart docker
```

### Check firewall
```bash
sudo firewall-cmd --list-all
```

### Permission denied error
If you get "permission denied" when running docker commands:
```bash
# Verify docker group exists
getent group docker

# Check if user is in docker group
groups $USER

# If not in group, add and reload:
sudo usermod -aG docker $USER
newgrp docker
```

## Uninstall Docker

If you need to remove Docker:

```bash
# Stop Docker service
sudo systemctl stop docker

# Remove Docker packages
sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Remove Docker data (WARNING: This deletes all containers, images, volumes)
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

## Post-Installation Configuration

### Configure Docker to use different data directory
Edit `/etc/docker/daemon.json`:
```json
{
  "data-root": "/new/path/to/docker"
}
```

Then restart Docker:
```bash
sudo systemctl restart docker
```

### Limit Docker log size
Edit `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
