{
  description = "Fortune cookie backend";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ];
        };
        buildInputs = with pkgs; [ openssl pkg-config ];
        nativeBuildInputs = with pkgs; [ rustToolchain ];
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "fortune-cookie";
          version = "0.1.0";
          src = ./.;
          cargoLock = { lockFile = ./Cargo.lock; };
          nativeBuildInputs = nativeBuildInputs;
          buildInputs = buildInputs;

          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
        };
      });
}
