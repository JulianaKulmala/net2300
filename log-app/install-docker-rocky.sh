#!/bin/bash

################################################################################
# Docker, Docker Compose, and Node.js Installation Script for Rocky Linux
# 
# This script will:
# - Install Docker CE (Community Edition)
# - Install Docker Compose plugin
# - Install Node.js LTS and npm
# - Configure Docker to start on boot
# - Optionally add current user to docker group
#
# Usage: sudo ./install-docker-rocky.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root or with sudo"
    exit 1
fi

print_info "Starting Docker and Node.js installation on Rocky Linux..."

# Check Rocky Linux version
if [ -f /etc/redhat-release ]; then
    OS_VERSION=$(cat /etc/redhat-release)
    print_info "Detected: $OS_VERSION"
else
    print_error "This script is designed for Rocky Linux"
    exit 1
fi

# Ask user what to install
echo ""
print_warn "What would you like to install?"
echo "  1) Docker + Docker Compose + Node.js (Full)"
echo "  2) Docker + Docker Compose only"
echo "  3) Node.js only"
read -p "Select option [1-3] (default: 1): " INSTALL_OPTION
INSTALL_OPTION=${INSTALL_OPTION:-1}

INSTALL_DOCKER=false
INSTALL_NODE=false

case $INSTALL_OPTION in
    1)
        INSTALL_DOCKER=true
        INSTALL_NODE=true
        print_info "Installing Docker, Docker Compose, and Node.js"
        ;;
    2)
        INSTALL_DOCKER=true
        print_info "Installing Docker and Docker Compose only"
        ;;
    3)
        INSTALL_NODE=true
        print_info "Installing Node.js only"
        ;;
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac
echo ""

################################################################################
# DOCKER INSTALLATION
################################################################################

if [ "$INSTALL_DOCKER" = true ]; then
    # Step 1: Remove old Docker installations if any
    print_info "Removing old Docker installations (if any)..."
    dnf remove -y docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine \
        podman \
        runc 2>/dev/null || true

    # Step 2: Install required packages
    print_info "Installing required packages..."
    dnf install -y dnf-plugins-core

    # Step 3: Add Docker repository
    print_info "Adding Docker CE repository..."
    dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    # Step 4: Install Docker Engine
    print_info "Installing Docker CE, Docker CLI, and containerd..."
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Step 5: Start and enable Docker service
    print_info "Starting Docker service..."
    systemctl start docker
    systemctl enable docker

    # Step 6: Verify Docker installation
    print_info "Verifying Docker installation..."
    if docker --version; then
        print_info "Docker installed successfully: $(docker --version)"
    else
        print_error "Docker installation failed"
        exit 1
    fi

    # Step 7: Verify Docker Compose installation
    print_info "Verifying Docker Compose installation..."
    if docker compose version; then
        print_info "Docker Compose installed successfully: $(docker compose version)"
    else
        print_error "Docker Compose installation failed"
        exit 1
    fi

    # Step 8: Test Docker with hello-world
    print_info "Testing Docker with hello-world container..."
    if docker run --rm hello-world > /dev/null 2>&1; then
        print_info "Docker is working correctly!"
    else
        print_warn "Docker test failed, but installation completed"
    fi

    # Step 9: Configure firewall (if firewalld is running)
    if systemctl is-active --quiet firewalld; then
        print_info "Configuring firewall for Docker..."
        firewall-cmd --permanent --zone=trusted --add-interface=docker0 2>/dev/null || true
        firewall-cmd --permanent --zone=public --add-masquerade 2>/dev/null || true
        firewall-cmd --reload
        print_info "Firewall configured"
    fi

    # Step 10: Ask to add user to docker group
    echo ""
    print_warn "To run Docker without sudo, add your user to the docker group"
    read -p "Add current user ($SUDO_USER) to docker group? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -n "$SUDO_USER" ]; then
            usermod -aG docker "$SUDO_USER"
            print_info "User $SUDO_USER added to docker group"
            print_warn "Please log out and log back in for group changes to take effect"
            print_warn "Or run: newgrp docker"
        else
            print_warn "Could not detect user. Run manually: sudo usermod -aG docker \$USER"
        fi
    fi
fi

################################################################################
# NODE.JS INSTALLATION
################################################################################

if [ "$INSTALL_NODE" = true ]; then
    echo ""
    print_info "Installing Node.js LTS..."
    
    # Remove old Node.js installations
    print_info "Removing old Node.js installations (if any)..."
    dnf remove -y nodejs npm 2>/dev/null || true
    
    # Install Node.js 18.x LTS from NodeSource
    print_info "Adding NodeSource repository for Node.js 18.x LTS..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    
    # Install Node.js and npm
    print_info "Installing Node.js and npm..."
    dnf install -y nodejs
    
    # Verify Node.js installation
    print_info "Verifying Node.js installation..."
    if node --version; then
        print_info "Node.js installed successfully: $(node --version)"
    else
        print_error "Node.js installation failed"
        exit 1
    fi
    
    # Verify npm installation
    print_info "Verifying npm installation..."
    if npm --version; then
        print_info "npm installed successfully: $(npm --version)"
    else
        print_error "npm installation failed"
        exit 1
    fi
    
    # Install common global packages (optional)
    read -p "Install common global npm packages (yarn, pm2)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing yarn and pm2..."
        npm install -g yarn pm2
        print_info "Global packages installed"
    fi
fi

# Display summary
echo ""
print_info "================================"
print_info "Installation Complete!"
print_info "================================"
echo ""

if [ "$INSTALL_DOCKER" = true ]; then
    echo "Docker version:         $(docker --version 2>/dev/null || echo 'Not installed')"
    echo "Docker Compose version: $(docker compose version 2>/dev/null || echo 'Not installed')"
fi

if [ "$INSTALL_NODE" = true ]; then
    echo "Node.js version:        $(node --version 2>/dev/null || echo 'Not installed')"
    echo "npm version:            $(npm --version 2>/dev/null || echo 'Not installed')"
fi

echo ""
print_info "Next Steps:"

if [ "$INSTALL_DOCKER" = true ]; then
    echo "  1. Log out and log back in (if user was added to docker group)"
    echo "  2. Test Docker: docker run hello-world"
    echo "  3. Test Docker Compose: docker compose version"
fi

if [ "$INSTALL_NODE" = true ]; then
    echo "  - Test Node.js: node --version"
    echo "  - Test npm: npm --version"
    echo "  - Install project dependencies: cd log-app/backend && npm install"
fi

echo ""

if [ "$INSTALL_DOCKER" = true ]; then
    print_info "Docker Commands:"
    echo "  - Check Docker status:      sudo systemctl status docker"
    echo "  - Start Docker:             sudo systemctl start docker"
    echo "  - Stop Docker:              sudo systemctl stop docker"
    echo "  - Docker info:              docker info"
    echo "  - View running containers:  docker ps"
    echo ""
fi

if [ "$INSTALL_NODE" = true ]; then
    print_info "Node.js Commands:"
    echo "  - Check Node version:   node --version"
    echo "  - Check npm version:    npm --version"
    echo "  - Install packages:     npm install"
    echo "  - Run npm script:       npm start"
    echo ""
fi

print_info "Documentation:"
if [ "$INSTALL_DOCKER" = true ]; then
    echo "  - Docker:   https://docs.docker.com/"
    echo "  - Compose:  https://docs.docker.com/compose/"
fi
if [ "$INSTALL_NODE" = true ]; then
    echo "  - Node.js:  https://nodejs.org/docs/"
    echo "  - npm:      https://docs.npmjs.com/"
fi
echo ""

exit 0
