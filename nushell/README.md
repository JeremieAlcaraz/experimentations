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
