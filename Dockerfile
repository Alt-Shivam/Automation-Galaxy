# Use Ubuntu as the base image
FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ansible=2.10.7* \
    make \
    python3-pip \
    sshpass \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install ansible k8s core
RUN ansible-galaxy collection install kubernetes.core

# Set up directories
WORKDIR /automation-galaxy

# Copy the entire repository into the container
COPY . .

# Add the entrypoint script
COPY app_entrypoint.sh /usr/local/bin/app_entrypoint.sh
RUN chmod +x /usr/local/bin/app_entrypoint.sh

# Set the entrypoint for the container
ENTRYPOINT ["/usr/local/bin/app_entrypoint.sh"]
