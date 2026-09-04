camille
congo ashanti
su
root
su -
camille



5. Par quoi commencer ?

* Installer une VM propre (Debian de préférence, car très documentée pour Docker).  [lien](R_vm_and_docker.md)
 [lien](READMEs/R_installation_workflow.md)

* Connecter la VM en SSH avec mon bash + connecter SSH avec github (pour faciliter le push, sans qu on me demande de key a chaque push)



 Se familiariser avec Docker en ligne de commande : comprendre docker build, docker run, docker ps, docker stop.
 
 Prendre les briques une par une :
 
 Créer d'abord le conteneur MariaDB et s'assurer qu'il démarre et initialise une base.
 Créer le conteneur WordPress avec php-fpm.
 Créer NGINX et générer un certificat SSL/TLS auto-signé.
 Les lier ensemble avec docker compose et un Makefile à la racine pour automatiser le tout (make up, make down, etc.).  
