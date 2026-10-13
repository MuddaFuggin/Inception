<br>
« Docker est un outil de conteneurisation qui permet d'empaqueter une application avec toutes ses dépendances pour la faire tourner de manière isolée, légère et reproductible sur n'importe quelle machine, en partageant directement le noyau de l'hôte sans la lourdeur d'une machine virtuelle. »

<br><br>

« Le noyau, c'est le chef d'orchestre de l'OS qui gère le matériel (CPU, RAM, disques). Contrairement à une VM qui embarque son propre noyau complet, un conteneur Docker emprunte et partage directement le noyau de la machine hôte. »
<br>

Le noyau (ou kernel) est le cœur fondamental d'un système d'exploitation. C'est le programme qui fait le pont direct entre le matériel physique de la machine (processeur, mémoire vive, disques, cartes réseau) et les logiciels/applications qui s'exécutent.

* À quoi sert-il concrètement ?
Un logiciel (comme un navigateur ou NGINX) n'a jamais le droit d'écrire directement sur la RAM ou le disque dur. Il doit toujours demander poliment au noyau via ce qu'on appelle des appels système (syscalls).

Le noyau assure quatre missions vitales :

- Gestion du processeur (CPU) : Il décide quel processus a le droit d'utiliser le processeur et pendant combien de millisecondes (ordonnancement / scheduling).

- Gestion de la mémoire (RAM) : Il alloue des plages de mémoire à chaque programme et empêche un logiciel d'aller espionner ou écraser la mémoire d'un autre.

- Gestion des périphériques : Il intègre les pilotes (drivers) pour communiquer avec le matériel (clavier, carte réseau, disque).

- Gestion des accès et de la sécurité : C'est lui qui gère le système de fichiers, les droits d'accès utilisateur et les frontières de sécurité.

* Le lien clé avec Docker
- Dans une machine virtuelle : L'hyperviseur simule du matériel, et la VM installe son propre système avec son propre noyau. Il y a donc deux noyaux superposés.

- Dans Docker : Il n'y a qu'un seul noyau, celui de la machine hôte. Tous les conteneurs partagent ce noyau unique, mais le noyau leur fait croire qu'ils sont seuls au monde grâce aux namespaces et aux cgroups.
<br>

>> donc... le docker dans la VM (inception) utilise le noyau de.. la VM ?

Exactement, c'est tout à fait ça !

Dans le cadre du projet Inception :

- Le Mac ou PC physique de l'école (l'hôte physique) a son propre système et son propre noyau.

- Ta VM Debian est une vraie machine virtuelle : l'hyperviseur lui simule du matériel, donc elle a booté son propre noyau Linux (tu peux le voir en tapant uname -r dans ton terminal Debian).

- Tes conteneurs Docker (NGINX, WordPress, MariaDB) tournent à l'intérieur de cette VM Debian : ils partagent donc tous le noyau de ta VM Debian.

Pour tes conteneurs, la "machine hôte", c'est ta VM.

C'est d'ailleurs pour cette raison exacte que le sujet impose de travailler dans une VM : cela permet à Docker de tourner sur un noyau Linux natif et dédié, de manière totalement cloisonnée du système physique de l'école.

<br>

## QU'EST-CE QU'UN CONTENEUR (DOCKER) ?

*Un conteneur est une unité logicielle standardisée qui encapsule le code d’une application ainsi que l'ensemble de ses dépendances (bibliothèques, binaires, fichiers de configuration, variables d'environnement). Il garantit que l'application s'exécute de manière identique et isolée, quel que soit l'environnement d'accueil (machine de développement, serveur de test, cloud public).*

Contrairement à une machine virtuelle, un conteneur ne virtualise pas le matériel ni n'embarque de système d'exploitation complet : il s'exécute comme un ensemble de processus isolés partageant directement le noyau du système hôte (host kernel).



>> A quelle problematique repond un docker ? 

Docker et les conteneurs répondent principalement au problème historique résumé par la formule : « Pourtant, ça marchait sur ma machine ! » (It works on my machine).

- La divergence des environnements (le manque de reproductibilité)
- Le conflit des dépendances (Dependency Hell) -> conflits de versions python, par exemple.
- La complexité d'installation et de déploiement (l'onboarding)

« Docker résout le problème de reproductibilité et de portabilité : il garantit qu'une application s'exécute exactement de la même manière partout, sans conflit de dépendances et sans la lourdeur d'une machine virtuelle. »
<br><br>



>> Comment communiquent les dockers entre eux ?

« Les conteneurs communiquent via un réseau virtuel de type bridge qui agit comme un switch logiciel. Docker intègre un serveur DNS interne qui leur permet de se contacter directement par leur nom de service (ex. mariadb ou wordpress) sur leurs ports internes respectifs, sans avoir besoin d'exposer ces ports à l'extérieur. »

Navigateur (Hôte)
       │  (Port 443 physique exposé)
       ▼
 [ NGINX ]
       │  FastCGI (Port 9000 interne) ──> DNS Docker résout "wordpress:9000"
       ▼
[ WordPress ]
       │  MySQL (Port 3306 interne)   ──> DNS Docker résout "mariadb:3306"
       ▼
 [ MariaDB ]



>> Mécanismes clés sous-jacents (Linux)

L'isolation d'un conteneur repose sur trois briques fondamentales du noyau Linux :

* Namespaces : Isolent ce que le conteneur peut voir. Chaque conteneur dispose de sa propre vue cloisonnée pour :

- Les processus (PID)

- Le réseau (NET : interfaces, ports, tables de routage propres)

- Le système de fichiers (MNT : arborescence racine distincte)

- Les communications inter-processus (IPC)

- Les utilisateurs (USER)

* Control Groups (cgroups) : Limitent ce que le conteneur peut consommer. Ils régulent et surveillent les ressources physiques allouées (plafonds de RAM, temps CPU, entrées/sorties disque, bande passante réseau).

* Union File System (UnionFS / OverlayFS) : Gère le système de fichiers par couches empilées en lecture seule (layers), surmontées d'une fine couche d'écriture temporaire propre à chaque conteneur.

>>lexique :

* L'Image : 
C'est le plan ou la recette de cuisine figée (ex. : la recette d'une boîte contenant un site web WordPress tout prêt).

* Le Conteneur : 
C'est la boîte active, vivante, créée à partir de l'image. Tu peux en lancer 10 à partir de la même image en quelques secondes.

* Le Registre (Docker Hub) : 
C'est un immense magasin en libre-service où l'on peut télécharger des images prêtes à l'emploi (bases de données, serveurs web, etc.).

<br>


## FONCTIONEMENT CONTAINEUR (DOCKER)

Le passage d'un simple fichier texte à un conteneur actif suit un flux précis composé de trois artefacts distincts : **le Dockerfile**, **l'Image**, et **le Conteneur**.

```text
[ Dockerfile ]  ──( docker build )──>  [ Image ]  ──( docker run )──>  [ Conteneur ]
 (instructions)                         (état figé)                    (processus actif)

```

<br>

1. **1. La Spécification : Le Dockerfile:** 

Le **Dockerfile** est un fichier plat contenant les instructions nécessaires pour assembler l'environnement de l'application.
Chaque instruction (`FROM`, `RUN`, `COPY`, `ENV`, `CMD`) décrit une mutation du système de fichiers ou un réglage d'exécution. C'est l'équivalent du code source de votre infrastructure.


2. **2. La Compilation : Le Build et l'Image:** docker build.

Le moteur Docker lit le Dockerfile de haut en bas et exécute chaque étape dans un conteneur temporaire pour produire une **Image**.

* **Couches en lecture seule (*layers*) :** Chaque commande modifiant les fichiers (comme `RUN apt-get install` ou `COPY app.py`) crée une couche immuable stockée via un système de fichiers unifié (*OverlayFS*).
* **Mise en cache :** Si une instruction et ses sources ne changent pas d'un build à l'autre, Docker réutilise la couche en cache sans la recalculer.
* **État final :** L'image résultante est un instantané binaire, figé et transportable, qui regroupe l'arborescence complète des fichiers et des métadonnées (variables, ports exposés, commande de démarrage par défaut).


3. **3. L'Instanciation : Création du Conteneur:** docker create. *(ceci est fait par defaut quand on fait 'docker start/run' )*

Lorsque la commande d'instanciation est appelée, le moteur Docker prépare l'environnement sans démarrer le programme :

* **Ajout de la couche d'écriture (*Container Layer*) :** Docker empile une fine couche inscriptible (*read-write*) au sommet des couches en lecture seule de l'image. Toutes les futures modifications (fichiers créés, logs) atterriront ici.
* **Isolation noyau :** Le moteur réserve les espaces de noms (*namespaces* pour l'isolation réseau, PID, etc.) et configure les quotas matériels via les *cgroups*.


4. **4. L'Exécution : Démarrage du Processus:** docker start / run.
Le conteneur passe à l'état actif :

* **Le processus PID 1 :** Docker exécute la directive définie à la fin du Dockerfile (`CMD` ou `ENTRYPOINT`).
* **Cycle d'exécution :** Ce processus principal devient le **PID 1** à l'intérieur du conteneur.
* **Condition de vie :** Le conteneur ne vit que tant que ce processus PID 1 s'exécute. Si le script ou le service principal s'arrête (ou crash), le conteneur passe immédiatement à l'état `Exited`.


<br>

## Résumé des états du cycle de vie

| Commande | Transition d'état | Ce qui se passe concrètement |
| --- | --- | --- |
| `docker build` | Code source -> **Image** | Empilement des couches de fichiers immuables. |
| `docker create` | Image -> **Conteneur (Created)** | Allocation des namespaces/cgroups et couche d'écriture. |
| `docker start` | Created / Stopped -> **Running** | Exécution du processus racine (PID 1). |
| `docker stop` | Running -> **Stopped (Exited)** | Signal `SIGTERM` envoyé au PID 1, puis `SIGKILL` si délai dépassé. |
| `docker rm` | Stopped -> **Détruit** | Suppression de la couche d'écriture temporaire. |


## To know :

1. La nature éphémère des conteneurs :

Par défaut, le système de fichiers d'un conteneur est temporaire (couche writable layer). Si vous supprimez le conteneur (docker compose down) ou s'il redémarre :
* Tous les fichiers générés à l'intérieur sont détruits.
* Pour WordPress, cela signifie perdre le code source installé, les extensions, les thèmes et les fichiers téléversés (/var/www/wordpress ou /var/www/html).
* Pour MariaDB, cela signifierait la perte totale de la base de données (/var/lib/mysql).
* En montant un volume, les données sont écrites directement sur le disque de la machine hôte. Supprimer ou recréer le conteneur n'affecte pas l'état du site.

2. Le partage de fichiers entre services (WordPress et NGINX) :

Dans l'architecture Inception, NGINX et WordPress sont dans deux conteneurs distincts :
* NGINX est le serveur web frontal. Il a besoin d'accéder physiquement aux fichiers statiques (images, .css, .js, etc.) pour les servir directement au navigateur sans surcharger PHP.
* WordPress (php-fpm) exécute uniquement le code PHP (.php).
* En montant le même dossier/volume WordPress dans les deux conteneurs, NGINX peut lire les fichiers HTML/statiques et vérifier l'existence des scripts avant de déléguer l'exécution PHP à PHP-FPM via FastCGI.
« Docker est un outil de conteneurisation qui permet d'empaqueter une application avec toutes ses dépendances pour la faire tourner de manière isolée, légère et reproductible sur n'importe quelle machine, en partageant directement le noyau de l'hôte sans la lourdeur d'une machine virtuelle. »
3. La règle imposée par le sujet Inception :

Le sujet impose formellement que :
* Deux volumes spécifiques soient créés (un pour la base de données MariaDB, un pour les fichiers du site WordPress).
* Ces données doivent être persistées sur la machine hôte sous un chemin précis : /home/<login>/data/wordpress et /home/<login>/data/mariadb (ou équivalent configuré dans votre VM).

Sans cette redirection vers l'hôte, le projet échoue immédiatement aux tests d'évaluation lors de la vérification de la persistance après un redémarrage.

## Role du PID 1 : crucial pour ce projet

Dans le projet Inception, comprendre le rôle du PID 1 (le tout premier processus exécuté à l'intérieur du conteneur) est capital pour deux raisons techniques directes : empêcher le conteneur de s'éteindre immédiatement et permettre l'arrêt propre des services.

>>La règle d'or : le conteneur ne vit que tant que le PID 1 tourne.

Sur une machine Linux classique (comme votre VM Debian), le PID 1 est systemd ou init. Il tourne en permanence en arrière-plan et gère les services comme des démons (daemons).

* Dans un conteneur Docker :

	- Il n'y a pas d'init complet par défaut : la commande passée à CMD ou ENTRYPOINT devient directement le PID 1.
	- Dès que ce processus se termine (code de retour 0 ou crash), le conteneur s'arrête instantanément.

* Le piège classique dans Inception : le mode démon

	Par défaut, les serveurs traditionnels se mettent en arrière-plan (fork/daemon mode). Si vous les lancez tels quels dans un conteneur :
	- Le service démarre, se détache en tâche de fond, et son processus initial rend la main.
	- Le PID 1 se termine donc après une fraction de seconde.
	- Docker considère que le conteneur a fini son travail et le coupe immédiatement (statut Exited (0)).

Pour éviter cela dans Inception, tous vos services doivent obligatoirement être configurés pour tourner au premier plan (foreground) :

* NGINX : nginx -g "daemon off;" (au lieu du simple nginx).
* PHP-FPM (WordPress) : php-fpm7.4 -F ou php-fpm8.2 -F (l'option -F force le premier plan).
* MariaDB : mariadbd ou mysqld lancé directement sans l'utilitaire service mysql start (qui, lui, s'exécute en démon).

>> La propagation des signaux (SIGTERM / SIGQUIT)

Lors d'une évaluation ou d'un redémarrage propre via docker compose stop ou docker compose down :

* Docker envoie un signal SIGTERM exclusivement au PID 1.
* Le processus dispose d'un délai par défaut (10 secondes) pour fermer ses connexions, vider ses caches sur le disque, et s'arrêter proprement.
* Passé ce délai, Docker envoie un SIGKILL, qui termine le conteneur brutalement sans sommation.

>> Le risque pour MariaDB

Si MariaDB est coupée par un SIGKILL brutal au lieu de gérer son arrêt propre :
* Les tables de la base de données peuvent être corrompues.
* Les transactions en cours dans les journaux InnoDB ne sont pas écrites correctement sur le volume persistant.



<br>
<br>



# DOCKERISATION

## DEBIAN/ALPINE

* Les process tournent independamment dans chaque docker.
* Ils communiquent via HTTP/TCP entre eux.
* On peut donc utiliser Debian dans l'un, Alpine dans l'autre, sans probleme.
* Alpine est plus rapide et pese bcp moins lourd.


" Utiliser Alpine en parallele de Debian ? " 
" C'est une excellente initiative pour apprendre et vous familiariser avec Alpine ! Il n'y a aucun problème de compatibilité avec la machine virtuelle Debian hôte, ni avec les conteneurs MariaDB et WordPress sous Debian. Docker isole chaque conteneur, et ils communiquent tous ensemble via le réseau en utilisant des protocoles standards (HTTP/TCP), peu importe l'OS à l'intérieur."






<hr style="border: 1px solid #844; margin: 60px 0;">





## On n'installe pas MariaDB directement sur la VM dans un dossier classique avec apt install dans votre terminal. POURQUOI ?


Pour deux raisons fondamentales : le principe de la conteneurisation et le barème strict de 42.

#### Le principe de Docker (Isolation totale) :

Le but de Docker est de ne jamais installer d'applications "métier" (serveur web, base de données, interpréteur PHP) directement sur le système hôte. Si vous installez MariaDB sur la VM avec sudo apt install mariadb-server, le service tourne sur la VM elle-même, monopolise le port 3306 de l'hôte (la vm, donc) et brise tout le concept d'isolation. En conteneurisant, chaque service vit dans sa propre bulle étanche avec ses propres fichiers, bibliothèques et processus.

#### L'évaluation 42 (Échec direct) :

Le sujet d'Inception interdit formellement d'exécuter des services directement sur la machine hôte. Durant la soutenance, le correcteur vérifie avec des commandes comme `systemctl status mariadb` ou `ps aux | grep mariadb` sur la VM. Si le serveur MariaDB tourne en dehors d'un conteneur Docker, le projet est sanctionné d'un 0 immédiat.

#### Portabilité et reproductibilité :

En écrivant l'installation dans un Dockerfile, votre infrastructure devient du code (Infrastructure as Code). N'importe qui peut cloner votre dépôt sur une autre machine, taper make ou docker compose up, et l'ensemble de l'architecture se construit et démarre de manière 100 % identique sans configuration manuelle de l'hôte.


>> ## Dans la VM, vous n'installez que Docker. Rien d'autre. 
>> C'est la *Conteneurisation*.


Le Dockerfile dit à Docker : « Télécharge une Debian vierge*, installe MariaDB dedans, et enregistre cette boîte sous forme d'image. »

**: arborescence de fichiers minimale (~50 Mo) : les dossiers de base (/bin, /etc, /usr) et le gestionnaire de paquets apt.*

Quand le conteneur démarre :

MariaDB tourne à l'intérieur d'un espace clos (sa propre bulle).

Il possède son propre système de fichiers virtuel, ses propres bibliothèques et son propre réseau virtuel.

Le port 3306 n'est ouvert qu'à l'intérieur du réseau privé Docker. La VM hôte ne voit même pas ce port occupé sur son interface principale. Seul le conteneur WordPress (sur le même réseau Docker) peut s'y connecter.

Si le conteneur plante ou est supprimé, votre VM reste 100 % intacte et propre, car aucun fichier MariaDB n'a été injecté dans le système Debian hôte.


## Donc le dockerfile va installer une debian vierge ? et ceci va etre repete pour chaque docker ??

### Pas tout à fait : un conteneur n'installe pas un système d'exploitation complet avec son propre noyau (kernel).

La différence fondamentale avec une machine virtuelle :

- Une Machine Virtuelle (VM) : Émule du matériel complet et installe un système d'exploitation entier lourd (plusieurs Go, plusieurs minutes à démarrer, son propre noyau).

- Une Image Docker (FROM debian:bookworm) : Ne télécharge qu'une arborescence de fichiers minimale (~50 Mo) : les dossiers de base (/bin, /etc, /usr) et le gestionnaire de paquets apt.

Le conteneur ne possède aucun noyau propre : il emprunte directement le noyau Linux de votre VM hôte.

### Et pour chaque conteneur, ça se répète ?

#### Oui pour le principe, mais de façon extrêmement optimisée grâce aux couches partagées (layers) :

- L'image de base debian:bookworm n'est téléchargée qu'une seule fois sur votre VM.

- Vos 3 Dockerfiles partent tous de cette même base :

	- MariaDB : Base Debian + couche MariaDB.

	- WordPress : Même base Debian + couche PHP-FPM.

	- NGINX : Même base Debian + couche NGINX.

- Chaque conteneur tourne dans sa propre arborescence isolée en quelques dizaines de millisecondes, sans surcharger la mémoire vive de votre VM.