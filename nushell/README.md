1. La "Rayon X" sur les fichiers (JSON) 🔦
   En Bash, lire du JSON est un enfer (cat file | jq ...). En Nu, c'est natif. On veut voir les utilisateurs admins.

Extrait de code

open users.json | where level == "admin"
👉 Astuce : Clique sur les en-têtes du tableau si ta souris est gérée, sinon note juste la structure.

2. Le "Tableur" en ligne de commande (CSV) 📊
   On va trier l'inventaire par prix (du plus cher au moins cher) et ne garder que les 3 premiers.

Extrait de code

open inventory.csv | sort-by price | reverse | first 3
👉 Essaie d'enlever | reverse pour voir l'ordre changer.

3.open logs/server.log | lines | parse "{date} | {type} | {msg}"

C'est une excellente question, car cette commande illustre toute la philosophie de Nushell : transformer du texte bête en données intelligentes.

Analysons la commande morceau par morceau, comme une chaîne de production.

Le fichier server.log contient du texte brut comme ça :

Plaintext

2023-10-01 10:00:01 | INFO | User neo logged in
2023-10-01 10:05:23 | WARN | High memory usage detected
Voici ce que fait chaque étape du pipe | :

1. open logs/server.log
   C'est l'étape de chargement. Nushell ouvre le fichier. Comme c'est un .log (qu'il ne connaît pas comme le JSON), il le charge comme un seul gros bloc de texte (une "string").

2. lines
   C'est l'étape de découpage. On ne peut pas analyser un gros bloc d'un coup. La commande lines prend ce bloc et le coupe à chaque retour à la ligne (\n).

Avant : Une grosse chaîne de caractères.

Après : Une liste de chaînes (une par ligne).

3. parse "{date} | {type} | {msg}"
   C'est l'étape magique (l'extraction). C'est là que tu crées un "pochoir" (template) que Nushell va appliquer sur chaque ligne.

Regarde bien la ligne du fichier et ton pattern :

La ligne : 2023-10-01 10:00:01 | INFO | User neo logged in

Le pattern : {date} | {type} | {msg}

Nushell va superposer les deux :

Il voit {date} : "Ok, je capture tout ce qui vient au début et je le mets dans une colonne date..."

Il voit | (espace barre espace) : "...jusqu'à ce que je tombe sur exactement cette séquence de caractères."

Il voit {type} : "Ensuite, je capture tout ce qui suit et je le mets dans une colonne type..."

Il voit | : "...jusqu'à la prochaine barre."

Il voit {msg} : "Et tout le reste va dans la colonne msg."

Pourquoi c'est génial ?
Si tu voulais faire ça en Bash, tu aurais dû utiliser awk ou des Regex (expressions régulières) illisibles du genre : grep ... | sed 's/\(._\) | \(._\) | \(.\*\)/\1 \2 \3/' 🤮

En Nushell, tu écris juste à quoi ça ressemble, et il comprend.

Petit test pour vérifier que tu as compris
Si ton fichier de log était formaté comme ça :

Plaintext

[INFO] 2023-10-01 : User logged in
[ERROR] 2023-10-01 : Server crash
Comment écrirais-tu le parse ?

<details> <summary>🕵️ Clique ici pour voir la solution</summary>

Extrait de code

open logs/server.log | lines | parse "[{type}] {date} : {msg}"
Tu vois ? On met les crochets et les deux-points dans le texte du pattern pour que Nushell sache qu'il doit les ignorer et juste capturer ce qu'il y a entre.
