#!/bin/bash

echo "==================================="
echo "🚀 Ubuntu Server Full Setup Script"
echo "==================================="

# ========================
# Demander les infos user
# ========================
read -p "👉 Nouveau mot de passe pour root : " root_pass
echo "root:$root_pass" | sudo chpasswd
echo "✅ Mot de passe root mis à jour."

read -p "👉 Nom du nouvel utilisateur sudo : " new_user
sudo adduser $new_user
sudo usermod -aG sudo $new_user
echo "✅ Utilisateur $new_user créé et ajouté au groupe sudo."

# ========================
# Sécuriser SSH
# ========================
read -p "👉 Nouveau port SSH (ex: 2203) : " ssh_port

# Sauvegarde de la conf SSH
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modifier la config SSH
sudo sed -i "s/^#Port .*/Port $ssh_port/" /etc/ssh/sshd_config
sudo sed -i "s/^Port .*/Port $ssh_port/" /etc/ssh/sshd_config
sudo sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i "s/^PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config

# Ajouter AllowUsers si pas déjà présent
if ! grep -q "AllowUsers" /etc/ssh/sshd_config; then
    echo "AllowUsers $new_user" | sudo tee -a /etc/ssh/sshd_config
else
    sudo sed -i "s/^AllowUsers.*/AllowUsers $new_user/" /etc/ssh/sshd_config
fi

sudo systemctl restart ssh
echo "✅ SSH configuré sur le port $ssh_port, root interdit, seul $new_user autorisé."

# ========================
# Mettre à jour le système
# ========================
sudo apt update && sudo apt upgrade -y
echo "✅ Système à jour."

# ========================
# Installer fail2ban
# ========================
sudo apt install -y fail2ban

sudo bash -c 'cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 600
findtime = 600
maxretry = 5
banaction = iptables-multiport
logtarget = SYSLOG

[sshd]
enabled = true
port = '"$ssh_port"'
filter = sshd
logpath = /var/log/auth.log
EOF'

sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
echo "✅ Fail2ban installé et configuré pour SSH sur port $ssh_port."

# ========================
# unattended-upgrades
# ========================
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
echo "✅ unattended-upgrades installé et configuré."

# ========================
# Installer bpytop + alias
# ========================
sudo apt install -y bpytop
echo "alias vichcheck='bpytop'" | sudo tee -a /home/$new_user/.bashrc
echo "alias vichcheck='bpytop'" | sudo tee -a /root/.bashrc
echo "✅ bpytop installé + alias vichcheck."

# ========================
# Installer Docker & Compose
# ========================
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

echo "✅ Docker et Docker Compose installés."

# ========================
# Déployer Portainer
# ========================
docker volume create portainer_data

docker run -d \
  -p 9000:9000 \
  -p 8000:8000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo "✅ Portainer lancé ➜ http://<votre_IP>:9000"

# ========================
# Déployer Nginx Proxy Manager
# ========================
mkdir -p ~/nginx-proxy-manager && cd ~/nginx-proxy-manager

cat <<EOF > docker-compose.yml
version: "3"
services:
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

docker compose up -d
echo "✅ Nginx Proxy Manager lancé ➜ http://<votre_IP>:81"

# ========================
# Résumé
# ========================
echo "🎉 Setup complet !"
echo "- SSH port : $ssh_port (root interdit, user autorisé : $new_user)"
echo "- Fail2ban actif pour SSH"
echo "- Unattended-upgrades actif"
echo "- bpytop alias : vichcheck"
echo "- Docker + Portainer + NPM actifs"
echo "🚀 Prêt pour déployer tes services !"
