{
  description = "Helium browser (solvedggorg/helium)";

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
    in
    {
      packages = forAllSystems (
        system:
        let
          helium = nixpkgs.legacyPackages.${system}.callPackage ./nix/default.nix { };
        in
        {
          inherit helium;
          helium-browser = helium;
          default = helium;
        }
      );

      overlays.default = final: _prev: {
        helium = final.callPackage "${self}/nix/default.nix" { };
        helium-browser = final.helium;
      };

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
