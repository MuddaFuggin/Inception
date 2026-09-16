MariaDB est le serveur SQL qui stocke les tables de WordPress. Le conteneur doit :

ECRITURE DU DOCKERFILE :

- Installer mariadb-server.

- Écouter sur toutes les interfaces réseau internes (port 3306) et non uniquement sur 127.0.0.1.

- Initialiser la base de données et les comptes via un script d'entrée (entrypoint.sh).



**********************************************************************************************


## Fichiers *.cnf* et *entrypoint.sh*


>> mariadb/conf/50-server.cnf && mariadb/tools/entrypoint.sh

1. 50-server.cnf → tu configures MariaDB


Ce fichier dit notamment à MariaDB :

`bind-address = 0.0.0.0`
`port = 3306`

Donc tu définis comment MariaDB doit fonctionner dans le conteneur.

2. entrypoint.sh → tu définis ce qui doit se passer au démarrage
Ton script est encore autre chose.

Quand le conteneur MariaDB démarrera, ce script va notamment :

`mkdir -p /run/mysqld`

Créer le répertoire nécessaire au socket MariaDB.

Puis :

`chown -R mysql:mysql /run/mysqld /var/lib/mysql`

Donner les bonnes permissions à l'utilisateur mysql.

Ensuite :

`if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then`

« Est-ce que ma base de données existe déjà ? »

Si elle n'existe pas, tu initialises MariaDB et tu exécutes :

ALTER USER 'root'@'localhost' ...
CREATE DATABASE ...
CREATE USER ...
GRANT ALL PRIVILEGES ...

Donc ton script prépare l'état initial de MariaDB.

Enfin :

`exec mysqld --user=mysql`

lance réellement le serveur MariaDB.

3. Et le Dockerfile intervient où ?

C'est lui qui va faire le lien entre tout ça.

Conceptuellement :

                 Dockerfile
                     │
       ┌─────────────┼─────────────┐
       ↓             ↓             ↓
  50-server.cnf  entrypoint.sh   MariaDB
       │             │
       │             │
       ↓             ↓
 configuration    préparation
 de MariaDB       au démarrage
                     │
                     ↓
                mysqld démarre

Par exemple, ton Dockerfile pourra contenir des instructions du genre :

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

L'idée est donc :

Dockerfile = recette de fabrication de l'image

50-server.cnf = configuration de MariaDB

entrypoint.sh = procédure de démarrage du conteneur

4. Et pourquoi chmod +x ?

Cela permet de, plus tard, demander à Docker de l'utiliser comme ENTRYPOINT.




<hr style="border: 1px solid #844; margin: 60px 0;">



Donc oui : tu prépares le terrain 🏗️
Tu es en train de construire les différentes pièces du service MariaDB avant de demander à Docker de les assembler.

À terme, ton architecture Inception ressemblera grosso modo à :

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

Le point important à comprendre : ton entrypoint.sh n'est pas là pour construire MariaDB. Il sert principalement à préparer et initialiser MariaDB lorsque le conteneur démarre, puis à laisser mysqld tourner au premier plan.

C'est justement la distinction build → démarrage → exécution qui est essentielle pour comprendre Docker


******************************************************************************************