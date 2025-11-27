# Architecture du Repository d'Expérimentations

## Vue d'ensemble

Ce repository `experimentations` contient plusieurs projets indépendants, chacun dans son propre dossier. Chaque projet utilise **Nix Flakes** avec une configuration DX (Developer Experience) commune centralisée dans `base-dx.nix`.

## Structure du Repository

```
experimentations/
├── base-dx.nix          # Configuration DX commune (à NE PAS modifier légèrement)
├── nushell/             # Projet d'expérimentation Nushell
│   ├── flake.nix
│   └── ...
├── broot/               # Projet d'expérimentation Broot
│   ├── flake.nix
│   └── ...
└── [nouveau-projet]/    # Futurs projets suivent le même pattern
    ├── flake.nix
    └── ...
```

## Le Fichier `base-dx.nix`

### Principe

`base-dx.nix` est une fonction Nix qui:
1. Accepte `pkgs` (les packages Nixpkgs) et `extraPackages` (packages spécifiques au projet)
2. Retourne un objet avec:
   - `packages`: liste des outils à installer
   - `shellHook`: script d'initialisation de l'environnement

### Packages Communs

Tous les projets héritent automatiquement de:
- **nushell** (shell moderne)
- **carapace** (complétion shell)
- **starship** (prompt customisé)
- **bat** (cat avec coloration syntaxique)
- **ripgrep** (recherche rapide)
- **neovim** (éditeur)
- **nodejs** (runtime JS)
- **git** (VCS)

### Configuration Automatique

Le `shellHook` configure automatiquement:
- Cache local dans `.nu_cache/` (gitignore recommandé)
- Starship avec prompt personnalisé (🚀 DX ➜)
- Bat avec thème Dracula
- Neovim avec config minimale
- Alias pratiques (`cat` → `bat`, `vim` → `nvim`)

## Pattern pour Nouveau Projet

### 1. Créer le Dossier

```bash
mkdir experimentations/mon-nouveau-projet
cd experimentations/mon-nouveau-projet
```

### 2. Créer le `flake.nix`

Utiliser ce template (exemple avec Claude Code):

```nix
{
  description = "Expérimentation Mon Nouveau Projet";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Ajouter ici les dépendances spécifiques (optionnel)
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, flake-utils, claude-code }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Extraire les packages des inputs si nécessaire
        claudePkg = claude-code.packages.${system}.default;

        # Importer base-dx.nix avec packages supplémentaires
        baseDx = import ../base-dx.nix {
          inherit pkgs;
          extraPackages = [
            claudePkg
            # Ajouter d'autres packages spécifiques ici
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = baseDx.packages;
          shellHook = ''
            ${baseDx.shellHook}

            # Ajouter ici des configurations supplémentaires spécifiques au projet

            exec nu --env-config "$NU_ENV_FILE" --config "$NU_CONFIG_FILE"
          '';
        };
      }
    );
}
```

### 3. Activer l'Environnement

```bash
nix develop
# ou avec direnv
echo "use flake" > .envrc
direnv allow
```

## Cas d'Usage

### Projet Sans Dépendances Externes

Si le projet n'a besoin que des outils de base:

```nix
baseDx = import ../base-dx.nix {
  inherit pkgs;
  extraPackages = [];
};
```

### Projet avec Packages NPM Globaux

```nix
let
  nodeEnv = pkgs.buildEnv {
    name = "node-env";
    paths = [ pkgs.nodejs ];
  };
in
baseDx = import ../base-dx.nix {
  inherit pkgs;
  extraPackages = [ nodeEnv pkgs.yarn ];
};
```

### Projet avec Outils Rust

```nix
baseDx = import ../base-dx.nix {
  inherit pkgs;
  extraPackages = with pkgs; [
    rustc
    cargo
    rust-analyzer
  ];
};
```

## Bonnes Pratiques

### À Faire ✅

- **Toujours** utiliser `../base-dx.nix` depuis les projets fils
- Ajouter `.nu_cache/` et `.direnv/` au `.gitignore`
- Documenter les `extraPackages` spécifiques dans le README du projet
- Tester `nix flake check` avant de commit

### À Éviter ❌

- **Ne pas** dupliquer la configuration de base dans chaque projet
- **Ne pas** modifier `base-dx.nix` pour des besoins spécifiques à un projet
- **Ne pas** hardcoder des chemins absolus dans les flakes

## Dépannage

### Le cache `.nu_cache` cause des problèmes

```bash
rm -rf .nu_cache
nix develop
```

### Les packages ne se mettent pas à jour

```bash
nix flake update
nix develop --refresh
```

### Conflit entre packages

Vérifier l'ordre dans `extraPackages` - le dernier package l'emporte en cas de collision de binaires.

## Philosophie

Cette architecture suit le principe **DRY (Don't Repeat Yourself)**:
- Configuration commune = `base-dx.nix`
- Configuration spécifique = `extraPackages` dans chaque `flake.nix`
- Isolation totale entre projets grâce aux Nix Flakes

Chaque projet reste **autonome** (peut être déplacé/forké) tout en bénéficiant de la **cohérence** de l'environnement de base.
