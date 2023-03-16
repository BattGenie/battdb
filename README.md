# BattDB

Ansible scripts for BattETL Database

## Requirements

In order to use this project, you will need to have the following software installed on your machine:

1. [Ansible](https://www.ansible.com) - a configuration management tool that allows you to automate the deployment and configuration of software and services.

    ```sh
    sudo apt install ansible
    ```

2. [sshpass](https://linux.die.net/man/1/sshpass) - a tool that allows you to provide a password for ssh connections.

    ```sh
    sudo apt install sshpass
    ```

    Please note that if you are using SSH key authentication to log in to the client machines, you do not need to install `sshpass`.

    `sshpass` is a tool used to automate password input during SSH connections. However, it is not recommended to use sshpass as it may compromise the security of the system. Instead, it is recommended to use SSH key authentication which provides a more secure way of authentication.

    If you have already set up SSH key authentication for your client machines, you can skip the installation of sshpass and proceed with your Ansible playbook. You can refer to the `hosts` file for examples on how to use `ssh_pass` and `ssh_private_key_file` for password and SSH key authentication respectively.

## Client playbooks

`battdb.yml`:

- Install Python3
- Install Install Docker and Docker Compose
- Clone `db_bg_cell_testing_main`
- Run Docker Compose to create database

## Usage

We have encrypted some credentials that need to be decrypted using ansible-vault.
To decrypt the encrypted files, run the following commands:

```sh
ansible-vault decrypt assets/ssh/bing_battdb.pem
ansible-vault decrypt variables/postgresql.yml
```

The password for the encrypted files can be found in BitVault. Once the files are decrypted, run the playbook using the following command:

```sh
ansible-playbook battdb.yml --extra-vars "variable_host=vms" --ask-become-pass
```

Please note that --ask-become-pass is used to prompt for the sudo password. However, if you are using AWS EC2 instances, you may not need to use this option as the instances may be configured to allow passwordless sudo access.
