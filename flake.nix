{
  description = "todo";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = {
    self,
    nixpkgs,
    crane,
    flake-utils,
    rust-overlay,
    advisory-db,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      nightlyRust = pkgs.rust-bin.nightly.latest.default;

      inherit (pkgs) lib;
      craneLib = crane.lib.${system};
      toolchain = with pkgs; [
        nightlyRust
        #cargo
        #rustc
        #rustfmt
        clippy
        rust-analyzer
        cargo-nextest
        cargo-limit
        cargo-audit
        cargo-limit
        cargo-watch
        nixpkgs-fmt
        bats
        (treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
      ];

      src = craneLib.cleanCargoSource ./.;

      # Common derivation arguments used for all builds
      commonArgs = {
        inherit src;
        cargoVendorDir = null;
      };

      # Build *just* the cargo dependencies, so we can reuse
      # all of that work (e.g. via cachix) when running in CI
      cargoArtifacts = craneLib.buildDepsOnly (commonArgs
        // {
          # Additional arguments specific to this derivation can be added here.
          # Be warned that using `//` will not do a deep copy of nested
          # structures
          pname = "collections";
        });

      # Run clippy (and deny all warnings) on the crate source,
      # resuing the dependency artifacts (e.g. from build scripts or
      # proc-macros) from above.
      #
      # Note that this is done as a separate derivation so it
      # does not impact building just the crate by itself.
      myCrateClippy = craneLib.cargoClippy (commonArgs
        // {
          # Again we apply some extra arguments only to this derivation
          # and not every where else. In this case we add some clippy flags
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        });

      # Build the actual crate itself, reusing the dependency
      # artifacts from above.
      myCrate = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
        });

      # Also run the crate tests under cargo-tarpaulin so that we can keep
      # track of code coverage
      myCrateCoverage = craneLib.cargoTarpaulin (commonArgs
        // {
          inherit cargoArtifacts;
        });

      myCrateDoc = craneLib.cargoDoc (commonArgs
        // {
          inherit cargoArtifacts;
        });

      myCrateFormat = craneLib.cargoFmt (commonArgs
        // {
          inherit cargoArtifacts;
        });

      myCrateAudit = craneLib.cargoAudit (commonArgs
        // {
          inherit cargoArtifacts advisory-db;
        });

      # Run tests with cargo-nextest
      myCrateNextest = craneLib.cargoNextest (commonArgs
        // {
          inherit cargoArtifacts;
          partitions = 1;
          partitionType = "count";
        });
    in {
      packages = {
        crate = myCrate;
        fmt = myCrateFormat;
        clippy = myCrateClippy;
        audit = myCrateAudit;
        doc = myCrateDoc;
      };

      packages.default = myCrate;

      devShell = pkgs.mkShell {
        buildInputs = toolchain;
      };
    });
}
