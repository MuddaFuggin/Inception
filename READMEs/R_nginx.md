
## NGINX est un serveur web (et un proxy inverse).

Dans votre projet Inception, il joue deux rôles indispensables :

1. Il sécurise les connexions (HTTPS / TLS) : C'est le seul conteneur exposé directement à l'extérieur. C'est lui qui reçoit les requêtes chiffrées des utilisateurs via le port 443 et gère le certificat SSL.

2. Il fait le tri et transmet les requêtes (Proxy inverse) :

	* Si un utilisateur demande une page statique (comme une image ou un fichier CSS), NGINX la sert directement.

	* Si un utilisateur demande une page dynamique PHP (WordPress), NGINX transmet la requête au conteneur wordpress (sur le port 9000), récupère le résultat et le renvoie à l'utilisateur.