# Polka

A personal, flake-based Kakoune distribution: ppy Dark colours, fuzzy project
navigation, and Python/Nix language intelligence. The editor and all tools come
from one locked Nixpkgs revision. Ordinary `kak` uses its own configuration.

## Run

```sh
nix run ~/Works/polka -- path/to/file.py
```

Run from your project directory for file navigation and project search.
To build and use a stable local command:

```sh
cd ~/Works/polka
nix build
ln -sfn "$PWD/result/bin/polka" ~/.local/bin/polka
```

After edits, run `nix build ~/Works/polka` to rebuild the installed command.
The result symlink keeps its Nix closure alive across garbage collection.
You can also install with `nix profile add ~/Works/polka` instead of the symlink;
reinstall that profile entry when changing local defaults.

## Controls

- **Ctrl-P** or **Space f**: fuzzy file picker; type a partial name, Tab, Enter.
- **Space b**: switch open buffers.
- **Space s**: project search; Enter on a result jumps to its location.
- **Space m**: searchable command menu.
- **g d / g r**: definition / references.
- **Space l**: language menu; **h** hover, **e** diagnostics, **R** rename,
  **s** symbols, **a** code actions, **f** formatting if the server supports it.
- **Space w**: save. **Space t**: toggle soft wrapping.
- **Space c**: edit personal overrides. **Space h**: this guide.

Python uses Pyright; Nix uses nil. Semantic completion and diagnostics are
enabled for those filetypes. Pyright does not provide Python formatting.
Configure project virtual environments with `pyrightconfig.json` or
`[tool.pyright]` in `pyproject.toml`. Polka bundles a baseline Python interpreter;
your project's interpreter and dependencies still need project configuration.
Both navigation and search use ripgrep and respect ignore files.
Literal newlines in filenames are unsupported by the file picker's candidate list.

## Make it yours

Shared defaults live in `config/kakrc`, the theme in `config/colors/ppy-dark.kak`.
Edit those files and rebuild to change the distribution.

Machine-local overrides live in `${XDG_CONFIG_HOME:-~/.config}/polka/extra.kak`,
load last, and only require restarting Polka. For example:

```kak
set-option global tabstop 4
set-option global indentwidth 4
```

Use `POLKA_USER_CONFIG=/path/to/extra.kak polka` to choose an override file.
The immutable bundled configuration remains independent of `~/.config/kak`.
Attaching with `polka -c <session>` uses that existing session's configuration;
launch without `-c` for a new Polka session.

## Flake interface

`packages.<system>.polka` and `.default`, `apps.<system>.polka` and `.default`,
and `overlays.default` are exposed. The package is defined for Apple Silicon
and Intel macOS, and aarch64/x86_64 Linux. Only the local host has been tested.

To import it into another flake, add a `polka` input and install
`inputs.polka.packages.${pkgs.system}.default` in your system or Home Manager
packages. The overlay also exposes `pkgs.polka`.

```sh
nix flake check
nix flake update nixpkgs  # intentionally update the pinned toolchain
nix build
```

`nix flake check` builds Polka and tests clean startup, file navigation,
personal overrides, Python go-to-definition, and real Python/Nix diagnostics.

## Theme provenance

The colours are ported from [peppy/ppy-jetbrains-theme](https://github.com/peppy/ppy-jetbrains-theme)
at revision `0fd810e515ea810654573e78900727864aa4eec1`, using ppy Dark's
editor XML and UI JSON. The source palette and MIT licence are preserved in
`vendor/ppy-jetbrains-theme/`. Kakoune has different token categories and UI
surfaces, so this is a palette-faithful adaptation rather than an exact IDE skin.
Use a terminal with true-colour support; fonts are controlled by your terminal.

The original `kak-lab` starter is superseded by Polka. It is kept only as a
local migration backup, not used by this flake.
