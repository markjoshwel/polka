{
  description = "Polka: a personal Kakoune distribution with ppy colours and Python/Nix/TOML LSP";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      makePolka = pkgs:
        let
          config = pkgs.runCommand "polka-config" { } ''
            mkdir -p $out
            cp -R ${./config}/. $out/
            cp ${./README.md} $out/README.md
          '';
        in
        pkgs.writeShellApplication {
          name = "polka";
          runtimeInputs = with pkgs; [
            kakoune kakoune-lsp pyright nil taplo python3
            ripgrep git coreutils findutils gnused gnugrep
          ];
          text = ''
            export KAKOUNE_CONFIG_DIR=${config}
            export POLKA_USER_CONFIG="''${POLKA_USER_CONFIG:-''${XDG_CONFIG_HOME:-$HOME/.config}/polka/extra.kak}"
            mkdir -p "$(dirname "$POLKA_USER_CONFIG")"
            exec ${pkgs.kakoune}/bin/kak "$@"
          '';
          meta = {
            description = "Kakoune with ppy Dark, project navigation, and Python/Nix/TOML LSP";
            mainProgram = "polka";
            platforms = systems;
          };
        };
    in {
      packages = forAllSystems (system:
        let polka = makePolka nixpkgs.legacyPackages.${system};
        in { inherit polka; default = polka; });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.polka}/bin/polka";
          meta.description = "Launch Polka";
        };
        polka = self.apps.${system}.default;
      });

      overlays.default = final: prev: { polka = makePolka final; };
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      checks = forAllSystems (system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        package = self.packages.${system}.polka;
        smoke = pkgs.runCommand "polka-smoke-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          python3 ${./scripts/smoke-check.py} ${self.packages.${system}.polka}/bin/polka
          touch $out
        '';
      });
    };
}
