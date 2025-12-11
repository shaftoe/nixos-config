{
  description = "NixOS configuration for eq";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.eq = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./eq.nix
      ];
    };
  };
}