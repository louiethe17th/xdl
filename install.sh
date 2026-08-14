#!/usr/bin/env bash
# Installer for xdl — sets up an isolated venv and puts the script on your PATH.
set -euo pipefail

BIN_DIR="${XDL_BIN_DIR:-$HOME/.local/bin}"
VENV="${XDL_VENV:-$HOME/.local/share/xdl-venv}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/xdl"

die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[36m==>\033[0m %s\n' "$*"; }

[[ -f "$SRC" ]] || die "can't find xdl next to this installer"
command -v python3 >/dev/null || die "python3 is required"

info "creating virtualenv at $VENV"
python3 -m venv "$VENV"

info "installing gallery-dl and yt-dlp (this takes a moment)"
"$VENV/bin/pip" install --quiet --upgrade pip yt-dlp gallery-dl

info "installing xdl to $BIN_DIR"
mkdir -p "$BIN_DIR"
install -m 755 "$SRC" "$BIN_DIR/xdl"

printf '\n\033[32m✓\033[0m installed\n'
printf '    gallery-dl %s\n' "$("$VENV/bin/gallery-dl" --version)"
printf '    yt-dlp     %s\n' "$("$VENV/bin/yt-dlp" --version)"

command -v ffmpeg >/dev/null || printf '\n\033[33mnote:\033[0m ffmpeg not found — needed to merge some videos.\n'

case ":$PATH:" in
    *":$BIN_DIR:"*) printf '\nTry it:  xdl https://x.com/someone/status/123\n' ;;
    *) printf '\n\033[33mnote:\033[0m %s is not on your PATH. Add it:\n' "$BIN_DIR"
       printf '    bash/zsh:  export PATH="%s:$PATH"\n' "$BIN_DIR"
       printf '    fish:      fish_add_path %s\n' "$BIN_DIR" ;;
esac
