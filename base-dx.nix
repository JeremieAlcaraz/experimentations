# base-dx.nix
{ pkgs, extraPackages ? [] }:

let
  commonPackages = with pkgs; [
    nushell
    carapace
    starship
    bat
    ripgrep
    neovim
    nodejs
    git
    # On a retiré Claude d'ici, il sera injecté via extraPackages !
  ] ++ extraPackages;

in
{
  packages = commonPackages;

  shellHook = ''
    # --- SETUP CHEMINS ---
    PROJECT_DIR=$(pwd)
    CACHE_DIR="$PROJECT_DIR/.nu_cache"
    mkdir -p "$CACHE_DIR"

    # --- CONFIG STARSHIP ---
    echo '
    [character]
    success_symbol = "[🚀 DX ➜](bold green)"
    error_symbol = "[💀 DX ➜](bold red)"
    [directory]
    truncation_length = 3
    style = "bold yellow"
    [nodejs]
    symbol = "⬢ "
    ' > "$CACHE_DIR/starship.toml"
    export STARSHIP_CONFIG="$CACHE_DIR/starship.toml"
    export BAT_THEME="Dracula"

    # --- CONFIG NEOVIM ---
    echo '
      set clipboard+=unnamedplus
      set number
      set termguicolors
    ' > "$CACHE_DIR/init.vim"

    # --- INIT SCRIPTS ---
    starship init nu > "$CACHE_DIR/starship.nu"
    carapace _carapace nushell > "$CACHE_DIR/carapace.nu"
    echo '$env.PROMPT_INDICATOR = {|| "" }' > "$CACHE_DIR/env.nu"

    # --- CONFIG NU ---
    echo "
      source '$CACHE_DIR/starship.nu'
      source '$CACHE_DIR/carapace.nu'
      alias cat = bat --style=plain
      alias vim = nvim -u '$CACHE_DIR/init.vim'
      
      print '🔧 Base DX chargée !'
    " > "$CACHE_DIR/config.nu"

    export NU_ENV_FILE="$CACHE_DIR/env.nu"
    export NU_CONFIG_FILE="$CACHE_DIR/config.nu"
  '';
}
