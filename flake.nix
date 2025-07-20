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
          cargoLock = { lockFile = ./Cargo.lock; };
          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [ openssl ];
        };
      in
      {
        packages.default = fortune-cookie;
        packages.fortune-cookie = fortune-cookie;
      }
    ) // {
      nixosModules.fortune-cookie = { config, pkgs, ... }: {
        options.services.fortune-cookie = {
          enable = pkgs.lib.mkEnableOption "Fortune Cookie Backend service";
        };

        config = pkgs.lib.mkIf config.services.fortune-cookie.enable {
          environment.systemPackages = [ self.packages.${pkgs.system}.fortune-cookie ];

          systemd.services.fortune-cookie = {
            description = "Fortune Cookie Backend";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              ExecStart = "${self.packages.${pkgs.system}.fortune-cookie}/bin/fortune-cookie";
              Restart = "always";
              StandardOutput = "journal";
              StandardError = "journal";
              User = "fortune";
              DynamicUser = true; 
            };
          };
        };
      };
    };
}
