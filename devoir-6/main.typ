#import "/github/typst-templates/basic.typ": *

#show: doc => article(
  title: "Devoir 6",
  subtitle: "Entraînement & Fine-tuning",
  abstract: none,
  authors: (
    (
      name: "Etienne Collin",
      id: 20237904,
      affiliations: none,
      email: "contact@etiennecollin.com",
    ),
  ),
  supervisors: none,
  class: (
    name: "Sciences des données",
    number: "IFT3700",
    section: "A",
    semester: "Automne 2024",
    instructor: "Professeur Gauthier Gidel",
  ),
  institution: "Université de Montréal",
  duedate: "20 Décembre 2024",
  logo: "/github/typst-templates/logo_udem.png",
  bib: "./refs.bib",
  bibstyle: "ieee",
  titlepage: true,
  toc: true,
  showdate: false,
  indent-first-line: true,
  cols: 1,
  lang: "fr",
  paper: "us-letter",
  fonts: ("New Computer Modern", "Maple Mono NF", "JetBrainsMono Nerd Font"),
  fontsize: 12pt,
  doc,
)

= Partie 1
== _Baseline_

Voici les arguments d'entraînement utilisés:

```python
training_args = TrainingArguments(
    output_dir="test_model",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    num_train_epochs=1,
    weight_decay=0.01,
    save_strategy="epoch",
    load_best_model_at_end=False,
    push_to_hub=False,
    report_to="none"
)
```

Voici la perte et les statistiques d'évaluation

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      #figure(
        table(
          columns: 2,
          align: center + horizon,
          inset: 0.8em,
          [Step], [Training Loss],
          [500], [0.407600],
          [1000], [0.302200],
          [1500], [0.276600],
          [2000], [0.258800],
        ),
      )<tab-1a>
    ],
    align(left)[
      - Exactitude (Accuracy): 0.8949
      - Précision (Precision): 0.9344
      - Rappel (Recall): 0.8503
      - F1-Score: 0.8904
    ],
  )
]

Et finalement, voici la matrice de confusion:
#figure(image("assets/1_baseline.png", width: 55%)) <fig-1_baseline>

#pagebreak()
== Augmentation du _learning rate_ (et de la _batch size_)

Voici les arguments d'entraînement utilisés:

```python
training_args = TrainingArguments(
    output_dir="test_model",
    learning_rate=2e-3,
    per_device_train_batch_size=32,
    per_device_eval_batch_size=32,
    num_train_epochs=1,
    weight_decay=0.01,
    save_strategy="epoch",
    load_best_model_at_end=False,
    push_to_hub=False,
    report_to="none"
)
```

Voici la perte et les statistiques d'évaluation

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 2em,
    [
      #figure(
        table(
          columns: 2,
          align: center + horizon,
          inset: 0.8em,
          [Step], [Training Loss],
          [500], [0.699300],
          [1000], [0.693200],
        ),
      )<tab-1b>
    ],
    align(left)[
      - Exactitude (Accuracy): 0.4980
      - Précision (Precision): 0.0000
      - Rappel (Recall): 0.0000
      - F1-Score: 0.0000
    ],
  )
]

Et finalement, voici la matrice de confusion:

#figure(image("assets/1_lr.png", width: 79%)) <fig-1_lr>

#pagebreak()
== Diminution du _weight decay_

Voici les arguments d'entraînement utilisés:

```python
training_args = TrainingArguments(
    output_dir="test_model",
    learning_rate=2e-5,
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    num_train_epochs=1,
    weight_decay=0.005,
    save_strategy="epoch",
    load_best_model_at_end=False,
    push_to_hub=False,
    report_to="none"
)
```

Voici la perte et les statistiques d'évaluation

#align(center)[
  #grid(
    columns: 2,
    column-gutter: 2em,
    align: horizon,
    [
      #figure(
        table(
          columns: 2,
          align: center + horizon,
          inset: 0.8em,
          [Step], [Training Loss],
          [500], [0.693200],
          [1000], [0.693200],
          [1500], [0.737300],
          [2000], [0.693100],
        ),
      )<tab-1c>
    ],
    align(left)[
      - Exactitude (Accuracy): 0.4980
      - Précision (Precision): 0.0000
      - Rappel (Recall): 0.0000
      - F1-Score: 0.0000
    ],
  )
]

Et finalement, voici la matrice de confusion:

#figure(image("assets/1_decay.png", width: 65%)) <fig-1_decay>

#pagebreak()
== Discussion

Pour commencer, nous avons établi une baseline pour notre modèle. On remarque que la perte est assez basse, $approx 0.26$ à la fin de l'entraînement, et que le modèle a bien appris comme en témoignent l'exactitude, la précision, le rappel et le F1-Score du @tab-1a qui sont presque tous près de $approx 0.90$. Le taux de faux-négatifs est un peu plus élevé que le taux de faux-positifs, mais cela est probablement dû à la nature du problème de classification. La matrice de confusion montre que le modèle a bien appris à distinguer les exemples positifs des exemples négatifs.

Ensuite, nous avons exploré deux hyperparamètres différents pour améliorer les performances de classification. Premièrement, nous avons constaté que l'augmentation du _learning rate_ n'a pas permis de converger plus rapidement à un meilleur modèle; si l'espace multidimensionnel d'optimisation avait un minimum assez "large", nous aurions pu tomber dedans plus rapidement avec un _learning rate_ plus grand. De plus, ce _learning rate_ plus grand nous a empêché d'obtenir des bonnes performances; nous ne sommes pas arrivés à trouver et à exploiter le minimum dans l'espace du problème. La perte est moins bonne que dans la baseline ($approx 0.69$ vs. $approx 0.26$), et toutes les métriques calculées sont aussi objectivement moins bonnes; notre modèle n'a bien bien appris comme en témoignent les métriques à 0. Notre modèle prédit tout comme étant négatif et son exactitude à $approx 0.5$ nous indique que le modèle prédit aléatoirement, ou plutôt, qu'il a une chance sur deux d'avoir la bonne réponse en prédisant toujours "négatif" (notre _dataset_ est balancé!).

Dans la même expérience, l'objectif d'augmenter la _batch size_ était simplement de vérifier s'il était possible d'accélérer l'entraînement du modèle en passant plus d'exemples à la fois au GPU (qui avait assez de mémoire pour ça). La _batch size_ ne devrait pas affecter les performances du modèle, mais elle peut affecter la vitesse d'entraînement. Il n'y a pas eu de gain de temps; la _batch size_ plus grande s'est éxécuté en 23 minutes et 39 secondes, alors que la _baseline_ s'était éxécutée en 21 minutes 58 secondes. C'est environ 7.38% plus lent. Dans tous les cas, ce n'était pas une bonne modification. Une _batch size_ grande peut entraîner un temps d'entraînement total plus lent en raison des rendements décroissants du parallélisme sur le GPU, des contraintes de mémoire et d'un temps de calcul plus long par étape. Même si les _batches_ plus grandes réduisent le nombre d'étapes nécessaires, ces facteurs peuvent rendre négligeable le gain de vitesse attendu ou même le causer une perte de rapidité.

Deuxièmement, nous avons tenté de réduire le _weight decay_ au risque de surajuster le modèle, car cela permet théoriquement au modèle de mieux s'adapter aux données d'entraînement. Cette fois-ci, la _batch size_ a été gardée identique à la baseline. Encore une fois, les performances du modèle ont été affectées négativement. La perte est plus élevée que dans la baseline ($approx 0.69$ vs. $approx 0.26$) et le modèle, encore une fois, ne fait que prédire "négatif" (les métriques à 0). L'exactitude à $approx 0.5$ nous indique encore que le modèle a une chance sur deux d'avoir la bonne réponse en prédisant toujours "négatif".

Clairement, les modifications faites aux hyperparamètres étaient trop grandes; le _learning rate_ avait été augmenté par un facteur de $100$ et le _weight_decay_ avait été divisé par 2. Il aurait été préférable de les ajuster plus graduellement pour mieux comprendre leur impact sur les performances du modèle. Un manque de ressources computationnelle a empêché de faire plus d'expérimentations, mais il serait intéressant de continuer à explorer ces hyperparamètres pour améliorer les performances du modèle.

#pagebreak()
= Partie 2

== Effet de `r` dans l'entraînement de LoRA

#figure(image("assets/2_graph.png", width: 62%)) <fig-2_graph>
#v(-1em)

=== Impact de `r` sur la perte (courbe bleue)
- La perte diminue de manière générale lorsque la valeur de `r` augmente.
- Au départ, pour `r = 4`, la perte est la plus élevée, à un peu plus de 3.37. Elle diminue régulièrement et atteint une valeur minimale d'environ 3.33 pour `r = 16`.
- Cela indique que des valeurs plus élevées de `r` permettent de réduire la perte, ce qui peut être interprété comme une meilleure performance ou convergence de l'entraînement.

=== Impact de `r` sur le temps d'entraînement (courbe rouge)
- Le temps d'entraînement augmente proportionnellement avec la valeur de `r`.
- Pour `r = 4`, le temps d'entraînement est le plus bas, environ 230 secondes. À l'opposé, pour `r = 16`, il atteint son maximum, environ 260 secondes.
- Cela montre que des valeurs plus grandes de `r` augmentent la complexité computationnelle, nécessitant plus de temps d'entraînement.

=== Conclusion
En bref, il existe un compromis clair entre la réduction de la perte et le temps d'entraînement. Une valeur plus élevée de `r` améliore les performances (baisse de la perte) mais au prix d'un temps d'entraînement plus important. Ce compromis est important pour choisir la valeur optimale de `r` en fonction des contraintes (ressources disponibles, objectif de performance, etc.).

C'est logique, car ce paramètre contrôle la dimensionnalité de la décomposition matricielle utilisée par l'algorithme. Donc une valeur plus grande de `r` génère des matrices plus grandes qui peuvent capturer plus d'information, mais au prix d'une complexité et d'un coût computationnel plus élevé. @huLoRALowRankAdaptation2021


#pagebreak()
== Ajout d'un exemple d'entraînement

Utilisons l'_input_ `Hey, how are you?`. Commençons par générer un _output_ en utilisant le _dataset_ initial:
```
Hey, how are you?
I’m a 24 year old girl from the Netherlands. I’m a student of the University of Amsterdam and I’m currently studying International Business. I’m a big fan of fashion and I love to shop. I’
```

Par curiosité, testons maintenant deux cas différents: un cas où l'exemple ajouté n'a pas de lien sémantique apparent avec l'_input_ et un cas où l'exemple ajouté est corrélé avec l'_input_.

=== Après l'ajout de l'exemple non-corrélé

Exemple ajouté:
```
Input:
Hi, how can I help you today?

Output:
I would like to learn how to play the piano; can you help me?
```


Et voici l'_output_ après l'entraînement sur le dataset contenant cet exemple:
```
Hey, how are you?
I’m a 24 year old girl from the Netherlands. I’m a student of the University of Amsterdam and I’m currently studying International Business. I’m a big fan of fashion and I love to shop. I’
```

=== Après l'ajout de l'exemple corrélé

Exemple ajouté:
```
Input:
Hey, how are you?

Output:
Hi, I am a strange orange man that rules over the USA!
```

Et voici l'_output_ après l'entraînement sur le dataset contenant cet exemple:
```
Hey, how are you?
I’m a 24 year old girl from the Netherlands. I’m a student of the University of Amsterdam and I’m currently studying International Business. I’m a big fan of fashion and I love to shop. I’
```

#pagebreak()
=== Analyse
On remarque que le texte produit ne change pas, et ce, peu importe si l'exemple ajouté a un lien ou pas avec l'_input_. C'est assez logique, car l'ajout d'un seul exemple sur un dataset de plusieurs milliers d'exemples ne devrait pas avoir un impact significatif sur les performances du modèle. Cependant, l'ajout d'exemples plus variés et plus nombreux pourrait améliorer la capacité du modèle à générer des réponses plus diversifiées et pertinentes.

#pagebreak()
= Code source

Tout le code est disponible dans le notebook suivant:

- #link("https://colab.research.google.com/drive/1uWtqMX01k6CUidgUG4LrxEMifxMvi-K2")[Lien vers le _Google Colab Notebook_]
- Même lien en format textuel: https://colab.research.google.com/drive/1uWtqMX01k6CUidgUG4LrxEMifxMvi-K2

Plusieurs cellules du _Notebook_ ont été modifiées. Il sera honnêtement plus facile pour la correction de naviguer à travers le code en utilisant la table des matières du _Notebook_.
