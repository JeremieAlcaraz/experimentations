{
  description = "Nushell Lab - Environment Pro";

  inputs = {
    # On utilise la branche unstable pour avoir les derniers outils
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Utilitaire pour gérer Mac (M1/M2) et Linux facilement
    flake-utils.url = "github:numtide/flake-utils";
    
    # Le Fameux Flake de Claude Code (Input natif !)
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, flake-utils, claude-code }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # On récupère le paquet Claude Code spécifiquement pour ton architecture
        claudePkg = claude-code.packages.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          # Liste propre des paquets
          packages = with pkgs; [
            nushell
            carapace
            starship
            bat
            ripgrep
            neovim
            nodejs
            claudePkg # <--- Intégration native, zéro bidouille
          ];

          # Le Hook de configuration (Nettoyé)
          shellHook = ''
            # 1. SETUP CHEMINS (Absolus pour la sécurité)
            ROOT_DIR=$(pwd)
            CACHE_DIR="$ROOT_DIR/.nu_cache"
            mkdir -p "$CACHE_DIR"

            # 2. CONFIGS GÉNÉRÉES
            # Starship
            echo '
            [character]
            success_symbol = "[🦀 FLAKE ➜](bold green)"
            error_symbol = "[💀 FLAKE ➜](bold red)"
            [directory]
            truncation_length = 3
            style = "bold yellow"
            [nodejs]
            symbol = "⬢ "
            ' > "$CACHE_DIR/starship.toml"
            export STARSHIP_CONFIG="$CACHE_DIR/starship.toml"
            export BAT_THEME="Dracula"

            # Neovim
            echo '
              set clipboard+=unnamedplus
              set number
              set termguicolors
            ' > "$CACHE_DIR/init.vim"

            # Nushell Scripts
            starship init nu > "$CACHE_DIR/starship.nu"
            carapace _carapace nushell > "$CACHE_DIR/carapace.nu"
            echo '$env.PROMPT_INDICATOR = {|| "" }' > "$CACHE_DIR/env.nu"

            # Config Principale
            echo "
              source '$CACHE_DIR/starship.nu'
              source '$CACHE_DIR/carapace.nu'
              alias cat = bat --style=plain
              alias vim = nvim -u '$CACHE_DIR/init.vim'
              
              \$env.config.show_banner = false
              print '✅ Environnement Flake Chargé !'
            " > "$CACHE_DIR/config.nu"

            echo "------------------------------------------------"
            echo "❄️  Nix Flake Shell - Mode Activation"
            echo "------------------------------------------------"

            # 3. LANCEMENT
            # On lance Nu directement
            exec nu --env-config "$CACHE_DIR/env.nu" --config "$CACHE_DIR/config.nu"
          '';
        };
      }
    );
}
