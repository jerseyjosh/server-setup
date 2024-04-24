#!/bin/bash

# install packages
apt update && sudo apt install -y htop zsh screen jupyter-notebook

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set zsh as the default shell
chsh -s $(which zsh)

# start jupyter server in a detached screen session
screen -dmS jupyter bash -c "cd /home/josh && jupyter notebook --allow-root --no-browser --port=8888 --NotebookApp.token='' --NotebookApp.password=''"

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "josh@hakuna.co.uk" -f ~/.ssh/id_ed25519 -N ''

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# Print SSH public key
echo "SSH key generated. Please add the following public key to GitHub:"
cat ~/.ssh/id_ed25519.pub
