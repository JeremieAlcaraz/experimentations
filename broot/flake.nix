{
  description = "Training Camp Broot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Pas besoin de Claude ici, juste la base
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # On importe la base en ajoutant Broot
        baseDx = import ../base-dx.nix { 
          inherit pkgs;
          extraPackages = [ pkgs.broot ]; 
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = baseDx.packages;
          
          shellHook = ''
            # 1. On charge le hook de la base (création des configs Nu, etc.)
            ${baseDx.shellHook}
            
            # 2. CONFIG SPÉCIFIQUE BROOT
            # On demande à broot de générer la fonction 'br' pour Nushell
            # et on l'ajoute à la fin du fichier config.nu généré par la base.
            echo "\n# Configuration automatique de br" >> "$NU_CONFIG_FILE"
            broot --print-shell-function nushell >> "$NU_CONFIG_FILE"

            print "🌳 Broot Lab prêt. Tape 'br' pour commencer."

            # 3. Lancement
            exec nu --env-config "$NU_ENV_FILE" --config "$NU_CONFIG_FILE"
          '';
        };
      }
    );
}
