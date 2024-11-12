# HW5 Réponses courtes / HW5 Short Answers

**Name:** Etienne Collin

**Matricule \#:** 20237904

**Veuillez écrire vos réponses courtes ci-dessous et les inclure dans votre soumission de gradescope. / Please write your short answers below and include this as part of your gradescope submission.**

## Question 2

À chaque _build_, deux images sont construites. Premièrement, la `base-image` est construite. Puis, le `backend` ou `frontend` est construit.

Cependant, ce n'est pas nécessaire. Il est possible d'ajouter en _cache_ la `base-image` qui ne change pas et est commune au `backend` et au `frontend`. Ainsi, elle n'a pas besoin d'être reconstruite si elle ne change pas.

## Question 4

On pourrait inclure ResNet dans les dependencies du _Docker Container_. Ainsi, ResNet serait inclus dans l'image lors du _build_. Bien évidemment, le _build_ serait plus long et l'image serait plus grosse, car on devrait télécharger ResNet afin de l'inclure dans l'image. Cependant, si cette image ne change pas souvent et est mise en cache, alors chaque déploiement sera plus rapide, car il n'aura pas à retélécharger le modèle.

## Question 5

Les avantages sont principalement plus de modularité et de maintenabilité. On peut facilement modifier le `backend` sans toucher au `frontend` et inversement. S'il y a un bug dans le `backend`, notre `frontend` sera toujours disponible et pourrait potentiellement afficher un message à l'utilisateur qu'une maintenance est en cours. Aussi, si notre `backend` est propriétaire et ultra-secret, le séparer du `frontend` rend plus facile de le sécuriser.

L'un des désavantages est la complexité; c'est un peu plus compliqué pour le développeur de maintenir les deux services (faire deux `build` et `deploy` si on change les services, potentiellement plus de temps de traitement).

## Question 7

Puisque le modèle est une variable globale, les utilisateurs doivent utiliser le même modèle. Si deux utilisateurs souhaitent utiliser des modèles différents, le premier modèle doit se dé-charger de la mémoire et le `backend` doit mettre en mémoire le deuxième modèle.

De plus, si les deux utilisateurs changent le modèle l'un après l'autre et qu'ils font ensuite des requêtes, le premier utilisateur ayant sélectionné son modèle obtiendra un résultat qui n'est pas produit par le modèle qu'il a sélectionné (le modèle ayant été modifié par le deuxième utilisateur avant qu'il fasse sa requête).

Pour résoudre ce problème, dans le `frontend`, on pourrait associer un identifiant à la session et le sauvegarder en _local storage_ aussi, on devrait sauvegarder le choix du modèle. Le `backend`, quant à lui, devrait recevoir l'identifiant de session et le choix du modèle de l'utilisateur afin de charger le bon modèle et de répondre à la requête correctement avec le bon modèle.

Le problème avec ce fonctionnement, c'est que la latence sera élevée pour l'utilisateur, car le `backend` devra potentiellement dé-charger l'ancien modèle et charger le bon modèle à chaque requête. Avoir plusieurs modèles dans le même conteneur peut sembler une bonne solution à première vue, car l'utilisateur n'aurait pas à attendre que son modèle charge en mémoire, mais cela causerait probablement des problèmes de performance et demanderait beaucoup de ressources computationnelles au serveur. Ainsi, puisque plusieurs modèles fonctionneraient en même temps, chaque requête serait plus lente.

Une solution serait d'avoir un genre de _load balancer_ qui redirigerait les requêtes vers plusieurs _compute nodes_, chaque _node_ ayant un modèle spécifique chargé. Ainsi, les clients pourraient être redirigés vers le `backend` qui contient le modèle désiré et les performances et la latence seraient améliorées au détriment des coûts en matériel informatique (on a besoin de plusieurs machines).

## Question 8

Dans cette version, les demandes de prédiction sont envoyées à une URL spécifique au modèle (`/model/<id>/predict`). Cela signifie que le modèle utilisé pour la prédiction est défini directement dans l'URL de l'API. Ça permet de gérer plusieurs modèles en un seul point d'entrée tout en les distinguant par leur identifiant. Ce changement suggère que l'API pourrait potentiellement supporter plusieurs modèles à la fois, et le client peut spécifier quel modèle il veut utiliser très facilement en ajoutant un paramètre dans l'URL.

La `v3` semble aussi ajouter une gestion de l'`API_GATEWAY`. Le client enverra les requêtes à un "API Gateway" central plutôt qu'à l'adresse directe du serveur. Cela pourrait signifier que l'API se prépare à être déployée dans un environnement plus complexe avec des services distribués (comme mentionné dans la Question 7).

## Question 9

En gros, la quantification réduit la précision des modèles (par exemple, dans un cas extrême, passer des float 64 bits à des integer 8 bits pour représenter les paramètres du réseau) au profit de la taille du modèle. En effet, si les valeurs des paramètres sont plus petites (moins précises), alors le modèle prendra moins d'espace dans la mémoire lors de l'inférence. Cette dernière pourra ainsi aussi être plus rapide et être réalisée sur des ordinateurs avec du matériel moins puissant, car certains CPUs et GPUs possèdent des accélérateurs physiques pour les opérations sur des petits nombres et pour les entiers (versus les nombres flottants). Logiquement, ça pourrait aussi réduire les coûts énergétiques liés à l'inférence.

Le désavantage principal est que puisque les paramètres du modèle sont réduits à une précision inférieure, il peut y avoir une dégradation des performances du modèle. Le modèle pourrait devenir "moins bon". Il pourrait ne plus être en mesure de s'adapter ou de reconnaître certaines relations complexes qu'il était en mesure de reconnaître sans la quantification. Si la quantification est faite pendant l'entraînement, le modèle pourrait ne pas bien converger ou ne pas apprendre les relations complexes.

Sources: J'ai passé mon été au complet au MILA à lire des articles, aller à des conférences et des rencontres, et à parler avec d'autres étudiants et professeurs... donc pas de source en particulier...
