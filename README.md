# dotfiles

Personal setup for dev containers and Codespaces. It links selected skills from
[pkuppens/skills](https://github.com/pkuppens/skills) into `~/.claude/skills`,
where both Claude Code and OpenCode load them.

## Use in VS Code dev containers

Add to your **host** VS Code user settings (not to any project):

```json
"dotfiles.repository": "pkuppens/dotfiles",
"dotfiles.targetPath": "~/dotfiles",
"dotfiles.installCommand": "install.sh"
```

Every dev container you create or rebuild then clones this repo and runs `install.sh`.
For Codespaces, enable *Automatically install dotfiles* in GitHub settings.

## What `install.sh` does

1. Clones `pkuppens/skills` to `~/skills`, or fast-forwards an existing clone.
2. Links each skill named in [`skills.txt`](skills.txt) to `~/.claude/skills/<name>`.

It is safe to run repeatedly. Existing real directories are never overwritten, and failures
only produce warnings, so they never block container creation.

Overrides: `SKILLS_REPO`, `SKILLS_CLONE`, `SKILLS_TARGET`, `SKILLS_LIST`.

## Add a skill

Add its directory name to `skills.txt`, then run `~/dotfiles/install.sh`.
