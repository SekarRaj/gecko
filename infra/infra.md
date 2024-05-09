1. Execute `tf apply -auto-approve` to create infra. At the end IP address will be written to `inventory.ini`.
2. Add the content `ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=adminuser` after IP address in ensure correct user and keys are used.
3. After update, execute `ansible-playbook -i inventory.ini ibm_cobol_playbook.yaml`.




DB2 Installation

dpkg --add-architecture i386 &&     apt-get update &&     apt-get install -y libnuma1 libpam0g:i386
