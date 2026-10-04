# dotfiles

This repo contains the configuration to setup my machines using [Chezmoi](https://chezmoi.io), a modern dotfile manager.

***NOTE: Only macOS is supported for automated setup.***

## Quick Setup (New Machine)

```shell
export GITHUB_USERNAME=Broderick-Westrope

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --source ~/dev/helse/dotfiles --apply $GITHUB_USERNAME
```

This will:
1. Install chezmoi
2. Clone this repository
3. Install Homebrew (if not present)
4. Install all packages defined in `.chezmoidata.yaml`
5. Apply all dotfile configurations
6. Set up shell environment

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

# Update from repository
chezmoi update
```

## What's Included

- **Shell**: zsh with starship prompt, zoxide, fzf integration
- **Development**: mise for tool management, lazygit, lazydocker
- **Applications**: Arc browser, VS Code, various productivity apps
- **Terminal**: Ghostty with custom configuration