# File: shell.nix - Simplified Multi-Language Development Shell

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Define the core language toolchains and general utilities
  buildInputs = with pkgs; [
    # Languages
    python3           # Python (latest stable version)
    julia_19          # Julia (Specific stable version)
    rust-bin.stable.latest.default # Rust (latest stable toolchain)
    elixir            # Elixir runtime

    # Databases and Data Tools
    postgresql_16     # PostgreSQL client and libraries (version 16)
    sqlite            # SQLite client

    # Marimo (Assuming marimo is used via Python, we ensure python environment is ready)
    # The marimo package itself is typically installed via pip/uv within the shell

    # General Utilities
    git
    starship
    neovim
    ripgrep
    fzf
    tree
  ];

  # Define specific environment variables or functions
  shellHook = ''
    echo "════════════════════════════════════════════════════════════════"
    echo "  Loaded Simplified Multi-Language Shell (Nix + direnv)"
    echo "  Python: $(python --version)"
    echo "  Rust:   $(rustc --version | head -n 1)"
    echo "════════════════════════════════════════════════════════════════"
  '';
}
