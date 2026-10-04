# dotfiles

This repo contains the configuration to setup my machines using [Chezmoi](https://chezmoi.io), a modern dotfile manager.

***NOTE: Only macOS is supported for automated setup.***

## Quick Setup (New Machine)

```shell
export GITHUB_USERNAME=Broderick-Westrope

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --source ~/dev/helse/dotfiles --apply $GITHUB_USERNAME
```

This will:
1. Install chezmoi and clone this repository to `~/dev/helse/dotfiles`
2. Ask "Is this a personal machine", which picks the personal or work package group
3. Install Homebrew (if not present)
4. Apply all dotfile configurations
5. Install the packages in the generated Brewfile
6. Set up the shell environment

### Before the first apply

These aren't in the repo and need setting up by hand:

- **SSH key for the personal GitHub account.** `~/.gitconfig-helse` rewrites `https://github.com/` to `git@github.com-personal:`, so `~/.ssh/config` needs a `Host github.com-personal` entry pointing at that key.
- **1Password.** Install the app, turn on Settings > Developer > Integrate with 1Password CLI, and make sure the items listed in `~/.config/op-refs.env` exist.
- **gh accounts.** Run `gh auth login` once for each account (`Broderick-Westrope` and `brodie-euc`).

## Managing Packages

Packages are managed in [`.chezmoidata.yaml`](./.chezmoidata.yaml). The top-level `formulae` and `casks` lists install everywhere; `personal` and `work` add to them depending on the answer to "Is this a personal machine" during `chezmoi init`.

chezmoi renders those lists into `~/.config/homebrew/Brewfile`. Whenever the rendered Brewfile changes, `chezmoi apply` installs anything missing with `brew bundle install --no-upgrade`. It never upgrades or removes packages.

```shell
# Show packages in the Brewfile that aren't installed
brew bundle check --verbose --no-upgrade --global

# Preview what isn't in the Brewfile, then remove it once the list looks right
brew bundle cleanup --global
brew bundle cleanup --global --force

# Upgrade separately, when you choose to
brew upgrade
```

## Common Commands

```shell
# Apply changes after editing dotfiles
chezmoi apply

# See what would change
chezmoi diff

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to be managed
chezmoi add ~/.new-config

# Copy edits made directly to a managed file back into the repo
chezmoi re-add ~/.zshrc

# Apply files without running the setup scripts
chezmoi apply --exclude scripts

# Update from repository
chezmoi update
```

## Secrets

No secrets live in this repo or in plain text on disk. Keys are stored in 1Password and `~/.config/op-refs.env` holds only `op://` references.

- `withkeys <cmd>` runs one command with those keys loaded (`op run`).
- `anvil` is a shell function that loads only the permission bouncer's key at startup.
- Don't use chezmoi's 1Password template functions for keys: they write the resolved value into the file on disk, where agents can read it.

## GitHub accounts

- **git:** `~/.config/git/config` includes `~/.gitconfig-helse` for anything under `~/dev/helse/`, which switches to the personal email, signing key and SSH host. Linked worktrees inherit it because their git dir lives in the main repo.
- **gh:** `~/.local/bin/gh` wraps the real `gh` and sets `GH_TOKEN` per call: `Broderick-Westrope` for repos under `~/dev/helse/` (or `--repo Broderick-Westrope/...`), `brodie-euc` otherwise. Override with `GH_ACCOUNT=<login>`.

## Cursor

**Theme.** Anvil Night lives in [`cursor/anvil-night/`](./cursor/anvil-night/). It's a plain VS Code colour theme that chezmoi never copies into `$HOME`. To change it:

1. Edit `themes/anvil-night-color-theme.json` directly.
2. Bump `version` in `package.json`.
3. Run `chezmoi apply`, then reload Cursor windows (`Developer: Reload Window`).

`run_onchange_after_setup-cursor-theme.sh.tmpl` packages the folder as a VSIX with `zip` and installs it with Cursor's CLI. It reruns whenever the theme files change or when `Cursor.app` first appears in `/Applications` or `~/Applications`, so a fresh machine picks the theme up after Homebrew installs Cursor. Without a Cursor CLI it prints a warning and skips.

**Settings.** `~/Library/Application Support/Cursor/User/settings.json` is managed on every machine. Cursor writes to it when you change settings in the UI, so copy those changes back:

```bash
chezmoi re-add "$HOME/Library/Application Support/Cursor/User/settings.json"
```

**Manual steps on a new machine.** These live in Cursor's internal state, not in `settings.json`:

- **Status bar:** right-click the status bar and untick everything except Editor Selection, Source Control Checkout and Source Control Sync.
- **Cursor Tab:** Cursor Settings (`cmd+shift+j`) → Tab → turn Cursor Tab off.

## What's Included

- **Shell**: zsh with starship prompt, zoxide, fzf integration
- **Development**: mise for tool management, lazygit, lazydocker, nvim (LazyVim), Zed, Cursor (settings and the Anvil Night theme)
- **Git and GitHub**: per-directory identities, SSH commit signing, the `gh` account wrapper
- **Agents**: Anvil config, including permission rules
- **Terminal**: Ghostty with custom configuration

## Known gaps

- `~/.config/anvil/anvil.json` on this machine has a skill-paths hook that points at a temporary worktree, so it isn't tracked yet. `chezmoi apply` skips the file while it differs; run `chezmoi re-add` once the hook has a permanent home.
- `~/.config/nvim` is also its own git repo with no remote. Commit there, then `chezmoi re-add ~/.config/nvim`.
- The Raycast export (`dot_config/raycast`) is from November 2024 and isn't applied. Replace it with a fresh export or delete it.
- Casks installed before the switch to `/Applications` still live in `~/Applications` and upgrade in place there.
- Cursor's per-item status bar visibility and the Cursor Tab toggle aren't settings-backed, so they're manual steps (see [Cursor](#cursor)).
- The Cursor theme can't reproduce everything from the Zed original. VS Code has no dim ANSI colours and no hollow diff hunks, and some Zed UI keys have no equivalent; the commit that added the theme lists each one.
