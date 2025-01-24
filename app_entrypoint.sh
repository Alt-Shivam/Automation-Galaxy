#!/bin/bash

# app_entrypoint.sh
# Entrypoint script to dynamically generate hosts.ini and run Ansible commands

# Print usage instructions
usage() {
    echo "Usage: docker run ansible-galaxy:latest <command> --username=<username> [--host-ip=<host_ip>] [--sudo-pass=<password>]"
    echo ""
    echo "Available commands:"
    echo "  pingall         - Ping all hosts in the inventory."
    echo "  k8s-install     - Install Kubernetes components."
    echo "  k8s-uninstall   - Uninstall Kubernetes components."
    echo "  install         - QuickStart installation."
    echo "  uninstall       - QuickStart uninstallation."
    echo ""
    echo "Options:"
    echo "  --username=<username>  Specify the username for the host machine."
    echo "  --host-ip=<host_ip>    Optionally specify the host machine's IP address."
    echo "  --sudo-pass=<password> Specify the sudo password for privileged commands."
    exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
    usage
fi

# Parse command-line arguments
COMMAND=$1
shift
USERNAME=""
HOST_IP=""
SUDO_PASS=""

for arg in "$@"; do
    case $arg in
        --username=*)
            USERNAME="${arg#*=}"
            shift
            ;;
        --host-ip=*)
            HOST_IP="${arg#*=}"
            shift
            ;;
        --sudo-pass=*)
            SUDO_PASS="${arg#*=}"
            shift
            ;;
        *)
            echo "Unknown argument: $arg"
            usage
            ;;
    esac
done

# Validate the username
if [ -z "$USERNAME" ]; then
    echo "Error: Username not provided."
    usage
fi

# Validate the sudo password
if [ -z "$SUDO_PASS" ]; then
    echo "Error: Sudo password not provided."
    usage
fi

# Detect host IP if not provided
if [ -z "$HOST_IP" ]; then
    HOST_IP=$(ip route | awk '/default/ { print $3 }')
    if [ -z "$HOST_IP" ]; then
        echo "Error: Unable to detect host IP."
        exit 1
    fi
fi

echo "Using Host IP: ${HOST_IP}"

# Generate the hosts.ini file dynamically
HOSTS_FILE="/automation-galaxy/hosts.ini"
echo "[all]" > $HOSTS_FILE
echo "${HOST_IP} ansible_host=${HOST_IP} ansible_user=${USERNAME} ansible_connection=ssh ansible_become_pass=${SUDO_PASS}" >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[master_nodes]" >> $HOSTS_FILE
echo "${HOST_IP}" >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[worker_nodes]" >> $HOSTS_FILE

# Define paths
ROOT_DIR="/automation-galaxy"
MAKEFILE_PATH="${ROOT_DIR}/Makefile"
EXTRA_VARS_FILE="${ROOT_DIR}/vars/main.yml"

# Execute the Makefile command
echo "Executing command: $COMMAND..."
make $COMMAND

# Exit with the appropriate status
if [ $? -eq 0 ]; then
    echo "Successfully executed command: $COMMAND"
else
    echo "Failed to execute command: $COMMAND"
    exit 1
fi
