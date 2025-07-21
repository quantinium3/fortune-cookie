{
  description = "Fortune cookie backend";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        fortune-cookie = pkgs.rustPlatform.buildRustPackage rec {
          pname = "fortune-cookie";
          version = "0.1.0";
          src = pkgs.fetchFromGitHub {
            owner = "quantinium3";
            repo = "fortune-cookie";
            rev = "f9fb77497c01cfff0a68146f4cf4884e8ddf9145";
            sha256 = "sha256-mKVzDicZVDb7n/zFQ7Fx1t2IUd+pW/pIz/r5UlWcfSQ=";
          };
          cargoHash = "sha256-ASRlHxodqd2/6ZNzADCftrkJS8v6bonlyLI/RtjxGn0=";
          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [ openssl ];
        };
      in
      {
        packages.default = fortune-cookie;
        packages.fortune-cookie = fortune-cookie;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ rustc cargo pkg-config openssl ];
        };
      }
    ) // {
      nixosModules.fortune-cookie = { config, pkgs, lib, ... }: {
        options.services.fortune-cookie = {
          enable = lib.mkEnableOption "Fortune Cookie Backend service";
        };
        config = lib.mkIf config.services.fortune-cookie.enable {
          systemd.services.fortune-cookie = {
            description = "Fortune Cookie Backend";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${self.packages.${pkgs.system}.fortune-cookie}/bin/fortune-cookie";
              Restart = "always";
              RestartSec = "10s";
              StandardOutput = "journal";
              StandardError = "journal";
              User = "fortune-cookie";
              Group = "fortune-cookie";
              DynamicUser = true;
              NoNewPrivileges = true;
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;
            };
          };
        };
      };
    };
}
