{
  description = "Multi-language development environment (Python, Rust, Julia, Elixir)";

  inputs = {
    # Pin to nixpkgs/nixos-unstable for latest packages and tools
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # 🛠️ NEW: Input for the community Rust package set
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }: # 🛠️ NEW: rust-overlay must be listed here
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgs = forAllSystems (system:
        let
          # 🛠️ Define the overlays list, including the rust-overlay
          overlays = [ (import rust-overlay) ];
        in
        import nixpkgs {
          inherit system overlays; # 🛠️ Apply the overlays here
          config.allowUnfree = true;
        }
      );

    in
    {
      devShells = forAllSystems (system:
        let
          # Define a local pkgs reference for convenience within this shell block
          localPkgs = pkgs.${system};
        in
        {
          default = localPkgs.mkShell {
            # Since the overlay is applied, rust-bin is now correctly accessible!
            buildInputs = with localPkgs; [
              # Languages
              python3
              julia_111 # Using the specific version
              rust-bin.stable.latest.default # 🛠️ This is now correct!
              elixir

              # Databases and Data Tools
              postgresql_16
              sqlite

              # General Utilities
              git
              starship
              neovim
              ripgrep
              fzf
              tree
            ];

            shellHook = ''
              echo "════════════════════════════════════════════════════════════════"
              echo "  [Flake] Loaded Multi-Language Shell."
              echo "  Python: $(python --version)"
              echo "  Rust:   $(rustc --version | head -n 1)"
              echo "════════════════════════════════════════════════════════════════"
            '';
          };
        }
      );
      defaultDevShell = self.devShells.${builtins.currentSystem}.default;
    };
}
