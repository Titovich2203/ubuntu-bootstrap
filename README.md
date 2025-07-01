# 🚀 Ubuntu Server Bootstrap

Un script Bash **clé en main** pour configurer rapidement un serveur **Ubuntu** sécurisé et prêt pour héberger des conteneurs avec **Docker**, **Portainer**, et **Nginx Proxy Manager**.

---

## ✅ Ce que ça fait

1. 🔐 **Sécurisation SSH**
   - Change le port SSH par défaut (ex. 2203)
   - Crée un **nouvel utilisateur sudo**
   - Désactive la connexion SSH pour `root`
   - Limite l’accès SSH à ton user

2. 🛡️ **Sécurité serveur**
   - Installe et configure **Fail2ban** pour bloquer les tentatives bruteforce SSH
   - Active **unattended-upgrades** pour les mises à jour automatiques
   - Installe **bpytop** pour monitorer ton serveur ➜ alias `vichcheck`

3. 🐳 **Stack conteneurs**
   - Installe **Docker** et **Docker Compose**
   - Déploie **Portainer** pour gérer Docker via une interface web
   - Déploie **Nginx Proxy Manager** pour gérer tes proxys, domaines et certificats SSL

---

## 🗂️ Structure

- `full-setup.sh` ➜ script interactif qui pose toutes les bases :
  - Demande le nouveau mot de passe `root`
  - Crée le nouvel utilisateur sudo
  - Demande le port SSH
  - Fait tout le reste automatiquement

---

## ⚡ Usage

```bash
# Rendre le script exécutable
chmod +x full-setup.sh

# Lancer le script
./full-setup.sh

```

---

## 📌 Pré-requis

- Serveur Ubuntu (22.04 LTS recommandé)
- Accès root initial pour lancer le script

---

## 🌐 Ports ouverts par défaut

- **SSH** ➜ ton port custom (ex. 7612)
- **Portainer** ➜ 9000
- **Nginx Proxy Manager**
  - 80 ➜ HTTP
  - 443 ➜ HTTPS
  - 81 ➜ Interface admin

Vérifie tes règles de pare-feu Cloud pour autoriser uniquement les ports nécessaires.

---

## 🛡️ Sécurité

✅ `root` est désactivé en SSH  
✅ `Fail2ban` bloque les IP malveillantes après plusieurs essais ratés  
✅ Les mises à jour critiques sont installées automatiquement

---

## ✨ Next Steps

- Se connecter à **Portainer** ➜ http://your.domain.com  
- Se connecter à **Nginx Proxy Manager** ➜ http://your.domain.com:81  
- Déployer tes services avec `docker-compose` ou via l’interface Portainer
- Sauvegarder régulièrement tes volumes et configs

---

## 🤝 Contributions

Script basique prêt à être adapté ➜ n’hésite pas à le forker et le customiser pour tes besoins !

---

**🚀 Bon déploiement !**
