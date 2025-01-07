# Automation-Galaxy
General purpose Automation Ansible playbooks triggered by Make

## The Instant way
### Pre-requisites
- Make sure docker installed on the system.
- pub key added to remote VM for ssh access.
### Run playbook
- To see the options available
```
core@noded39:~$ docker run --rm ansible-galaxy:latest
```
```
Usage: docker run ansible-galaxy:latest <command> --username=<username> [--host-ip=<host_ip>]

Available commands:
  pingall         - Ping all hosts in the inventory.
  k8s-install     - Install Kubernetes components.
  k8s-uninstall   - Uninstall Kubernetes components.
  install         - QuickStart installation.
  uninstall       - QuickStart uninstallation.

Options:
  --username=<username>  Specify the username for the host machine.
  --host-ip=<host_ip>    Optionally specify the host machine's IP address.
```
- To run a task
```
docker run --rm -it --network host \
    -v ~/.ssh:/root/.ssh:ro \
    ansible-galaxy:latest pingall --username=core --host-ip=192.168.100.89
```

## Install Packages required for setup
- Ubuntu 22
```bash
sudo apt update
sudo apt install make sshpass ansible=2.10.7* -y
ansible-galaxy collection install kubernetes.core
```
- Ubuntu 20
```bash
sudo apt update
sudo apt install make sshpass ansible=2.9.6* -y
ansible-galaxy collection install kubernetes.core
```
- Mac
```bash
brew install ansible@8
```

## Ansible repo setup
1) Clone repo
```bash
git clone --recursive https://github.com/Alt-Shivam/Automation-Galaxy.git
```
2. Modify `hosts.ini` according to your target hosts
3. Check the connectivity with target hosts
```bash
make pingall
```
<details>
  <summary>Output</summary>

  ```bash
  core@nodeb40:~/Automation-Galaxy$ make pingall 
echo /home/core/Automation-Galaxy
/home/core/Automation-Galaxy
ansible-playbook -i /home/core/Automation-Galaxy/hosts.ini /home/core/Automation-Galaxy/pingall.yml \
	--extra-vars "ROOT_DIR=/home/core/Automation-Galaxy" --extra-vars "@/home/core/Automation-Galaxy/vars/main.yml"

PLAY [ping all hosts] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [node1]

TASK [ping all] ********************************************************************************************************************************************************************************************
ok: [node1]

PLAY RECAP *************************************************************************************************************************************************************************************************
node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

  ```
</details>

4. Initiate a k8s cluster
```
make k8s-install
```
<details>
  <summary>Output</summary>

  ```bash
  make k8s-install 
make: Circular k8s-install <- k8s-install dependency dropped.
ansible-playbook -i /home/core/Automation-Galaxy/hosts.ini /home/core/Automation-Galaxy/deps/k8s/rke2.yml --tags install \
	--extra-vars "ROOT_DIR=/home/core/Automation-Galaxy" --extra-vars "@/home/core/Automation-Galaxy/vars/main.yml"

PLAY [provision rke2] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : set fs.file-max to 2097152] *******************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : set fs.inotify.max_user_watches to 524288] ****************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : set fs.inotify.max_user_instances to 512] *****************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : set_fact] *************************************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : remove /tmp/rke2] *****************************************************************************************************************************************************************************
changed: [node1]

TASK [rke2 : create /tmp/rke2] *****************************************************************************************************************************************************************************
changed: [node1]

TASK [rke2 : download rke2] ********************************************************************************************************************************************************************************
changed: [node1]

TASK [rke2 : create /etc/rancher/rke2] *********************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : install rke2 on masters] **********************************************************************************************************************************************************************
changed: [node1]

TASK [rke2 : enable rke2-server on masters] ****************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : copy master-config.yaml to /etc/rancher/rke2/config.yaml] *************************************************************************************************************************************
ok: [node1]

TASK [rke2 : start rke2-server on masters] *****************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : waiting for the master nodes to get ready] ****************************************************************************************************************************************************
changed: [node1]

TASK [rke2 : force systemd to reread configs] **************************************************************************************************************************************************************

ok: [node1]

TASK [rke2 : pause] ****************************************************************************************************************************************************************************************
Pausing for 5 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
ok: [node1]

TASK [rke2 : install rke2 agent on workers] ****************************************************************************************************************************************************************
skipping: [node1]

TASK [rke2 : enable rke2-agent on workers] *****************************************************************************************************************************************************************
skipping: [node1]

TASK [rke2 : copy worker-config.yaml to /etc/rancher/rke2/config.yaml] *************************************************************************************************************************************
skipping: [node1]

TASK [rke2 : start rke2-agent on workers (sequentially)] ***************************************************************************************************************************************************
skipping: [node1]

TASK [rke2 : force systemd to reread configs] **************************************************************************************************************************************************************
skipping: [node1]

TASK [rke2 : download kubectl] *****************************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : create /home/core/.kube] **********************************************************************************************************************************************************************
ok: [node1]

TASK [rke2 : copy /etc/rancher/rke2/rke2.yaml /home/core/.kube/config] *************************************************************************************************************************************
ok: [node1]

TASK [rke2 : change /home/core/.kube ownership] ************************************************************************************************************************************************************
[WARNING]: Consider using the file module with owner rather than running 'chown'.  If you need to use command because file is insufficient you can add 'warn: false' to this command task or set
'command_warnings=False' in ansible.cfg to get rid of this message.
changed: [node1]

PLAY RECAP *************************************************************************************************************************************************************************************************
node1                      : ok=20   changed=6    unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   

ansible-playbook -i /home/core/Automation-Galaxy/hosts.ini /home/core/Automation-Galaxy/deps/k8s/helm.yml --tags install \
	--extra-vars "ROOT_DIR=/home/core/Automation-Galaxy" --extra-vars "@/home/core/Automation-Galaxy/vars/main.yml"
[WARNING]: Collection kubernetes.core does not support Ansible version 2.10.8

PLAY [provision helm] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [node1]

TASK [helm : set_fact] *************************************************************************************************************************************************************************************
ok: [node1]

TASK [helm : remove /tmp/helm] *****************************************************************************************************************************************************************************
ok: [node1]

TASK [helm : create /tmp/helm] *****************************************************************************************************************************************************************************
changed: [node1]

TASK [helm : download get-helm.sh] *************************************************************************************************************************************************************************
changed: [node1]

TASK [helm : install helm on masters] **********************************************************************************************************************************************************************
changed: [node1]

TASK [helm : add incubator chart repo] *********************************************************************************************************************************************************************
changed: [node1]

PLAY RECAP *************************************************************************************************************************************************************************************************
node1                      : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
</details>