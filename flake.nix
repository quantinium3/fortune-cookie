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
            rev = "1518c312a13dc6593666b2d38c01f24e8719b2e6"; # replace with the rev we got earlier
            sha256 = "sha256-ehkM8XvKHysYVaH5xdleVsatCtSfUrWxOC/9ADakGbg="; # replace with the hash we got earlier
          };
          cargoLock = { lockFile = ./Cargo.lock; };
          buildInputs = with pkgs; [ openssl ];

          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        };
      });
}
