{
  description = "Fortune cookie backend";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
          src = pkgs.lib.sourceByRegex ./. [
            "Cargo\.lock"
            "Cargo\.toml"
            "src"
            "src/bin"
            ".*\.rs$"
          ];
          cargoLock = { lockFile = ./Cargo.lock; };
          buildInputs = with pkgs; [ openssl ];

          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        };
      });
}
