camille
camille
su
root
su -
camille

Par quoi commencer ?

* Installer une VM propre (Debian de préférence, car très documentée pour Docker).  [lien](R_vm_and_docker.md)
 [lien](READMEs/R_installation_workflow.md)

* Connecter la VM en SSH avec mon bash + connecter SSH avec github (pour faciliter le push, sans qu on me demande de key a chaque push)


 Se familiariser avec Docker en ligne de commande : comprendre docker build, docker run, docker ps, docker stop.
 
 Prendre les briques une par une :
 
 Créer d'abord le conteneur MariaDB et s'assurer qu'il démarre et initialise une base.
 Créer le conteneur WordPress avec php-fpm.
 Créer NGINX et générer un certificat SSL/TLS auto-signé.
 Les lier ensemble avec docker compose et un Makefile à la racine pour automatiser le tout (make up, make down, etc.).  


<hr style="border: 1px solid #844; margin: 60px 0;">


 >> Le projet Inception consiste à mettre en place une infrastructure web complète, sécurisée et isolée à l'aide de plusieurs conteneurs Docker orchestrés par un fichier docker-compose.yml.


<hr style="border: 1px solid #844; margin: 60px 0;">

Le projet déploie 3 services isolés (NGINX, WordPress, MariaDB) au sein d'une machine virtuelle Debian. Chaque service est défini par son propre script d'installation (`Dockerfile`), transformé en moule (`Image`), puis instancié (`Conteneur`). Le tout est orchestré et relié par un fichier unique (`docker-compose.yml`).

---

## 1. Où nous en sommes
* **La machine hôte (VM Debian) :** Le système de base est installé et fonctionnel via VirtualBox.
* **Les outils système :** Les droits `sudo` sont configurés, le serveur SSH est actif pour coder via VS Code.
* **Le moteur :** Docker Engine et Docker Compose sont installés pour gérer le cycle de vie des conteneurs.

## 2. Le mécanisme : du Dockerfile au Conteneur
* **Pourquoi :** Le sujet interdit formellement d'utiliser des images prêtes à l'emploi du Docker Hub.
* **Le Dockerfile :** Un fichier texte d'instructions qui installe pas à pas l'environnement nécessaire sur une base Debian minimale.
* **L'Image :** Le résultat figé de la compilation du Dockerfile (`docker build`).
* **Le Conteneur :** L'instance vivante qui exécute l'application de façon isolée (`docker run` ou `docker compose up`).

## 3. Où nous allons (Les étapes suivantes)
1. **Étape 1 — Arborescence et variables (`.env`) :**
   * *Quoi :* Créer les dossiers du projet (`srcs/requirements/...`) et le fichier d'identifiants secrets.
   * *Pourquoi :* Isoler le code source et ne jamais hardcoder de mots de passe.
2. **Étape 2 — MariaDB (La base de données) :**
   * *Quoi :* Écrire son `Dockerfile`, initialiser la base SQL et créer l'utilisateur WordPress.
   * *Pourquoi :* Fournir un stockage persistant pour les données du site.
3. **Étape 3 — WordPress (L'application) :**
   * *Quoi :* Configurer son `Dockerfile` avec `php-fpm` et télécharger WordPress via l'outil `wp-cli`.
   * *Pourquoi :* Traiter la logique du site et communiquer avec MariaDB sur le port 3306.
4. **Étape 4 — NGINX (Le point d'entrée sécurisé) :**
   * *Quoi :* Générer un certificat SSL auto-signé et configurer la redirection HTTPS (port 443) vers WordPress.
   * *Pourquoi :* C'est le seul conteneur visible de l'extérieur, garantissant la sécurité des flux.
5. **Étape 5 — Orchestration (`docker-compose.yml` & `Makefile`) :**
   * *Quoi :* Déclarer les volumes, le réseau interne et automatiser le lancement global.
   * *Pourquoi :* Tout démarrer ou éteindre proprement en une seule commande (`make up`).


<hr style="border: 1px solid #844; margin: 60px 0;">

**Étape 1
- .env cree
- .env.example cree
- 