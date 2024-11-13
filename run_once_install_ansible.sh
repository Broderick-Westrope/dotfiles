#!/bin/bash

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

ansible-playbook ~/.bootstrap/setup.ansible.yml --ask-become-pass
echo "Ansible installation complete."
