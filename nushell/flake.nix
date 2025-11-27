{
  description = "Expérimentation Nushell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    # ON REMET CLAUDE ICI (C'est la bonne pratique Flake)
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, flake-utils, claude-code }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # On extrait le paquet Claude du Flake téléchargé
        claudePkg = claude-code.packages.${system}.default;
        
        # On appelle notre base en lui DONNANT Claude
        baseDx = import ../base-dx.nix { 
          inherit pkgs;
          extraPackages = [ claudePkg ]; 
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = baseDx.packages;
          shellHook = ''
            ${baseDx.shellHook}
            exec nu --env-config "$NU_ENV_FILE" --config "$NU_CONFIG_FILE"
          '';
        };
      }
    );
}
