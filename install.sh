#!/usr/bin/env bash
# Personal dev-container bootstrap, run by VS Code's dotfiles feature.
# Idempotent, and never fails container creation: problems are reported as warnings.
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS_REPO="${SKILLS_REPO:-https://github.com/pkuppens/skills.git}"
SKILLS_CLONE="${SKILLS_CLONE:-$HOME/skills}"
# Claude Code and OpenCode both load personal skills from here.
SKILLS_TARGET="${SKILLS_TARGET:-$HOME/.claude/skills}"
SKILLS_LIST="${SKILLS_LIST:-$DOTFILES_DIR/skills.txt}"

warn() { echo "dotfiles: warning: $*" >&2; }
info() { echo "dotfiles: $*"; }

install_skills() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git not found; skipping skills"
    return 0
  fi

  if [ -d "$SKILLS_CLONE/.git" ]; then
    git -C "$SKILLS_CLONE" pull --ff-only --quiet \
      || warn "could not fast-forward $SKILLS_CLONE; leaving it as is"
  elif [ -e "$SKILLS_CLONE" ]; then
    warn "$SKILLS_CLONE exists but is not a git clone; skipping skills"
    return 0
  else
    git clone --quiet "$SKILLS_REPO" "$SKILLS_CLONE" \
      || { warn "could not clone $SKILLS_REPO; skipping skills"; return 0; }
  fi

  mkdir -p "$SKILLS_TARGET"

  local line name src dst
  while IFS= read -r line || [ -n "$line" ]; do
    name="${line%%#*}"
    name="${name//[[:space:]]/}"
    [ -z "$name" ] && continue

    src="$SKILLS_CLONE/skills/$name"
    dst="$SKILLS_TARGET/$name"

    if [ ! -f "$src/SKILL.md" ]; then
      warn "skill '$name' not found in $SKILLS_CLONE/skills"
    elif [ -L "$dst" ]; then
      ln -sfn "$src" "$dst"
    elif [ -e "$dst" ]; then
      warn "$dst exists and is not a symlink; leaving it alone"
    else
      ln -s "$src" "$dst"
      info "linked skill $name"
    fi
  done < "$SKILLS_LIST"
}

install_skills
exit 0
