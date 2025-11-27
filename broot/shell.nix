{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Les paquets nécessaires
  buildInputs = [
    pkgs.nushell
    pkgs.broot
  ];

  shellHook = ''
    # 1. Nettoyage préventif
    rm -f .repro_config.nu .repro_env.nu

    # 2. Génération de la fonction 'br' (le wrapper)
    # Note: On utilise 'nushell' explicitement comme argument
    broot --print-shell-function nushell > .br_wrapper.nu

    # 3. Création d'un fichier de config combiné pour ce test
    # On source le wrapper broot pour que la commande 'br' soit dispo
    echo "source .br_wrapper.nu" >> .repro_config.nu
    # On ajoute un petit prompt pour savoir qu'on est dans l'env de test
    echo '$env.PROMPT_COMMAND = {|| "🚀 (test) > " }' >> .repro_config.nu
    # On désactive le message de bienvenue pour la clarté
    echo '$env.config.show_banner = false' >> .repro_config.nu

    # 4. Création d'un env vide pour ignorer tes erreurs globales locales
    touch .repro_env.nu

    # 5. Création d'un alias raccourci pour lancer le test
    # On force nu à utiliser NOS fichiers et ignorer les tiens (~/.config/nushell/...)
    alias start-test='nu --config .repro_config.nu --env-config .repro_env.nu'

    echo "------------------------------------------------------------------"
    echo " 🛡️  Environnement Isolé Nushell + Broot"
    echo "------------------------------------------------------------------"
    echo " La configuration locale a été générée (et isole ton shell des bugs)."
    echo ""
    echo " 👉 Tape simplement : start-test"
    echo "------------------------------------------------------------------"
  '';
}
