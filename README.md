# Quimb Python Package - Nix Flake

This repository provides a Nix flake for the [quimb](https://github.com/jcmgray/quimb) Python package, built for both Python 3.12 and Python 3.13.

## Package Structure

The flake exposes packages in the standard nixpkgs format:

- `python312Packages.quimb` - Quimb for Python 3.12
- `python312Packages.autoray` - Autoray dependency for Python 3.12
- `python312Packages.cotengra` - Cotengra dependency for Python 3.12
- `python313Packages.quimb` - Quimb for Python 3.13
- `python313Packages.autoray` - Autoray dependency for Python 3.13
- `python313Packages.cotengra` - Cotengra dependency for Python 3.13

## Usage Examples

### 1. Direct Import (Recommended - Dependencies Auto-Propagate)

Add quimb package directly to your shell. Dependencies automatically propagate:

```nix
{
  description = "My project using quimb";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quimb-flake = {
      url = "github:user/quimb-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, quimb-flake }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.python313
          quimb-flake.packages.${system}.python313Packages.quimb
        ];
      };
    };
}
```

**Why this method?** Dependencies automatically propagate via `propagatedBuildInputs` - no need to list numpy, scipy, etc!

**Note:** Use `inputs.nixpkgs.follows = "nixpkgs"` to ensure quimb uses the same nixpkgs version as your project.

### 2. Using the Overlay (Requires Explicit Dependencies)

Use the overlay to integrate quimb into the Python package set:

```nix
{
  description = "My project using quimb";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quimb-flake = {
      url = "github:user/quimb-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, quimb-flake }:
    let
      system = "x86_64-linux";
      
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ quimb-flake.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          (pkgs.python313.withPackages (ps: with ps; [
            quimb autoray cotengra
            # Must explicitly list dependencies:
            numpy scipy numba cytoolz tqdm psutil
          ]))
        ];
      };
    };
}
```

**Note:** With overlays, you **must explicitly list all dependencies** as `toPythonModule` doesn't propagate them in `withPackages`.

### 3. Using with Python 3.12

The overlay supports both Python 3.12 and 3.13:

```nix
{
  description = "My project using quimb with Python 3.12";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quimb-flake = {
      url = "github:user/quimb-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, quimb-flake }:
    let
      system = "x86_64-linux";
      
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ quimb-flake.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          (pkgs.python312.withPackages (ps: with ps; [
            quimb autoray cotengra
            numpy scipy numba cytoolz tqdm psutil
            matplotlib
          ]))
        ];
      };
    };
}
```

### 4. Multiple Python Versions

The overlay automatically provides quimb for both Python 3.12 and 3.13:

```nix
{
  description = "Project with multiple Python versions";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quimb-flake = {
      url = "github:user/quimb-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, quimb-flake }:
    let
      system = "x86_64-linux";
      
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ quimb-flake.overlays.default ];
      };
      
      pythonPackages = ps: with ps; [
        quimb autoray cotengra
        numpy scipy numba cytoolz tqdm psutil
      ];
    in {
      devShells.${system} = {
        py312 = pkgs.mkShell {
          packages = [ (pkgs.python312.withPackages pythonPackages) ];
        };
        
        py313 = pkgs.mkShell {
          packages = [ (pkgs.python313.withPackages pythonPackages) ];
        };
      };
    };
}
```

Then use with:
```bash
nix develop .#py312  # For Python 3.12
nix develop .#py313  # For Python 3.13
```

### 5. Quick Test Environment

To quickly test quimb without creating a flake:

```bash
# Python 3.13
nix develop path:/path/to/this/flake#py313

# Python 3.12
nix develop path:/path/to/this/flake#py312
```

### 6. Adding to NixOS Configuration

You can use the overlay in your NixOS system configuration:

```nix
{ config, pkgs, ... }:
let
  quimb-flake = builtins.getFlake "github:user/quimb-flake";
in {
  nixpkgs.overlays = [ quimb-flake.overlays.default ];
  
  environment.systemPackages = [
    (pkgs.python313.withPackages (ps: with ps; [
      quimb autoray cotengra
      numpy scipy numba cytoolz tqdm psutil
      matplotlib
    ]))
  ];
}
```

## Building the Package

Build the package directly:

```bash
# Python 3.13 version
nix build .#python313Packages.quimb

# Python 3.12 version
nix build .#python312Packages.quimb
```

## Testing

Run the included test script:

```bash
# Test Python 3.13
nix develop .#py313 --command python test_quimb.py

# Test Python 3.12
nix develop .#py312 --command python test_quimb.py
```

## Dependencies

The following packages are built from source:
- `autoray` (v0.8.0)
- `cotengra` (v0.7.5)
- `quimb` (v1.11.2)

Standard dependencies are pulled from nixpkgs:
- numpy
- scipy
- numba
- cytoolz
- tqdm
- psutil

## Why Direct Import vs Overlay?

**Direct Import (Method 1) is recommended** because:
- ✓ **Dependencies auto-propagate**: No need to list numpy, scipy, etc.
- ✓ **Works naturally**: Nix's standard `propagatedBuildInputs` mechanism works
- ✓ **Simpler**: Just add the package to `packages`

**Overlay (Method 2)** provides:
- **Cleaner syntax**: Use `ps.quimb` instead of `quimb-flake.packages.${system}.python313Packages.quimb`
- **Consistency**: Looks like other nixpkgs Python packages
- **Trade-off**: Must manually list all dependencies in `withPackages`

**Why the difference?** `python.withPackages` is designed for packages from the same Python interpreter's package set. External packages (even with overlays) don't fully integrate with `withPackages` dependency propagation, so you must list dependencies explicitly.

## File Structure

- `default.nix` - Package definitions for both Python versions
- `flake.nix` - Flake that imports from default.nix and exposes packages
- `test_quimb.py` - Simple test script to verify functionality
- `example-usage-flake.nix` - Complete example showing overlay usage
