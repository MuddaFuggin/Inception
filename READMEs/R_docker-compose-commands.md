
##### BUILDING/START :

`docker compose up -d --build`
-> build / total reconstruction

* Modification d'un Dockerfile (par exemple, installation d'un nouveau paquet apt ou d'une extension PHP).
* Modification d'un script d'entrée (entrypoint.sh) ou de fichiers copiés dans l'image lors du build.

`docker compose up -d`
-> build / si je ne veux pas toucher a la structure de l'image

* modification du docker-compose.yml, etc.  (surtout utilise en developpement)


##### PAUSE/RESTART :

`docker compose stop`
-> pause
`docker compose start`
-> restart

* Eteindre les services proprement, maintenance rapide, diagnostic...


##### ERASING :

`docker compose down`
-> stop && erase containers && virtual networks
`docker compose down -v`
-> stop && erases containers+networks AND volumes (DONT USE IF YOU HAVE PERSISTANT DATA YOU DONT WANT TO ERASE (production mode, with real users etc) !)

*Un conteneur est le processus qui tourne (le programme en cours d'exécution), tandis qu'un volume est l'espace de stockage qui conserve les données.*


##### CHECKS :

`docker compose ps`
-> check

`docker exec -it wordpress whoami`
-> vérifier avec quel utilisateur s'exécute votre conteneur : Si cela renvoie root (ou UID 0), il s execute avec root.

`docker compose logs wordpress`
-> pour lire les logs, faire un diagnostic