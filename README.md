<img src="https://raw.githubusercontent.com/BattGenie/battdb/main/images/BattDB_Logo.png">

# BattDB [![Documentation Status](https://readthedocs.org/projects/battdb/badge/?version=latest)](https://battdb.readthedocs.io/en/latest/?badge=latest)

BattDB is a database based on TimescaleDB (Postgres 15 extension) to store battery-related field and experimental (physical and virtual) data, as well as the metadata. Detailed database documentation and a few deployment options are provided.

## Overview

- [BattDB](#battdb)
  - [Overview](#overview)
  - [Database Design Principles](#database-design-principles)
  - [Documentation](#documentation)
  - [Deployment Options](#deployment-options)
    - [Local Deployment with Docker Compose](#local-deployment-with-docker-compose)
      - [Prerequisites](#prerequisites)
      - [Deployment Steps](#deployment-steps)
    - [Using migration Scripts on your server](#using-migration-scripts-on-your-server)
      - [Migrate with Flyway](#migrate-with-flyway)
    - [Remote Deployment with Ansible](#remote-deployment-with-ansible)
      - [Prerequisites](#prerequisites-1)
      - [Client playbooks](#client-playbooks)
      - [Deployment Steps](#deployment-steps-1)
    - [SSL](#ssl)
      - [PostgreSQL](#postgresql)
        - [Key](#key)
        - [postgresql.conf](#postgresqlconf)
        - [pg\_hba.conf](#pg_hbaconf)
      - [PgBouncer](#pgbouncer)
        - [Key](#key-1)
        - [environment variables](#environment-variables)
      - [Example commands to generate SSL certificates](#example-commands-to-generate-ssl-certificates)

## Database Design Principles

We believe in the power of good design and robust practices when it comes to our database management. Here's how we ensure the efficient and reliable data management for scale and longevity for our clients:

1. Version-Controlled Schema: We use advanced tools like Flyway for database migration and version control. This allows us to meticulously track changes to our database schema over time, ensuring a reliable and consistent database structure that can evolve with your needs.

2. Modular Design: Our database schema changes are broken down into smaller, manageable parts. This modular approach makes our database easier to understand, maintain, and adapt, ensuring that we can quickly respond to your changing requirements. Use a simpler database structure available in assets\migrations_scripts_quick for ad-hoc analyses and much more detailed and powerful, relational database structure for long-term storage of data.

3. Comprehensive Documentation: We believe in transparency and clarity. That's why we provide detailed schema diagrams, making it easy for you to understand the structure of your database. This clear communication aids in decision-making and ensures that you're always in the loop.

4. Environment Isolation: We maintain separate configurations for different environments such as development, staging, and production. This practice safeguards your production data and allows us to test changes in a controlled environment, ensuring the highest level of data integrity and reliability.

5. Automated Deployment: We leverage the power of automation to reduce manual errors and streamline our deployment process. Using tools like Ansible and Docker, we ensure a repeatable and reliable setup and deployment of your database, delivering consistent performance and saving you time.

In essence, our database design principles are all about providing you with a robust, reliable, and adaptable database solution that can grow with your business. Trust us to handle your data with the care and precision it deserves.

## Documentation

The detailed database documentation, including the schema, can be found in the [docs/index.html](docs/index.html) file.

## Deployment Options

BattDB can be deployed in following ways: locally using Docker-compose or using the migration scripts on self-hosted or managed TimescaleDB server or remotely using Ansible on bare-metal.

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

2. Create the `.env` file, change the environment variables:  

    ```text
    POSTGRES_USER=YOUR_USERNAME  
    POSTGRES_PASSWORD=YOUR_PASSWORD  
    POSTGRES_DATABASE=YOUR_DATABASE  
    POSTGRES_PORT=YOUR_PORT  
    FLYWAY_SQL=../migration_scripts
    ```

    Use `FLYWAY_SQL=../migration_scripts_quick` for quick mode.

3. Run Docker Compose:

    ```sh
    docker network create battsoft-net
    docker-compose --env-file .env up -d --scale schemaspy=0
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

### SSL

#### PostgreSQL

To establish an SSL connection with the database, please refer to the PostgreSQL official documentation:

<https://www.postgresql.org/docs/current/ssl-tcp.html>

##### Key

You will need at least five files:

- root.crt
- server.crt
- server.key
- client.crt
- client.key

Please place `root.crt`, `server.crt` and `server.key` in the `BattDB/assets/battdb_docker/data/battdb` directory.

##### postgresql.conf

You might need to modify the following content in `postgresql.conf`:

```conf
ssl = on
ssl_ca_file = '/var/lib/postgresql/data/root.crt'
ssl_cert_file = '/var/lib/postgresql/data/server.crt'
ssl_key_file = '/var/lib/postgresql/data/server.key'
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL' # allowed SSL ciphers
ssl_prefer_server_ciphers = on
```

##### pg_hba.conf

We recommend adding the following settings:

Allow password login for containers under the same `battsoft-net` Docker network:

```conf
host all all 172.0.0.0/8 scram-sha-256
```

External connections should use SSL:

```conf
hostssl all all all cert
```

#### PgBouncer

To establish an SSL connection with PgBouncer, please refer to the PgBouncer official documentation:

<https://www.pgbouncer.org/config.html>

##### Key

You will need at least five files:

- root.crt
- server.crt
- server.key
- client.crt
- client.key

Please place `root.crt`, `server.crt` and `server.key` in the `BattDB/assets/battdb_docker/certs` directory.

##### environment variables

Please add the following environment variables to the `.env` file:

```text
PGBOUNCER_CLIENT_TLS_SSLMODE=verify-full
```

Optionally, you can add the following environment variables to the `.env` file:

- PGBOUNCER_CLIENT_TLS_CA_FILE: default is `/certs/root.crt`
- PGBOUNCER_CLIENT_TLS_CERT_FILE: default is `/certs/server.crt`
- PGBOUNCER_CLIENT_TLS_KEY_FILE: default is `/certs/server.key`

**Restart the docker container to apply the SSL settings.**

Please adjust these configurations based on your requirements and ensure that the specified files and paths are accurate for your setup.

#### Example commands to generate SSL certificates

```sh
openssl genrsa -out ca.key 2048
openssl genrsa -out server.key 2048
openssl genrsa -out client.key 2048

# Common Name: BGRoot (or your domain)
openssl req -x509 -new -nodes -key ca.key -days 3650 -out ca.crt

# Common Name: localhost (or your domain)
openssl req -new -key server.key -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650

# Common Name: localhost (or your domain)
openssl req -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 3650
```
