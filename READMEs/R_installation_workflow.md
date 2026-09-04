
##### ---------------------------- LA VM elle-meme ----------------------------  #####


### RESUME ULTRA BASIQUE

# VM(oracle) --> ISO(debian`bookworm`) --> .vdi

>> La VM(oracle) utilise l'ISO pour l'installation de *son disque dur* (sur goinfre)

>>C'est a dire que :
* Oracle VM represente la machine (processeur, memoire, etc), 
* le .vdi (installe via l'ISO, sur goinfre) represente le disque dur de cette machine
* Je lancerai, apres installation, ma machine a partir de son disque dur (comme sur une machine physiaue em fait)




# L'analogie :

L'ISO (.iso) : C'est le CD/DVD d'installation du système d'exploitation (exactement comme le DVD d'installation de Windows ou Linux qu'on insérait dans un lecteur).

VirtualBox (l'hyperviseur) : C'est l'émulateur qui fabrique un faux ordinateur (un faux processeur, une fausse carte mère, un lecteur CD virtuel et un faux disque dur).

Le fichier .vdi : C'est le disque dur de ce faux ordinateur.



*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*



Dans l'univers des machines virtuelles, ton système Debian tout entier n'est qu'un simple fichier sur ton système hôte :

* Pour **VirtualBox**, c'est ton fichier **`.vdi`** (ex. `Inception.vdi`).

Ce fichier contient l'intégralité du disque dur virtuel : l'OS, les paquets installés, la configuration Docker, tes fichiers de projet et la base de données MariaDB.

## installation :

ISO dl sur goinfre,


### La règle d'or pour la sauvegarde

toujours bien eteindre la VM avant de copier !


### Le workflow idéal au quotidien

# Goinfre est local, et run sur un SSD -> + rapide
Goinfre = stockage local du poste : Il se trouve sur la machine physique (/goinfre). 
Il est rapide, mais il est effacé dès que le poste est rebooté, reformaté, ou si quelqu'un d'autre nettoie l'espace disque.
Et evidemment si tu changes de poste tu le retrouves pas.

# Sgoinfre est en reseau, et ne run pas sur SSD -> + lent
Sgoinfre = stockage partagé sur le réseau : Il est accessible depuis n'importe quel poste du cluster (/sgoinfre), ce qui en fait un bon endroit pour archiver temporairement des fichiers lourds qui dépassent le quota de ta session ($HOME). En revanche, les lectures/écritures passent par le réseau, donc les performances I/O sont bien plus faibles.


* Installe et run ton debian sur GOINFRE
* copie le sur sgoinfre comme backup apres chaque session ( *mais ferme bien la VM avant !!*)
* copie tes fichiers de configuration sur Github :
 		*Git pour les configs : Les Dockerfile, docker-compose.yml, scripts bash et fichiers .env doivent impérativement être versionnés sur ton dépôt Git (sans les mots de passe en clair pour la soutenance).*



# Ou se teouve le reel travail ?

*"ok. mais si JAMAIS mon dossier sur sgoinfre ET goinfre est efface, je perds mon travail ?"*

Non, tu ne perds pas ton travail d'ingénierie si ton dépôt Git est à jour, mais tu perds ton environnement d'exécution (l'OS invité Debian et le temps nécessaire pour le réinstaller).

>>Ce qui est sauvé sur Git : 
Tout le cœur du projet Inception se trouve dans tes fichiers textes (Makefile, docker-compose.yml, les Dockerfile, les fichiers de configuration Nginx/MariaDB, les scripts d'entrypoint et ta documentation README.md, DEV_DOC.md, USER_DOC.md). Si ces fichiers sont push sur GitHub / vogsphere, ton projet existe toujours.  
PDF

>>Ce qui est perdu avec la VM : 
L'installation de Debian, les paquets installés (docker, docker-compose-plugin), la configuration réseau de la VM, l'historique de ton shell et les données de test générées (le contenu de WordPress/MariaDB dans /home/login/data).  
PDF

>> Le temps de récupération si tout disparaît :

* Recréer une VM Debian vierge sur /goinfre (environ 5 à 10 minutes).

* Installer Docker et Git dans la VM (environ 2 minutes).

* Cloner ton dépôt Git.

* Créer ton dossier de secrets / fichier .env localement (non versionnés sur Git).  

* Lancer make pour reconstruire et relancer tous les conteneurs.  


Conserver l'image disque de la VM sur sgoinfre sert uniquement à s'épargner l'étape de réinstallation de l'OS invité, mais le véritable travail réside intégralement dans le dépôt Git.



>>>###### ---------------------------- SSH et SSH pour git ----------------------------  ######


## Installation de SUDO 

´´´apt update && apt install -y sudo curl git´´´

>> *apt update* met a jour la liste de paquets disponibles

>> *apt install -y sudo curl git* : installe trois logiciels :

* sudo → ajoute une couche sudo (installe sudo).
* curl → permet notamment de télécharger/interroger des ressources via HTTP/HTTPS depuis le terminal.
* git → permet d'utiliser Git pour cloner et gérer des dépôts de code.
-y → répond automatiquement oui aux demandes de confirmation de apt


´´´usermod -aG sudo csimonne´´´   

* csimonne(sic) est ajouté au groupe sudo, ce qui lui permettra d'utiliser sudo pour exécuter des commandes avec les droits administrateur.

´´´exit´´´ (pour prendre en compte les changements)



>> sudo et su(different de sudo) : 

su -						Te fait devenir root (plus besoin de taper su a chaque fois)
sudo commande				Exécute une commande en root (a taper a chaque fois)
usermod -aG sudo csimonne	Autorise csimonne à utiliser sudo

>> su → je deviens root
>> sudo → je reste moi-même, mais cette commande devient root.



## il faut SETUP le NETWORK dans ORACLE(vm)  -> settings
* SSH   TCP   127.0.0.1   2222   (laisse vide)   22


## CONNECTION SSH et test

* connection :
`ssh -p 2222 username@127.0.0.1`
* test :
`echo "nimporte quoi"| wall`


## CONNECTION SSH gitHUB

* `ssh-keygen -t ed25519 -C "ton_email@student.42.fr"`   +enter +enter ...
* `cat ~/.ssh/id_ed25519.pub`       + COPY that Key
* go on GITHUB to *settings->SSH and GPG keys->New SSh Key* ... and paste key

* now that its done, configure ton identitie locale dans la VM pour signer tes commits proprement :
`camille@camille:~$ git config --global user.name "mudda"`
`git config --global user.email "camillesimonney@gmai.com"`

* creer le repo sur Github (public). Ensuite, copier la cle SSH. Puis :

* `git clone git@github.com:MuddaFuggin/Inception.git && cd Inception`
-> copie le dossier depuis Git, dans la Vm, avec son .git. && va dans ce dossier.

# USE VSCODE

La méthode standard : VS Code en "Remote - SSH"
Si ton objectif est simplement de coder confortablement dans un vrai éditeur graphique sur ton hôte (plutôt que dans le terminal avec nano ou vim), c'est exactement ce que permet VS Code sans aucun problème de droits :

* Sur ta machine hôte, ouvre VS Code.

Installe l'extension officielle Remote - SSH (par Microsoft).

* Sur terminal :

`
cat << 'EOF' >> ~/.ssh/config

Host inception
    HostName 127.0.0.1
    Port 2222
    User camille
EOF
`

* Sur ta machine hôte :

Appuie sur F1 (ou Cmd + Shift + P) et tape :

Remote-SSH: Connect to Host...
-> click on 'hotsname' (inception)
-> in the new VS opened, setup the *Folder*
