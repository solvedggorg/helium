{
  description = "Helium browser package for NixOS (solvedggorg/helium)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (
        system:
        let
          helium = (pkgsFor system).callPackage ./default.nix { };
        in
        {
          inherit helium;
          helium-browser = helium;
          default = helium;
        }
      );

      overlays.default = final: _prev: {
        helium = final.callPackage ./default.nix { };
        helium-browser = final.helium;
      };

      # Drop-in: inputs.helium.url = "github:solvedggorg/helium?dir=nix";
      # then: imports = [ inputs.helium.nixosModules.default ];
      nixosModules.default =
        { ... }:
        {
          nixpkgs.overlays = [ self.overlays.default ];
        };

      homeManagerModules.default =
        { ... }:
        {
          nixpkgs.overlays = [ self.overlays.default ];
        };
    };
}
