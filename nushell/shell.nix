{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    nushell
    carapace
    starship
    bat
    ripgrep
    neovim # <--- Le sauveur pour le presse-papier
  ];

  shellHook = ''
    # --- 1. SETUP DES CHEMINS ---
    ROOT_DIR=$(pwd)
    CACHE_DIR="$ROOT_DIR/.nu_cache"
    mkdir -p "$CACHE_DIR"

    # --- 2. CONFIG STARSHIP ---
    echo '
    [character]
    success_symbol = "[🦀 NU_LAB ➜](bold green)"
    error_symbol = "[💀 NU_LAB ➜](bold red)"
    [directory]
    truncation_length = 3
    style = "bold yellow"
    ' > "$CACHE_DIR/starship.toml"
    export STARSHIP_CONFIG="$CACHE_DIR/starship.toml"

    # --- 3. FIX BAT THEME ---
    # On force un thème intégré proche de TokyoNight pour éviter l'erreur
    export BAT_THEME="Dracula"

    # --- 4. CONFIG NEOVIM (Presse-papier) ---
    # Neovim sur Mac utilise automatiquement pbcopy/pbpaste
    # On ajoute juste quelques options de confort
    echo '
      set clipboard+=unnamedplus
      set number
      set termguicolors
    ' > "$CACHE_DIR/init.vim"

    # --- 5. GÉNÉRATION DES SCRIPTS NU ---
    starship init nu > "$CACHE_DIR/starship.nu"
    carapace _carapace nushell > "$CACHE_DIR/carapace.nu"
    echo '$env.PROMPT_INDICATOR = {|| "" }' > "$CACHE_DIR/env.nu"

    # --- 6. CONFIG NUSHELL PRINCIPALE ---
    echo "
      source '$CACHE_DIR/starship.nu'
      source '$CACHE_DIR/carapace.nu'
      
      alias cat = bat --style=plain
      
      # L'astuce : quand tu tapes 'vim', ça lance 'neovim' avec notre config
      alias vim = nvim -u '$CACHE_DIR/init.vim'
      
      \$env.config.show_banner = false
      print '✅ Config chargée : Neovim + Bat Dracula'
    " > "$CACHE_DIR/config.nu"

    echo "------------------------------------------------"
    echo "🧪 Chargement du Lab (Version Neovim)"
    echo "------------------------------------------------"

    # --- 7. LANCEMENT ---
    nu --env-config "$CACHE_DIR/env.nu" --config "$CACHE_DIR/config.nu"
  '';
}
