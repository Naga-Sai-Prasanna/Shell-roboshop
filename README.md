# Shell RoboShop

Shell script automation for deploying the **RoboShop** microservices e-commerce application on EC2 instances. Each service is installed and configured using a standalone Bash script paired with a systemd unit file, without relying on a configuration management tool like Ansible.

## What This Does

RoboShop is a microservices-based e-commerce demo application made up of several backend services (catalogue, cart, shipping, payment, user, frontend) and datastores (MySQL, MongoDB, Redis, RabbitMQ). This repo automates the setup of each component using plain Bash scripts, intended to be run directly on each target EC2 instance.

## Project Structure

| File | Purpose |
|------|---------|
| `user.sh` | Installs and configures the User service |
| `user.service` | systemd unit file to run the User service as a managed background process |
| *(additional `*.sh` / `*.service` pairs)* | One script + systemd unit per RoboShop component (catalogue, cart, shipping, payment, frontend, etc.) |

> Each `*.sh` script handles installing dependencies (Node.js, runtime packages), pulling the application code/artifact, and setting up the working directory for its service. The matching `*.service` file registers that service with `systemd` so it starts on boot and restarts on failure.

## Prerequisites

- An EC2 instance running Amazon Linux / RHEL-compatible OS
- Root or `sudo` access on the target instance
- Internet access on the instance to download dependencies and packages
- Each script run on the EC2 instance dedicated to that specific service (RoboShop's microservices architecture expects one service per host)

## Usage

1. Copy the relevant script and `.service` file to the target EC2 instance.
2. Make the script executable:

   ```bash
   chmod +x user.sh
   ```

3. Run the script with root privileges:

   ```bash
   sudo ./user.sh
   ```

4. The script installs the systemd unit and starts the service. Verify it's running:

   ```bash
   sudo systemctl status user
   ```

5. Repeat for each service on its respective host.

## Notes

- These scripts are written as straightforward, sequential Bash — no idempotency guarantees like Ansible provides, so re-running a script may fail or duplicate setup steps if not designed for it.
- Intended as a manual/scriptable alternative to the Ansible-based deployment in the companion [`ansible-roboshop`](https://github.com/Naga-Sai-Prasanna/ansible-roboshop) repo.

## Status

This is a personal learning/practice project for DevOps automation (Bash + systemd + AWS EC2), part of a broader RoboShop deployment exercise also covering Ansible, Terraform, Docker, and EKS in separate repos.
