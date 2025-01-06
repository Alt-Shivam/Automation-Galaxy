#!/bin/bash

# app_entrypoint.sh
# Entrypoint script to dynamically generate hosts.ini and run Ansible commands

# Print usage instructions
usage() {
    echo "Usage: docker run ansible-galaxy:latest <command> --username=<username>"
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

for arg in "$@"; do
    case $arg in
        --username=*)
            USERNAME="${arg#*=}"
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

# Fetch the host IP dynamically
HOST_IP=$(ip route | awk '/default/ { print $3 }')

# Generate the hosts.ini file dynamically
HOSTS_FILE="/automation-galaxy/hosts.ini"
echo "[all]" > $HOSTS_FILE
echo "localhost ansible_host=${HOST_IP} ansible_user=${USERNAME} ansible_connection=local" >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[master_nodes]" >> $HOSTS_FILE
echo "localhost" >> $HOSTS_FILE
echo "" >> $HOSTS_FILE
echo "[worker_nodes]" >> $HOSTS_FILE
# Add any worker nodes dynamically if required here

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
