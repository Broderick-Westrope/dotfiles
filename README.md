# dotfiles

This repo contains the configuration to setup my machines. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install. It was inspired by Logan Donleys [setup](https://github.com/logandonley/dotfiles).

Support for automated setup prioritises MacOS (since this is my daily driver), but there is some support for Linux distros as well.

## How to run

```shell
export GITHUB_USERNAME=Broderick-Westrope
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

## Adding new Brew packages

Brew packages are added in [setup.ansible.yml](./dot_bootstrap/setup.ansible.yml). The following are some utility commands for getting the currently installed packages.

```shell
brew list --installed-on-request --formulae >> formulae.txt

brew list --casks >> casks.txt
```

This way new packages can be installed on the current machine and then these commands can be run to see what should be included in the setup file. It will alphabetise and omit dependencies for you.