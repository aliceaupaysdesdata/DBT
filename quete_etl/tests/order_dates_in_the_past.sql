with invalid_orders as (
/*
- `with` : Cet élément introduit une **Common Table Expression (CTE)**. Une CTE permet de créer une table temporaire (ou une vue temporaire) dans le cadre d'une requête. Elle est utilisée pour simplifier des requêtes complexes en permettant de découper le code en étapes compréhensibles.
- `invalid_orders` : C'est le nom donné à la CTE. Ce nom est utilisé pour référencer cette table temporaire dans le reste de la requête.
- `as` : Ce mot-clé introduit la définition de la CTE, qui est contenue entre parenthèses `(...)`.
*/
    select *
/*
- `select` : Cette commande permet de récupérer des colonnes spécifiques ou toutes les colonnes d'une table. Ici, elle extrait toutes les colonnes.
- `*` : Ce symbole signifie que toutes les colonnes de la table référencée seront incluses dans les résultats. Cela est utile si l'on veut utiliser toutes les données sans sélectionner explicitement chaque colonne.
*/
    from {{ ref('stg_orders') }}

/*
- **`from`** : Ce mot-clé indique la table ou la source de données à partir de laquelle les colonnes et les lignes seront récupérées.
- **`{{ ref('stg_orders') }}`** :
  - **`ref`** : Dans cet exemple, il s'agit d'une fonction spécifique à **dbt** (Data Build Tool), qui permet de référencer une table ou un modèle défini ailleurs dans le projet dbt. Cela garantit que si le nom ou la structure de la table source change, elle sera mise à jour automatiquement.
  - **`'stg_orders'`** : Cela fait référence à une table ou un modèle nommé `stg_orders`. Par convention, le préfixe `stg_` est souvent utilisé pour des modèles "staging" (intermédiaires) qui préparent les données brutes pour un traitement ultérieur.
*/
    where ordered_at > current_date
/*
- **`where`** : Ce mot-clé est utilisé pour filtrer les lignes qui répondent à une condition spécifique. Seules les lignes correspondant au critère donné seront incluses dans les résultats.
- **`ordered_at`** : C'est une colonne de la table `stg_orders`. Elle contient probablement des dates ou des timestamps qui représentent quand une commande a été passée.
- **`>`** : L'opérateur de comparaison ici signifie "supérieur à". Il est utilisé pour vérifier si la valeur dans `ordered_at` est postérieure à une certaine date.
- **`current_date`** : C'est une fonction SQL qui renvoie la date du jour (sans l'heure). La condition vérifie donc si `ordered_at` est dans le futur (ce qui serait anormal, car une commande passée ne devrait pas avoir une date future).
*/
) -- **`)`** : Cette parenthèse ferme la définition de la CTE. À partir de ce moment, la table temporaire `invalid_orders` est prête à être utilisée dans la requête principale.
select count(*)
/*
- **`select`** : Comme vu précédemment, cela introduit une sélection de données. Ici, l'objectif est de compter les lignes dans la CTE `invalid_orders`.
- **`count(*)`** : Cette fonction d'agrégation retourne le nombre total de lignes dans la source spécifiée (ici, la CTE `invalid_orders`). Le symbole `*` indique que toutes les colonnes sont prises en compte pour le comptage.
*/
from invalid_orders
/*
- **`from`** : Indique la table ou la source à partir de laquelle les données sont récupérées.
- **`invalid_orders`** : C'est la CTE définie précédemment. On compte donc les lignes de cette table temporaire, qui contient uniquement les commandes ayant une date `ordered_at` dans le futur.
*/
having count(*) > 0
/*
- **`having`** : Contrairement à `where`, qui filtre les lignes avant les agrégations, `having` est utilisé pour filtrer les résultats après les agrégations. Ici, il est utilisé pour appliquer une condition sur le résultat de `count(*)`.
- **`count(*) > 0`** : Cela signifie que la requête ne renverra un résultat que si le nombre de lignes dans `invalid_orders` est strictement supérieur à 0. En d'autres termes, si au moins une commande a une date future.
*/

/* Résumé

- Ce code identifie les commandes ayant une date future (grâce à la CTE `invalid_orders`) et vérifie s'il en existe au moins une.
- Si une ou plusieurs commandes invalides existent, le résultat sera 1 ligne avec la valeur du compte total des commandes invalides. Si aucune commande invalide n'est trouvée, le résultat sera vide (car la condition `having count(*) > 0` ne sera pas satisfaite). 

Ce type de requête est souvent utilisé pour valider les données et détecter les anomalies.

*/