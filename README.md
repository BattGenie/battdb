<img src="https://raw.githubusercontent.com/BattGenie/battdb/main/images/BattDB_Logo.png">

# BattDB

BattDB is a database based on Timescaledb (Postgres 15 extension) to store battery-related field and experimental (physical and virtual) data, as well as the metatada. Detailed database documentation and a few deployment options are provided.

### Overview

- [Documentation](#documentation)
- [Deployment Options](#deployment-options)
  - [Local Deployment with Docker Compose](#local-deployment-with-docker-compose)
    - [Prerequisites](#prerequisites)
    - [Deployment Steps](#deployment-steps)
  - [Using migration Scripts on your server](#using-migration-scripts-on-your-server)
    - [Migrate with Flyway](#migrate-with-flyway)
  - [Remote Deployment with Ansible](#remote-deployment-with-ansible)
    - [Prerequisites](#prerequisites)
    - [Client playbooks](#client-playbooks)
    - [Deployment Steps](#deployment-steps)


## Documentation

A .dbml file for the database is available in the diagrams directory. A condensed version in PDF form [here](diagrams/battdb_condensed.pdf). The condensed version only includes the tables and columns that are used by the ETL process.

## Deployment Options

BattDB can be deployed in following ways: locally using Docker-compose or using the migration scripts on self-hosted or managed Timescaledb server or remotely using Ansible on bare-metal. 

### Local Deployment with Docker Compose

A Docker Compose configuration file is provided to facilitate local deployment of the BattDB database.

#### Prerequisites

In order to use Docker Compose, you will need to have the following software installed on your machine:

1. [Docker](https://www.docker.com) - a platform for developing, shipping, and running applications in containers.

2. [Docker Compose](https://docs.docker.com/compose) - a tool for defining and running multi-container Docker applications.

#### Deployment Steps

1. Enter the compose directory:

    ```sh
    cd assets/battdb_docker/
    ```

2. Modify the `.env` file, change the environment variables:  
    POSTGRES_USER=YOUR_USERNAME  
    POSTGRES_PASSWORD=YOUR_PASSWORD  
    POSTGRES_DATABASE=YOUR_DATABASE  
    POSTGRES_PORT=YOUR_PORT  

3. Run Docker Compose:

    ```sh
    docker-compose --env-file .env up -d
    ```

4. Wait for Docker Compose to complete, and the `BattDB` database has been successfully deployed. The data for the database will be stored in the directory `assets/Docker/data`.

### Using migration Scripts on your server

Please note that if you need to update your database version, you can simply re-run the Ansible or Docker Compose deployment commands. This will apply any necessary updates using Docker & Flyway. However, if you need to manually migrate your database, you can use Flyway as described below.

#### Migrate with Flyway

If you need to manually migrate your database, follow these steps:

1. Download and install Flyway from <https://documentation.red-gate.com/fd/command-line-184127404.html>.
2. Navigate to the Flyway folder and edit the conf/flyway.conf file with the following parameters:

```conf
flyway.url=jdbc:postgresql://[URL]:[PORT]/[DATABASE]
# Example: flyway.url=jdbc:postgresql://localhost:5432/battdb
flyway.user=[USERNAME]
flyway.password=[PASSWORD]
```

3. Update to latest version of the database

```sh
flyway migrate -locations=filesystem:./assets/migration_scripts
```

 or update to specific version

```sh
flyway -target="[VERSION]" migrate -locations=filesystem:./assets/migration_scripts
```

### Remote Deployment with Ansible

An Ansible playbook is provided to quickly deploy the BattDB database remotely.

#### Prerequisites

- The remote host needs to have SSH service enabled.
- The remote host needs to have root privileges.

In order to use Ansible, you will need to have the following software installed on your machine:

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

#### Client playbooks

`battdb.yml`:

- Install Python3
- Install Install Docker and Docker Compose
- Clone `db_bg_cell_testing_main`
- Run Docker Compose to create database

#### Deployment Steps

1. Modify the `hosts` file, change the IP address, username, and password of the remote host
   - Refer to the `hosts` file for an example. If you are using a private key to log in, add your private key to the `assets/ssh/` directory.

2. Modify the `variables/postgresql.yml` file, change the credentials:

    ```yaml
    ---
    db_user: YOUR_USERNAME
    db_password: YOUR_PASSWORD
    db_name: YOUR_DATABASE
    db_port: YOUR_PORT
    ```

3. Run the playbook using the following command:

    ```sh
    ansible-playbook battdb.yml --extra-vars "variable_host=dev" --ask-become-pass
    ```

    Please note that --ask-become-pass is used to prompt for the sudo password. However, if you are using AWS EC2 instances, you may not need to use this option as the instances may be configured to allow passwordless sudo access.

4. Wait for the playbook to complete, and the `BattDB` database has been successfully deployed. The data for the database will be stored in the directory `~/battdb/data`.

