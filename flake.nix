{
  description = "ttbregman shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
    python = pkgs.python3;

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
    };
  in {
    packages.x86_64-linux = {
      quimb = quimb;
      autoray = autoray;
      cotengra = cotengra;
      default = quimb;
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        (python.withPackages (p:
          with p; [
            jedi-language-server
            black
            quimb
          ]))
      ];
    };
  };
}
