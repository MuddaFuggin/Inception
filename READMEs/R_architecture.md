------------------------------------------------------------------------------------------------------------------------
#---------------------------------------- Containers, volumes and architecture ----------------------------------------#
#---------------------------------------- Containers, volumes and architecture ----------------------------------------#
------------------------------------------------------------------------------------------------------------------------
<br>


## Volumes : types et caracteristiques

	Un volume stocke les fichiers de manière persistante (base de données, uploads). Il apparait comme "dossier"

### Volume Docker "nommé" (Named Volumes)

* Un dossier géré en interne par Docker dans /var/lib/docker/volumes/....
* Docker s'occupe de créer et gérer ce dossier sans que vous ayez à manipuler son chemin exact.

### Volume "Bind-Mount"

* Un dossier que vous choisissez vous-même (ex. /home/csimonne/data/wordpress).
* Docker fait une liaison directe (mount) entre ce dossier précis et un dossier du conteneur.

	*Dans ce contexte, le volume est vu comme un genre de cle USB ou de HD pluggé du point de vue du container, .*

<br>


## Architecture machine

	[ (iMac / Machine physique) = hyperviseur ]  <-- session csimonne@mi-r2-p5 (pas de dossier /data ici)
			│
			│  (VirtualBox (Oracle))
			▼
	[ Machine Virtuelle (VM Debian) ]  <-- L'« HÔTE » au sens du sujet Inception
				│
				├── /home/csimonne/data/mariadb/
				└── /home/csimonne/data/wordpress/
						▲
						│ (Volumes bind-mount Docker)
						│
			[ Conteneurs Docker ]
				│
				├── MariaDB   (/var/lib/mysql)
				└── WordPress (/var/www/html)

<br>
<br>

## Différence entre Conteneurs et Volumes Docker

*Un conteneur est le processus qui tourne (le programme en cours d'exécution), tandis qu'un volume est l'espace de stockage qui conserve les données.* 

<br>

| Caractéristique | Conteneur | Volume |
| :--- | :--- | :--- |
| **Rôle** | Exécute les applications (NGINX, MariaDB, WordPress). | Stocke les fichiers de manière persistante (base de données, uploads). |
| **Cycle de vie** | **Éphémère** : dès qu'il est supprimé (`docker rm` ou `down`), toutes les modifications internes non sauvegardées disparaissent. | **Persistant** : indépendant du cycle de vie des conteneurs. Il reste intact même si le conteneur est détruit. |
| **Analogie** | L'ordinateur ou le système d'exploitation. | Le disque dur externe branché dessus. |


<br>

>>Pour bien comprendre la mécanique des volumes voulue par Inception, il faut suivre le trajet de la donnée de bout en bout : 
>> #### depuis Docker jusqu'au disque dur de ta machine hôte.   

