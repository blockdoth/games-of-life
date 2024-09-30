{
  description = "A nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

    in {
      packages = forEachSupportedSystem (system: let
        pkgs = system.pkgs;
      in {
        pyraylib = pkgs.python3Packages.buildPythonPackage rec {
          pname = "pyraylib";
          version = "1.0.2";

          src = pkgs.fetchFromGitHub {
            owner = "electronstudio";
            repo = "raylib-python-cffi";
            rev = "05955b5ef120b3b70bd5f4d3940203be31b7176b";
            sha256 = "sha256-Vb4yUcCSHYel0EX5p62mRkvSgK1KkLQkz4qhQWz5wPU="; 
          };

          nativeBuildInputs = with pkgs; [ 
            python3Packages.setuptools 
            pkg-config
          ];

          buildInputs = with pkgs; [ 
            python3Packages.cffi
            python3Packages.setuptools 
            raylib 
          ];
          
          preBuild = ''
            export PKG_CONFIG_PATH=${pkgs.raylib}/lib/pkgconfig
          '';
        };

      });

      # Adjust the devShells section to use the now-exposed patchedRaylib
      devShells = forEachSupportedSystem (system: let
        pkgs = system.pkgs;
        pyraylib = self.packages.${pkgs.system}.pyraylib;
      in {
        default = pkgs.mkShell {
          venvDir = "./.venv";

          shellHook = ''
            echo 'Entering a python shell template'
            echo 'Python interpreter lives at ${pkgs.python3Packages.python}'
            echo 'Pyraylib lives at ${pyraylib}'
          '';

          packages = with pkgs; [
            raylib
          ] ++ (with pkgs.python3Packages; [
            python
            pyraylib
            cffi
          ]);
        };
      });
    };
}
