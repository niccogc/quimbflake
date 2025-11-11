# Example flake showing how to use quimb with the overlay
{
  description = "Example project using quimb with overlay";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quimb-flake.url = "path:./.";  # Points to this directory
  };
  
  outputs = { self, nixpkgs, quimb-flake }:
    let
      system = "x86_64-linux";
      
      # Import nixpkgs with quimb overlay
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ quimb-flake.overlays.default ];
      };
      
      # Common Python packages for quimb
      pythonPackages = ps: with ps; [
        # Quimb and its custom dependencies
        quimb
        autoray
        cotengra
        # Standard dependencies
        numpy
        scipy
        numba
        cytoolz
        tqdm
        psutil
        # Optional: add your own packages
        # matplotlib
        # jupyter
      ];
    in {
      # Development shells with quimb available as ps.quimb
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [ (pkgs.python313.withPackages pythonPackages) ];
        };
        
        py312 = pkgs.mkShell {
          packages = [ (pkgs.python312.withPackages pythonPackages) ];
        };
        
        py313 = pkgs.mkShell {
          packages = [ (pkgs.python313.withPackages pythonPackages) ];
        };
      };
    };
}
