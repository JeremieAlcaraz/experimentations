
  source '/Users/jeremiealcaraz/src/tries/2025-11-27-experimentations/nushell/.nu_cache/starship.nu'
  source '/Users/jeremiealcaraz/src/tries/2025-11-27-experimentations/nushell/.nu_cache/carapace.nu'
  
  alias cat = bat --style=plain
  
  # L'astuce : quand tu tapes 'vim', ça lance 'neovim' avec notre config
  alias vim = nvim -u '/Users/jeremiealcaraz/src/tries/2025-11-27-experimentations/nushell/.nu_cache/init.vim'
  
  $env.config.show_banner = false
  print '✅ Config chargée : Neovim + Bat Dracula'

