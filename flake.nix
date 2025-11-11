{
  description = "Quimb Python package with dependencies";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    # Import packages from default.nix
    defaultPackages = import ./default.nix {inherit pkgs;};
  in {
    # Expose packages in standard Python package structure
    packages.${system} = {
      python312Packages = {
        autoray = defaultPackages.autoray-py312;
        cotengra = defaultPackages.cotengra-py312;
        quimb = defaultPackages.quimb-py312;
      };
      
      python313Packages = {
        autoray = defaultPackages.autoray-py313;
        cotengra = defaultPackages.cotengra-py313;
        quimb = defaultPackages.quimb-py313;
      };
      
      # Default to Python 3.13
      default = defaultPackages.quimb-py313;
    };

    # Python overlays for easy integration
    overlays.default = final: prev: {
      python312 = prev.python312.override {
        packageOverrides = pyfinal: pyprev: {
          quimb = pyfinal.toPythonModule self.packages.${system}.python312Packages.quimb;
          autoray = pyfinal.toPythonModule self.packages.${system}.python312Packages.autoray;
          cotengra = pyfinal.toPythonModule self.packages.${system}.python312Packages.cotengra;
        };
      };
      
      python313 = prev.python313.override {
        packageOverrides = pyfinal: pyprev: {
          quimb = pyfinal.toPythonModule self.packages.${system}.python313Packages.quimb;
          autoray = pyfinal.toPythonModule self.packages.${system}.python313Packages.autoray;
          cotengra = pyfinal.toPythonModule self.packages.${system}.python313Packages.cotengra;
        };
      };
    };

    devShells.${system} = {
      default = let
        overlaidPkgs = import nixpkgs.outPath {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in overlaidPkgs.mkShell {
        packages = [
          (overlaidPkgs.python313.withPackages (p: [
            p.quimb
          ]))
        ];
      };

      py312 = let
        overlaidPkgs = import nixpkgs.outPath {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in overlaidPkgs.mkShell {
        packages = [
          (overlaidPkgs.python312.withPackages (p: [
            p.quimb
          ]))
        ];
      };

      py313 = let
        overlaidPkgs = import nixpkgs.outPath {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in overlaidPkgs.mkShell {
        packages = [
          (overlaidPkgs.python313.withPackages (p: [
            p.quimb
          ]))
        ];
      };
    };
  };
}
