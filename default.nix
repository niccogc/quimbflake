{pkgs ? import <nixpkgs> {system = "x86_64-linux";}}:
let

  # Function to build packages for a specific Python version
  buildQuimbPackages = python: let
    # Package autoray (no dependencies)
    autoray = python.pkgs.buildPythonPackage rec {
      pname = "autoray";
      version = "0.8.0";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jcmgray";
        repo = "autoray";
        rev = "v${version}";
        sha256 = "sha256-OACzYlSg0U6Omd9A2CiAySW3nZKug6hKljWIBUJlFkE=";
      };

      build-system = with python.pkgs; [
        hatchling
        hatch-vcs
      ];
    };

    # Package cotengra (requires autoray)
    cotengra = python.pkgs.buildPythonPackage rec {
      pname = "cotengra";
      version = "0.7.5";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jcmgray";
        repo = "cotengra";
        rev = "v${version}";
        sha256 = "sha256-lGzdpCcrgl8OArFbd6nM9GRvTkoA4Vj5LtWPgFDa8k8=";
      };

      build-system = with python.pkgs; [
        hatchling
        hatch-vcs
      ];

      dependencies = [
        autoray
      ];
      
      propagatedBuildInputs = [
        autoray
      ];
    };

    # Package quimb
    quimb = python.pkgs.buildPythonPackage rec {
      pname = "quimb";
      version = "1.11.2";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jcmgray";
        repo = "quimb";
        rev = "v${version}";
        sha256 = "sha256-+yJHzv8J+DWmpFy+Is6lofxii/ZLlUG8pYsqwBQ5rro=";
      };

      build-system = with python.pkgs; [
        hatchling
        hatch-vcs
      ];

      dependencies = with python.pkgs; [
        numpy
        scipy
        numba
        cytoolz
        tqdm
        psutil
        autoray
        cotengra
      ];
      
      propagatedBuildInputs = with python.pkgs; [
        numpy
        scipy
        numba
        cytoolz
        tqdm
        psutil
        autoray
        cotengra
      ];
    };
  in {
    inherit autoray cotengra quimb;
  };

  # Build for Python 3.12
  py312Packages = buildQuimbPackages pkgs.python312;

  # Build for Python 3.13
  py313Packages = buildQuimbPackages pkgs.python313;
in
  {
    # Python 3.12 packages
    quimb-py312 = py312Packages.quimb;
    autoray-py312 = py312Packages.autoray;
    cotengra-py312 = py312Packages.cotengra;

    # Python 3.13 packages
    quimb-py313 = py313Packages.quimb;
    autoray-py313 = py313Packages.autoray;
    cotengra-py313 = py313Packages.cotengra;

    # Default to Python 3.13
    quimb = py313Packages.quimb;
    autoray = py313Packages.autoray;
    cotengra = py313Packages.cotengra;
  }
