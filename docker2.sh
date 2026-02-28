#!/bin/bash

# Actualizar la lista de paquetes
sudo apt-get update

# Actualizar los paquetes instalados
sudo apt-get upgrade -y

# Instalar herramientas de red
sudo apt-get install net-tools -y

# Instalar y habilitar OpenSSH server
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh

# Crear usuario de respaldo
sudo adduser backupuser

# Crear el directorio para los respaldos de PostgreSQL
mkdir -p /home/backupuser/postgres_backups

# Ver la IP
ip a
