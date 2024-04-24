#!/bin/bash

# install packages
apt update && sudo apt install -y zsh screen htop

# install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set zsh as the default shell
chsh -s $(which zsh)

# Setup python venv
cd /home/josh
rm -rf venv
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip numpy pandas jupyter matplotlib ipykernel scipy statsmodels scikit-learn polars
python3 -m ipykernel install --user --name=venv --display-name="Python (venv)"
echo 'alias python3="/home/josh/venv/bin/python3"' >> ~/.zshrc

# start jupyter server in a detached screen session
screen -dmS jupyter zsh -c "cd /home/josh && jupyter notebook --allow-root --no-browser --port=8888 --NotebookApp.token='' --NotebookApp.password=''"

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "josh@hakuna.co.uk" -f ~/.ssh/id_ed25519 -N ''

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# Print SSH public key
echo "---------"
echo "SSH key generated. Please add the following public key to GitHub:"
cat ~/.ssh/id_ed25519.pub
echo "---------"
echo "Logout and log back in to activate zsh if not already activated."
