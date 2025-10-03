# dotfiles

This repo contains the configuration to setup my machines using [Chezmoi](https://chezmoi.io), a modern dotfile manager.

***NOTE: Only macOS is supported for automated setup.***

## Quick Setup (New Machine)

```shell
export GITHUB_USERNAME=Broderick-Westrope
# Optional: Set your email for git configuration
export GIT_EMAIL=your-email@example.com

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

This will:
1. Install chezmoi
2. Clone this repository
3. Install Homebrew (if not present)
4. Install all packages defined in `.chezmoidata.yaml`
5. Apply all dotfile configurations
6. Set up shell environment

## Managing Packages

Packages are managed in [`.chezmoidata.yaml`](./.chezmoidata.yaml). To add new packages:

1. Edit the file directly, or
2. Install packages manually and use these commands to see what's installed:

```shell
# List formulae (CLI tools)
brew list --installed-on-request --formulae

# List casks (GUI applications)  
brew list --casks
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
- **Terminal**: WezTerm with custom configuration