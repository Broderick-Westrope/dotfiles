# dotfiles

This repo contains the configuration to setup my machines. This is using [Chezmoi](https://chezmoi.io), the dotfile manager to setup the install. It was inspired by Logan Donleys [setup](https://github.com/logandonley/dotfiles).

This automated setup is currently only configured for Macs.

## How to run

```shell
export GITHUB_USERNAME=Broderick-Westrope
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```
