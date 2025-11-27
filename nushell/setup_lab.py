import os
import json
import csv

# 1. Création du dossier principal
base_dir = "nu_lab"
if not os.path.exists(base_dir):
    os.makedirs(base_dir)
    os.makedirs(os.path.join(base_dir, "logs"))

# 2. Fichier JSON (Données structurées)
users_data = [
    {"id": 1, "user": "neo", "level": "admin", "login_count": 42, "active": True},
    {"id": 2, "user": "trinity", "level": "admin", "login_count": 38, "active": True},
    {"id": 3, "user": "morpheus", "level": "moderator", "login_count": 15, "active": False},
    {"id": 4, "user": "cypher", "level": "user", "login_count": 2, "active": True},
    {"id": 5, "user": "tank", "level": "operator", "login_count": 10, "active": True}
]
with open(os.path.join(base_dir, "users.json"), "w") as f:
    json.dump(users_data, f, indent=2)

# 3. Fichier CSV (Données tabulaires type Excel)
csv_data = [
    ["item", "category", "price", "stock"],
    ["laptop_pro", "electronics", 1200, 5],
    ["mouse_wireless", "electronics", 25, 50],
    ["coffee_mug", "kitchen", 10, 100],
    ["monitor_4k", "electronics", 400, 0],
    ["desk_lamp", "home", 45, 12]
]
with open(os.path.join(base_dir, "inventory.csv"), "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerows(csv_data)

# 4. Fichier LOG (Texte brut à parser - Le "Boss final")
log_content = """2023-10-01 10:00:01 | INFO | User neo logged in
2023-10-01 10:05:23 | WARN | High memory usage detected
2023-10-01 10:10:00 | ERROR | Connection failed for user cypher
2023-10-01 10:15:45 | INFO | User trinity uploaded file data.json
2023-10-01 10:20:00 | ERROR | Database timeout
"""
with open(os.path.join(base_dir, "logs", "server.log"), "w") as f:
    f.write(log_content)

# 5. Fichier TOML (Configuration)
toml_content = """
[server]
host = "localhost"
port = 8080

[database]
enabled = true
pool_size = 10
"""
with open(os.path.join(base_dir, "config.toml"), "w") as f:
    f.write(toml_content)

print(f"✅ Dossier '{base_dir}' créé avec succès ! Tu peux commencer.")
