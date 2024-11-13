#!/bin/bash

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Ansible
OS="$(uname -s)"
case "${OS}" in
Darwin*)
    echo "Installing Ansible..."
    echo
    brew install ansible
    ;;
*)
    echo "Unsupported operating system: ${OS}"
    exit 1
    ;;
esac
echo "Ansible installation complete. Running setup..."

# ansible-playbook ~/.bootstrap/setup.ansible.yml --ask-become-pass
