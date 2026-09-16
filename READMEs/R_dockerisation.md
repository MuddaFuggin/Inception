
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