{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    nushell
    carapace
    starship
    bat
    ripgrep
  ];

  shellHook = ''
    # --- 1. SETUP DES CHEMINS ABSOLUS ---
    # On capture le chemin actuel pour ne laisser aucune chance à l'erreur
    ROOT_DIR=$(pwd)
    CACHE_DIR="$ROOT_DIR/.nu_cache"
    
    mkdir -p "$CACHE_DIR"

    # --- 2. CONFIG STARSHIP ---
    # On crée le fichier de config Starship
    echo '
    [character]
    success_symbol = "[🦀 NU_LAB ➜](bold green)"
    error_symbol = "[💀 NU_LAB ➜](bold red)"
    
    [directory]
    truncation_length = 3
    style = "bold yellow"
    ' > "$CACHE_DIR/starship.toml"

    # On force la variable d environnement pour que Starship le voie
    export STARSHIP_CONFIG="$CACHE_DIR/starship.toml"

    # --- 3. GÉNÉRATION DES SCRIPTS NU ---
    # On génère les init dans le dossier cache
    starship init nu > "$CACHE_DIR/starship.nu"
    carapace _carapace nushell > "$CACHE_DIR/carapace.nu"
    
    # Création d un env.nu minimal
    echo '$env.PROMPT_INDICATOR = {|| "" }' > "$CACHE_DIR/env.nu"

    # --- 4. CRÉATION DE LA CONFIG PRINCIPALE ---
    # C est ici que la magie opère : on injecte le chemin ABSOLU ($CACHE_DIR)
    # directement dans le code source de Nushell.
    echo "
      source '$CACHE_DIR/starship.nu'
      source '$CACHE_DIR/carapace.nu'
      
      alias cat = bat --style=plain
      \$env.config.show_banner = false
      
      print '✅ Config chargée depuis : $CACHE_DIR'
    " > "$CACHE_DIR/config.nu"

    echo "------------------------------------------------"
    echo "🧪 Chargement du Lab (Tentative avec chemins absolus)"
    echo "------------------------------------------------"

    # --- 5. LANCEMENT ---
    nu --env-config "$CACHE_DIR/env.nu" --config "$CACHE_DIR/config.nu"
  '';
}
