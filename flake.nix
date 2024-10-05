{
  description = "Game of life in various languages";

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
        in rec {
        raylib-source = pkgs.fetchFromGitHub{
          owner = "raysan5";               
          repo = "raylib";                
          rev = "ae50bfa2cc569c0f8d5bc4315d39db64005b1b08";                  
          sha256 = "sha256-gEstNs3huQ1uikVXOW4uoYnIDr5l8O9jgZRTX1mkRww="; 
        };

        raylib = pkgs.raylib.overrideAttrs (oldAttrs: {
          src = raylib-source;
        });
        
        pyraylib = pkgs.python3Packages.buildPythonPackage {
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

        rustraylib = pkgs.rustPlatform.buildRustPackage {
          pname = "rustraylib";
          version = "5.5.0";

          src = pkgs.fetchFromGitHub {
            owner = "raylib-rs";
            repo = "raylib-rs";
            rev = "edbfe848313d8d28250d12c2f5ec1ad5fbaa8adb";
            sha256 = "sha256-16TAKT8VOT+bmIUqsOtqBnsC4prOYCi7QB+1IfgVSuw=";
          };

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            clang
            cargo
            rustc  
          ];

          buildInputs = with pkgs; [
            mesa 
            glfw
            alsa-lib            
            wayland
            wayland-protocols
            libxkbcommon
            xorg.libX11
            xorg.libXrandr
            xorg.libXinerama
            xorg.libXcursor
            xorg.libXi
          ];

          cargoPatches = [
            ./rust/patches/cargo.lock.patch    #The library doesnt come with a cargo lock
            ./rust/patches/fix-examples.patch  #One specific example wouldnt build, removed it from the cargo.toml
          ];

          doCheck = false;
          cargoHash = "sha256-oTwrf7TpTtVadgk66tUDuiq08/vRhOD3G9NUSocpjfk="; 
          
          LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
          CMAKE_PREFIX_PATH= "${pkgs.glfw}/lib/cmake/glfw3:$CMAKE_PREFIX_PATH";
          OPENGL_INCLUDE_DIR="${pkgs.mesa.dev}/include";

          buildPhase = ''
            rm ./raylib-sys/raylib -r
            cp -r ${raylib-source} ./raylib-sys/raylib
            cargo build --release --features "wayland"
          '';    
          installPhase = ''
            mkdir -p $out/bin
            cp -r ./target/release/ $out/bin
          '';
        };

        javaraylib = pkgs.maven.buildMavenPackage {
          pname = "javaraylib";
          version = "0.0.3";
          src = pkgs.fetchFromGitHub {
            owner = "electronstudio";
            repo = "jaylib-ffm";
            rev = "c8218ae951fe5aa8cbd6b69ace2b7747b928648b";
            sha256 = "sha256-5UXpOJCdUAQl/ZesmlvIMeSb6tkgvU93dantfZA5s+M=";
          };
          mvnHash = "";
          pom = "${self.packages.${pkgs.system}.javaraylib.src}/pom.xml"; 

          nativeBuildInputs = with pkgs; [
            jdk22
          ];

          preBuild = ''
              export JAVA_HOME=${pkgs.jdk22}/lib/openjdk/
              java -version
          '';


        };
        }
      );

      devShells = forEachSupportedSystem (system: let
        pkgs = system.pkgs;
        raylib = self.packages.${pkgs.system}.raylib;
        pyraylib = self.packages.${pkgs.system}.pyraylib;
        rustraylib = self.packages.${pkgs.system}.rustraylib;
        # javaraylib = self.packages.${pkgs.system}.javaraylib;
      in {
        default = pkgs.mkShell {
          venvDir = "./.venv";

          shellHook = ''
            echo 'Python interpreter lives at ${pkgs.python3Packages.python}'
            echo 'JDK lives at ${pkgs.jdk22}'
            echo 'pyraylib lives at ${pyraylib}'
            echo 'rustraylib lives at ${rustraylib}'
          '';


          packages = with pkgs; [
            cargo
            rustc
            raylib
            jdk22
            rustraylib
            # javaraylib
          ] ++ (with pkgs.python3Packages; [
            python
            pyraylib
            cffi
          ]);
        };
      });
    };
}
