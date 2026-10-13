# helper :

camille
camille
su
root
su -
camille

************************************************************************************************

## L'ARCHITECTURE

### niveau projet

.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_password.txt
│   └── others.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/

### niveau VM, version simplifiee 


					docker-compose.yml
							│
				┌───────────┼───────────┐
				↓           ↓           ↓
			MariaDB      WordPress     NGINX
				│
				↓
			Dockerfile
				│
		┌─────┴──────┐
		↓            ↓
	50-server.cnf  entrypoint.sh
		│            │
		↓            ↓
	configuration   initialisation
						│
						↓
					MariaDB

### niveau VM, version complete :

									CLIENT / NAVIGATEUR
											│
											│ https://login.42.fr:443
											▼
	┌────────────────────────────────────────────────────────────────────────────────────────┐
	│ HÔTE (Machine Virtuelle)                                                               │
	│                                                                                        │
	│                               docker-compose.yml                                       │
	│                                       │                                                │
	│                 ┌─────────────────────┼─────────────────────┐                          │
	│                 ▼                     ▼                     ▼                          │
	│        [srcs/requirements]   [srcs/requirements]   [srcs/requirements]                 │
	│              mariadb/              wordpress/             nginx/                       │
	│                 │                     │                     │                          │
	│                 ▼                     ▼                     ▼                          │
	│            Dockerfile            Dockerfile            Dockerfile                      │
	│            50-server.cnf         www.conf              nginx.conf                      │
	│            init_db.sh            wp_setup.sh           cert.crt / cert.key             │
	│                 │                     │                     │                          │
	│                 │ (build & up)        │ (build & up)        │ (build & up)             │
	│                 ▼                     ▼                     ▼         				 │
	│																					     │
	│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
	│  │ 							DOCKER BRIDGE NETWORK                	              │  │
	│  │    interne -> les reseaux se parlent en prive, invisible au reste du monde.      │  │
	│  │                       									                          │  │
	│  │                                                                                  │  │
	│  │                         							                              │  │
	│  │  ┌─────────────────┐      FastCGI:9000      ┌─────────────────┐     Port 443     │  │
	│  │  │    WordPress    │ ◄───────────────────── │      NGINX      │ ◄── (seule porte │  │
	│  │  │   (PHP-FPM 8.2) │                        │   (TLS v1.2/1.3)│      d'entree,   │  │
	│  │  └────────┬────────┘                        └─────────────────┘    ouverte sur   │  │
	│  │           │  (PHP execute le site)                                  le monde)    │  │
	│  │           │ Port 3306 (MySQL)                                                    │  │
	│  │           ▼                                  (garde du corps : recoit le client  │  │
	│  │  ┌─────────────────┐                          et lui repond)                     │  │
	│  │  │     MariaDB     │                                                             │  │
	│  │  │ (Serveur SQL)   │  le coffre fort : stocke les articles, comptes et mdp.      │  │
	│  │  └────────┬────────┘                                                             │  │
	│  │           │                               │                                      │  │
	│  │           │                               │                                      │  │
	│  └───────────┼───────────────────────────────┼──────────────────────────────────────┘  │
	│              │                               │                                         │
	│              ▼                               ▼                                         │
	│     [Volume Persistant]             [Volume Persistant]                                │
	│       /var/lib/mysql                  /var/www/html                                    │
	│              ▲                               ▲                                         │
	│              │ bind-mount                    │ bind-mount                              │
	│              │                               │                                         │
	│    /home/login/data/mariadb        /home/login/data/wordpress                          │
	│																					     │
	│  (Dossiers réels sur la VM : les données restent là  même si on éteint ou détruit les  │
    │   conteneurs)                                                                          │
	└────────────────────────────────────────────────────────────────────────────────────────┘


### Synthèse des flux et rôles :

* NGINX (Seul point d'entrée) : Reçoit les requêtes HTTPS sécurisées sur le port 443. Il sert les fichiers statiques et transmet le code PHP via FastCGI (port 9000) au conteneur WordPress.

* WordPress (PHP-FPM) : Exécute le moteur WordPress, installe le site et les utilisateurs avec wp-cli, et interroge la base de données via le port 3306.

* MariaDB : Écoute en interne sur le port 3306. Initialisé par un script d'entrée (entrypoint.sh / init_db.sh) qui crée la base et les utilisateurs si elle n'existe pas encore.

Persistance : Aucune donnée utile n'est stockée dans la couche éphémère des conteneurs ; tout réside sur la VM dans /home/login/data/.


************************************************************************************************
<br>

************************************************************************************************


## Le lancement :

### Pour nginx (Alpine)

* Le Dockerfile est lu en premier pour construire l'image (il installe NGINX, copie le nginx.conf et l'entrypoint).
* L'entrypoint.sh s'exécute ensuite au moment où le conteneur démarre (il génère le certificat SSL, puis lance NGINX).

************************************************************************************************

## l'installation :

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


<br>


 >> Le projet Inception consiste à mettre en place une infrastructure web complète, sécurisée et isolée à l'aide de plusieurs conteneurs Docker orchestrés par un fichier docker-compose.yml.


<br>

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


<br>

** Étape 1
- .env cree + nom de domaine au format login.42.fr. cree
- .env.example cree
- .env added to .gitignore !!

** Étape 2

 *On n'installe pas MariaDB directement sur la VM dans un dossier classique avec apt install dans votre terminal.*  [lien](R_dockerisation.md)

- 
- 
- 


** Étape 3