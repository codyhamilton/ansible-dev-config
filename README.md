# devconf

A self-contained POSIX shell tool for managing developer configs (bash, git, vim, Cursor, Claude).

## Quick Install

```sh
curl -fsSL https://raw.githubusercontent.com/codyhamilton/ansible-dev-config/master/install.sh | sh
```

This will:
1. Clone the repo to `~/.local/opt/devconf`
2. Symlink `devconf` to `~/.local/bin/devconf`
3. Add `~/.local/bin` to your PATH in `~/.bashrc` / `~/.bash_profile`
4. Run `devconf configure` interactively

## Commands

```
devconf configure   Apply configs from repo to live system
devconf update      Pull latest repo changes, then configure
devconf sync        Copy live configs back to repo and commit
devconf help        Show help
```

### `devconf configure`

Deploys each config file from the repo to its live location. For each file:
- **Identical** → prints `[ok]`, skips
- **Different** → shows colored diff, prompts: `[a]ccept repo / [k]eep current / [e]dit in vim`

### `devconf update`

Pulls the latest repo changes (`git pull --rebase`), then runs `configure`.

### `devconf sync`

Compares live files to repo files. For each difference, prompts:
`[a]dd to repo / [k]eep repo / [e]dit in vim / [s]kip`

After collecting changes, stages them, prompts for a commit message, commits, and optionally pushes.

## Repo Structure

```
configs/
  bash/
    alias.sh          → ~/.bashrc.d/alias.sh
    defaults.sh       → ~/.bashrc.d/defaults.sh
  git/
    git-prompt-colors.sh  → ~/.git-prompt-colors.sh
    gitprompt.sh          → ~/.bashrc.d/gitprompt.sh
    gitcomplete.sh        → ~/.bashrc.d/gitcomplete.sh
    gitconfig-aliases     → git config --global alias.*
  vim/
    vimrc             → ~/.config/nvim/init.vim  (or ~/.vimrc)
    Darwin.vim        → OS-specific vim settings
    Debian.vim
    RedHat.vim
  cursor/
    argv.json         → ~/.cursor/argv.json
    mcp.json          → ~/.cursor/mcp.json
  claude/
    settings.json     → ~/.claude/settings.json
    CLAUDE.md         → ~/.claude/CLAUDE.md  (starter template)
bin/
  devconf             # CLI dispatcher
lib/
  utils.sh            # output helpers, OS detection, utilities
  diff.sh             # diff engine and interactive prompts
  configure.sh        # repo → live logic
  sync.sh             # live → repo logic
install.sh            # bootstrap one-liner
```

## Development

Clone directly and run from the repo:

```sh
git clone https://github.com/codyhamilton/ansible-dev-config.git ~/workspace/devconf
~/workspace/devconf/bin/devconf configure
```

## What Gets Configured

| Config | Live Location |
|--------|--------------|
| Bash aliases | `~/.bashrc.d/alias.sh` |
| Bash defaults (PS1, colors) | `~/.bashrc.d/defaults.sh` |
| bashrc.d loader | injected into `~/.bashrc` or `~/.bash_profile` |
| git-prompt colors | `~/.git-prompt-colors.sh` |
| gitprompt loader | `~/.bashrc.d/gitprompt.sh` |
| git tab completion | `~/.bashrc.d/gitcomplete.sh` |
| bash-git-prompt | `~/.bashrc.d/git-prompt/` (cloned from GitHub) |
| git aliases | `git config --global alias.*` |
| git settings | `push.default=simple`, `core.editor=vim` |
| vimrc | `~/.config/nvim/init.vim` or `~/.vimrc` |
| vim-plug | installed if missing |
| Cursor argv.json | `~/.cursor/argv.json` |
| Cursor mcp.json | `~/.cursor/mcp.json` |
| Claude settings | `~/.claude/settings.json` |
| Claude CLAUDE.md | `~/.claude/CLAUDE.md` (created if absent) |

## Compatibility

macOS, Debian/Ubuntu, Red Hat/Fedora/CentOS

## License

BSD
