#### Variables ####

export ROOT_DIR ?= $(PWD)
export GALAXY_ROOT_DIR ?= $(ROOT_DIR)

export K8S_ROOT_DIR ?= $(GALAXY_ROOT_DIR)/deps/k8s


export ANSIBLE_NAME ?= ansible-galaxy
export ANSIBLE_CONFIG ?= $(GALAXY_ROOT_DIR)/ansible.cfg
export HOSTS_INI_FILE ?= $(GALAXY_ROOT_DIR)/hosts.ini

## Extra Variables to be added herer
export EXTRA_VARS ?= "@$(GALAXY_ROOT_DIR)/vars/main.yml"


#### Start Ansible docker (no longer supported) ####

ansible:
	export ANSIBLE_NAME=$(ANSIBLE_NAME); \
	sh $(GALAXY_ROOT_DIR)/scripts/ansible ssh-agent bash

#### Validate Ansible Configuration ####
pingall:
	echo $(GALAXY_ROOT_DIR)
	ansible-playbook -i $(HOSTS_INI_FILE) $(GALAXY_ROOT_DIR)/pingall.yml \
		--extra-vars "ROOT_DIR=$(ROOT_DIR)" --extra-vars $(EXTRA_VARS)

#### Provision galaxy Components for 5G ####
k8s-install: k8s-install
k8s-uninstall: k8s-uninstall

#### Shortcut for QuickStart Only ####
install: k8s-install # Other tasks to can be added sequential order
uninstall: k8s-uninstall



#include at the end so rules are not overwritten (More makefiles can be added as per repo)
include $(K8S_ROOT_DIR)/Makefile

