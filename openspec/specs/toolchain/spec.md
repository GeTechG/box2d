# toolchain Specification

## Purpose
Say which compiler types the library and give every checkout that compiler, symbol navigation and structural search with one command.

## Requirements

### Requirement: The compiler is pinned in the repository
`tools/haxe-build.pin` SHALL hold one line, `<build key, 40 hex> <sha256 of the archive, 64 hex>`, naming the file `haxe-linux64-<key>.tar.gz` of the `builds` release of `GeTechG/haxe`. The library SHALL be built and typed only with that compiler (`.haxe/haxe`, `HAXE_STD_PATH=.haxe/std`); changing the compiler is a change of that file alone.

#### Scenario: Compiler bump
- **WHEN** the pin file is changed to another key and checksum and `tools/setup.sh` is run
- **THEN** `.haxe` points at the install of the new key and the install of the old key is left in place

### Requirement: One command sets up a checkout
`tools/setup.sh` SHALL download the pinned build, verify its checksum, install it in a per-key directory of the user's cache shared by all checkouts, and point the gitignored `.haxe` symlink at it. It SHALL refuse an archive whose checksum differs from the pin and SHALL NOT download again when the key is already installed.

#### Scenario: Fresh worktree
- **WHEN** `tools/setup.sh` is run in a new worktree
- **THEN** `.haxe/haxe --version` reports the pinned build

#### Scenario: Checksum mismatch
- **WHEN** the downloaded archive does not match the checksum in the pin file
- **THEN** the command fails, names both checksums, and installs nothing

### Requirement: Serena navigates the sources with the pinned compiler
The setup command SHALL build `vshaxe/haxe-language-server` from source at a fixed commit into a per-commit directory of the user's cache, and write the gitignored `.serena/project.local.yml` so that Serena starts that server with `.haxe` first on its `PATH`. It SHALL create a minimal `.serena/project.yml` when none exists, and SHALL NOT overwrite a `project.local.yml` it did not generate. Serena SHALL be registered in `.mcp.json` and `.codex/config.toml`.

#### Scenario: Someone's own overrides
- **WHEN** `.serena/project.local.yml` exists with settings and without the generator's mark
- **THEN** the command fails and leaves the file as it is

### Requirement: The display config types every module
The generated `.serena/lsp.hxml` SHALL hold only the class path, flags and module names (no `--macro`) and SHALL name every module under `box2D/`. `.haxe/haxe .serena/lsp.hxml --no-output` SHALL exit 0; the setup command fails when it does not.

#### Scenario: New source file
- **WHEN** a module is added and the setup command is run again
- **THEN** the display config names the new module

### Requirement: Structural search works on the Haxe sources
The setup command SHALL install `ast-grep` at a fixed version and build the Haxe grammar `GeTechG/tree-sitter-haxe` at a fixed commit, each into a per-pin directory of the user's cache shared by all checkouts, and link them as `.ast-grep/ast-grep` and `.ast-grep/haxe.so` in the gitignored `.ast-grep/` directory. `sgconfig.yml` at the repository root SHALL register that library as the custom language `haxe` for the extension `hx`.

#### Scenario: Fresh worktree
- **WHEN** `tools/setup.sh` is run in a new worktree
- **THEN** `.ast-grep/ast-grep run -p 'new $T($$$A)' -l haxe box2D` lists the matching `new` expressions
