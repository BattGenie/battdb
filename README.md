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

3. [Docker](https://www.docker.com) - a platform for developing, shipping, and running applications in containers.
4. [Docker Compose](https://docs.docker.com/compose) - a tool for defining and running multi-container Docker applications.

## Usage

```sh
ansible-playbook battdb.yml --extra-vars "variable_host=vms" --ask-become-pass
```
