{
  description = "Fortune cookie backend";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "fortune-cookie-${version}";
          version = "0.1.0";
          src = pkgs.fetchFromGitHub {
            owner = "quantinium3";
            repo = "fortune-cookie";
            rev = "main";
            sha256 = "sha256-uhMwLCa/OVoMNI26of29BVaRcEUSlVerg1nLQuvSrjE=";
          };
          cargoLock = {
            lockFile = "${src}/Cargo.lock";
          };
          buildInputs = with pkgs; [ openssl ];

          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        };
      });
}
