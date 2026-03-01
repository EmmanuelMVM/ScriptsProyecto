#!/bin/bash

# Descargar Docker
sudo apt install docker.io -y
sudo apt install docker-compose -y

# Descomprimir el archivo Docker/servidor-web
sudo unzip Docker/servidor-web
mv Docker/servidor-web /home/usuario1/
# Cambiar al directorio del servidor web
cd ~/servidor-web

# Iniciar contenedores Docker con la opción --build
sudo docker-compose up -d --build

# Ver los contenedores en ejecución
sudo docker ps

# Mover los certificados SSL al directorio adecuado
cd apache/certs
sudo mv cert.pem /etc/ssl/certs/
sudo mv key.pem /etc/ssl/private/

# Detener los contenedores y reiniciar
sudo docker-compose down
sudo docker-compose up -d --build
sudo docker ps

# Editar /etc/hosts
sudo nano /etc/hosts <<EOF
127.0.0.1   localhost
127.0.1.1   caremind
127.0.0.1   caremind.test
192.168.1.4 caremind.test
192.168.1.4 mail.caremind.test
EOF

# Instalar dnsutils para pruebas de DNS
sudo apt install dnsutils -y

# Verificar configuración de DNS en el contenedor de bind9
sudo docker exec -it bind9_dns named-checkconf
sudo docker exec -it bind9_dns named-checkzone caremind.test /etc/bind9/db.caremind.test

# Hacer consultas DNS
dig @127.0.0.1 -p 5353 caremind.test
dig @127.0.0.1 -p 5353 caremind.test MX

# Verificar puertos relacionados con el correo
sudo ss -tulpn | grep -E ':25|:587|:148|:993'

# Verificar conexión SSL con el servidor
openssl s_client -connect localhost:993

# Levantar contenedor de servidor de correo
sudo docker-compose up -d mailserver

# Agregar un correo de prueba al servidor
sudo docker exec -it mailserver setupt email add usuario@caremind.test password123
sudo docker exec -it mailserver setup email list

# Instalar Thunderbird
sudo apt install thunderbird -y

# Mover el script de respaldo de PostgreSQL a una ubicación global
sudo mv backup_postgres.sh /usr/local/bin/backup_postgres.sh

# Crear directorios para respaldos y logs
sudo mkdir -p /var/backups/postgres
sudo mkdir -p /var/log
sudo touch -p /var/log/postgres_backup.log

# Asegurarse de que el script sea ejecutable
sudo chmod +x /usr/local/bin/backup_postgres.sh

# Generar una clave SSH para el usuario de respaldo
ssh-keygen -t rsa -b 4096

# Copiar la clave SSH al servidor de respaldo
sudo ssh-copy-id backupuser@192.168.1.5

# Configurar el cron para el respaldo automático
sudo crontab -e
# Agregar la siguiente línea al crontab:
# 1 0 * * * /usr/local/backupuser_postgres.sh
