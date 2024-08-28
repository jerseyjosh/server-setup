#!/bin/bash

# Install necessary packages
apt update && apt install -y zsh screen htop python3-venv

# Git configuration
git config --global user.email "josh@hakuna.co.uk"
git config --global user.name "Josh Griffiths"

# Install Oh My Zsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" bash --unattended

# Set Zsh as the default shell
chsh -s $(which zsh)

# Setup Python virtual environment
if [ -d "/home/josh" ]; then
    # Use /home/josh if it exists
    HOME_DIR="/home/josh"
else
    # Otherwise default to /home
    HOME_DIR="/home"
fi

cd "$HOME_DIR" || exit 1  # Change to home directory, exit if it fails

# remake venv if exists
if [ -d "venv" ]; then
    rm -rf venv
fi

# activate environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
python3 -m pip install --upgrade pip \
    numpy \
    pandas \
    jupyter notebook==7.0.8 \
    tqdm \
    matplotlib \
    ipykernel \
    scipy \
    statsmodels \
    scikit-learn \
    polars \
    pyarrow \
    cvxpy

python3 -m ipykernel install --user --name=venv --display-name="Python (venv)"

# Create packages directory
mkdir -p packages

# Start from home directory and activate venv on login
echo "cd $HOME_DIR && source $HOME_DIR/venv/bin/activate" >> /root/.zshrc

# Start Jupyter server in a detached screen session
screen -dmS jupyter zsh -c "cd $HOME_DIR && jupyter notebook --allow-root --no-browser --port=8888 --NotebookApp.token='' --NotebookApp.password=''"

# Generate SSH key for GitHub to clone repos
ssh-keygen -t ed25519 -C "josh@hakuna.co.uk" -f ~/.ssh/id_ed25519 -N '' -q <<< y >/dev/null 2>&1

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# Print SSH public key
echo "---------"
echo "SSH key generated. Please add the following public key to GitHub:"
cat ~/.ssh/id_ed25519.pub
echo "---------"
echo "Logout and log back in to activate Zsh if not already activated."
