{
  description = "Zig bindings for TIGR";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        linuxDeps = with pkgs; [
          xorg.libX11
          libGL
          libGLU
        ];

        darwinDeps = with pkgs; [
          apple-sdk_15
          libiconv
        ];
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; } {
          packages =
            [
              pkgs.zig
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux ([ pkgs.pkg-config ] ++ linuxDeps)
            ++ pkgs.lib.optionals pkgs.stdenv.isDarwin darwinDeps;

          env = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
            SDKROOT = "${pkgs.apple-sdk_15.sdkroot}";
          };

          shellHook = ''
            echo "ZIGR development shell"
            echo "Zig version: $(zig version)"
          '';
        };
      }
    );
}
