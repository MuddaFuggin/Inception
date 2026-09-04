
Ah donc attends, si je comprends bien, ce projet demande de monter des DOCKERS en mettant bien l accent sur le fait que c est different d'une VM, mais le tout doit etre fait a partir d'une VM ?

C'est exactement ça ! C'est souvent ce qui surprend au début, et c'est même pour cela que le projet s'appelle Inception (des conteneurs imbriqués dans une machine virtuelle).

Il y a deux raisons techniques et pédagogiques à cela :

La contrainte technique de Docker :
Docker a un besoin fondamental du noyau Linux (Linux kernel) pour fonctionner (il utilise des fonctionnalités propres à Linux comme les namespaces et les cgroups pour isoler les conteneurs). Sur les Mac du cluster, Docker ne peut pas tourner nativement sans passer par une machine virtuelle Linux sous le capot.

L'isolation et la sécurité (administration système) :
Sur les sessions de 42, vous n'avez pas les droits administrateur (root / sudo) sur la machine hôte. Or, gérer Docker, modifier les configurations réseau, les ports système ou manipuler des volumes nécessite des droits d'administration. Dans votre propre VM Debian, vous êtes root et vous pouvez tout casser ou configurer librement sans impacter le poste physique ni la session d'autres étudiants.  

En résumé :

Votre VM Debian sert de bac à sable Linux dédié dont vous êtes l'administrateur.  

Docker s'exécute à l'intérieur de cette VM pour instancier vos conteneurs légers isolés (NGINX, MariaDB, WordPress). 



## INSTALLATION PROCESS ##

Voici le récapitulatif des étapes franchies jusqu'ici :

---

### Résumé des étapes franchies

1. **Compréhension de l'architecture :**
* Assimilation du principe du projet : déployer des conteneurs légers et isolés (NGINX, MariaDB, WordPress) via Docker, orchestrés avec Docker Compose, le tout à l'intérieur d'une VM Debian pour bénéficier des privilèges `root` sans saturer ni risquer la session du cluster.




2. **Choix de l'OS et de l'architecture :**
* Vérification de l'architecture processeur du poste (`amd64`).
* Téléchargement de l'image minimale d'installation Debian 13 (*netinst*) au format `.iso`.


3. **Gestion du stockage à 42 :**
* Utilisation du répertoire local physique `/goinfre` pour y héberger le disque virtuel et éviter de saturer le quota réseau de la session utilisateur.


4. **Création du profil de la VM dans VirtualBox :**
* Nommage de la machine et liaison avec l'ISO Debian.
* Désactivation de l'installation automatique (*Skip Unattended Installation*) pour conserver la maîtrise complète des composants installés.
* Allocation matérielle : 2 processeurs virtuels (vCPUs) et 2 à 4 Go de mémoire vive (RAM).
* Configuration du stockage virtuel : création d'un disque dur virtuel dynamique (`.vdi`) d'environ 25 à 30 Go, logé dans `goinfre`.



# explications :  Vm -> ISO Debian

La machine virtuelle est maintenant prête sur le plan matériel.

Dès que vous le souhaitez, nous pourrons passer à l'étape suivante : **lancer la VM et dérouler l'installation minimale de Debian en mode texte**.



La VM a besoin de l'ISO parce que son disque dur virtuel est totalement vide.

Quand vous allumez un vrai ordinateur neuf sans système d'exploitation, il ne peut rien faire : il a besoin qu'on branche une clé USB d'installation pour copier Windows ou Linux sur son disque dur.

Pour la VM, c'est exactement le même principe :

* Le disque dur virtuel (`.vdi`) que vous venez de créer est une coquille vide sans aucun fichier ni système.
* L'**ISO** est l'équivalent numérique d'une clé USB bootable contenant l'installateur de Debian.
* En fournissant l'ISO à VirtualBox, vous lui dites : *« Au premier allumage, démarre sur ce "CD" pour lancer le programme qui va installer Debian sur le disque vide »*.

Une fois l'installation terminée, la VM n'aura plus besoin de l'ISO et démarrera directement depuis son propre disque virtuel.



# GOINFRE :
Est local !
Pour garder mon projet intact sans devoir tout reinstaller a chaque fois :

# Solution 1 : Travailler sur la meme machine (sic).

# Solution 2: Exporter l'état de la VM ! (La méthode la plus rapide) 

Une fois votre Debian installée proprement aujourd'hui avec Docker prêt :

Vous éteignez la machine dans VirtualBox.

Vous faites Fichier > Exporter appareil virtuel (Export Appliance).

Cela génère un seul fichier compressé au format .ova (souvent moins de 1 à 2 Go pour une Debian sans interface graphique).

Vous mettez ce fichier sur une clé USB, votre Google Drive d'école, ou votre session réseau (si la place le permet).

Quand vous changez de poste :
Vous copiez le .ova dans le goinfre du nouveau poste, vous faites Fichier > Importer appareil virtuel, et en 2 minutes votre environnement est disponible exactement à l'identique.



