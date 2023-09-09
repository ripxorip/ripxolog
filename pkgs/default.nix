{ pkgs ? import <nixpkgs> { } }: rec {

  matrix-sh = pkgs.callPackage ./matrix.sh { };
  mavsdk = pkgs.callPackage ./mavsdk { };
}
