# install packages
apt update && apt install -y zsh screen htop

# git setup
git config --global user.email "josh@hakuna.co.uk"
git config --global user.name "Josh Griffiths"

# install ohmyzsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" bash --unattended

# Set zsh as the default shell
chsh -s $(which zsh)

# Setup python venv
cd /home/josh
rm -rf venv
python3 -m venv venv
source venv/bin/activate
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

# install local packages
cd /home/josh/packages
python3 -m pip install -e quant-tools
python3 -m pip install -e dataframe-tools
python3 -m pip install -e spread-research
python3 -m pip install -e backtest-client
python3 -m pip install -e preprocessing

# change zsh defualts
echo "source /home/josh/venv/bin/activate" >> /root/.zshrc

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
