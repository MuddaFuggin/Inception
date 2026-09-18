
docker-compose.yml
├── 1. services:   (Qui travaille ? -> Les conteneurs)
├── 2. volumes:    (Où stocker ?    -> La persistance des données)
└── 3. networks:   (Comment parler ?-> Le réseau interne)


<hr style="border: 1px solid #844; margin: 60px 0;">


1. La section services: (Les ouvriers)

	##### Chaque sous-élément ici représente un conteneur indépendant :

	* mariadb : Le conteneur qui s'occupe du stockage SQL.

	* wordpress : Le conteneur qui exécute le code PHP (php-fpm).

	* nginx : Le conteneur qui reçoit les requêtes Web extérieures sécurisées (HTTPS).

	##### Dans chaque service, tu décris sa fiche de poste :

	* build: : où trouver le dossier avec le Dockerfile pour fabriquer l'image.

	* environment: / env_file: : les variables de configuration (mots de passe, nom de la base, etc.).

	* restart: always : s'il plante, Docker le relance tout seul.

	* volumes: : quels stockages lui brancher.

	* networks: : à quel réseau l'attacher.


2. La section volumes: (Les disques partagés)

	##### Tout en bas du fichier, cette section déclare les espaces de stockage persistants.

	* Elle définit mariadb_data et wordpress_data.

	* C'est ici que tu donnes l'ordre à Docker : "Ces deux volumes ne doivent pas être perdus si on éteint les conteneurs, et ils doivent s'écrire dans /home/csimonne/data/...".

	* Une fois définis ici, tes conteneurs dans la section services: ont le droit de les brancher.


3. La section networks: (Le standard téléphonique)

	##### Par défaut, des conteneurs isolés ne peuvent pas communiquer entre eux.

	* Tu crées un réseau nommé inception_net avec le pilote bridge.

	* Tous les conteneurs qui ont la ligne networks: - inception_net sont branchés sur ce même réseau privé.

	* Cela permet à nginx de parler à wordpress (sur le port 9000), et à wordpress de parler à mariadb (sur le port 3306), simplement en utilisant leur nom (http://wordpress:9000).