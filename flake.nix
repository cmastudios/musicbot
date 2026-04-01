{
  description = "Nix flake for rubychan Discord music bot";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python313;
        pythonPkgs = pkgs.python313Packages;

        rubychanDeps = with pythonPkgs; [ discordpy yt-dlp ];

        rubychan = pythonPkgs.buildPythonApplication {
          pname = "rubychan";
          version = "0.1.0";
          src = ./.;
          pyproject = true;
          propagatedBuildInputs = rubychanDeps ++ [ pkgs.ffmpeg pkgs.deno ];
          buildInputs = [ pkgs.ffmpeg pkgs.deno ];
          nativeBuildInputs = with pythonPkgs; [ setuptools wheel ];
          doCheck = false;
          meta = with pkgs.lib; {
            description = "Discord music bot";
            license = licenses.mit;
            maintainers = [];
          };
        };
      in {
        packages.rubychan = rubychan;

        devShells.default = pkgs.mkShell {
          buildInputs = [ python pkgs.ffmpeg pkgs.deno ] ++ rubychanDeps;
          shellHook = ''
            echo "rubychan dev shell ready (python ${python.version})"
          '';
        };
      }
    );
}
