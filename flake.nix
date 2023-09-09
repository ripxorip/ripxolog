{
  description = "Ripxolog Pomodore with project time reporting";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    { self
    , nixpkgs
    , nix-formatter-pack
    , flake-utils
    , rust-overlay
    }:

    flake-utils.lib.eachDefaultSystem (system:

    let

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      alcli_toolchain = pkgs.rust-bin.fromRustupToolchainFile ./alcli/toolchain.toml;

      python_pkgs = ps: with ps; [
        (
          buildPythonPackage rec {
            pname = "pyulog";
            version = "1.0.1";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-kdQ+BwMaGBx6PSVjDjzc6irZT5mtRFlq9Pu99JH/FtY=";
            };
            doCheck = false;
            propagatedBuildInputs = [
              # Specify dependencies
              pkgs.python39Packages.numpy
            ];
          }
        )
        numpy
        pyqt5
        pyqtgraph
        scipy
        pyside2
        requests
        pymavlink
        pyserial
      ];

      cargoToml = builtins.fromTOML (builtins.readFile ./rust_log_downloader/Cargo.toml);
      matrix-sh = pkgs.callPackage ./pkgs/matrix.sh { };
      mavsdk = pkgs.callPackage ./pkgs/mavsdk { };
    in
    {
      formatter = pkgs.nixpkgs-fmt;

      packages = rec {
        default = matrix-sh;
      };

      # Devshell for building/debugging the alcli rust app
      devShells.alcli = pkgs.mkShell {
        packages = [
          alcli_toolchain
          matrix-sh
        ];
      };

      # Devshell for building the mavsdk C++ apps
      devShells.default = pkgs.mkShell {
        packages = [
            mavsdk
            pkgs.cmake
            pkgs.gcc
        ];
      };

    });
}
