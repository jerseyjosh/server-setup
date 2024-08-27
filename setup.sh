# install packages
apt update && apt install -y zsh screen htop python3-venv

# git setup
git config --global user.email "josh@hakuna.co.uk"
git config --global user.name "Josh Griffiths"

# install ohmyzsh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" bash --unattended

# Set zsh as the default shell
chsh -s $(which zsh)

# Setup python venv
if [ -d "/home/josh" ]; then
    # use /home/josh if it exists
    HOME_DIR="/home/josh"
else
    # otherwise default to /home
    HOME_DIR="/home"
fi
cd "$HOME_DIR" || exit 1  # cd into home directory, exit if cd fails
if [ -d "venv" ]; then
    rm -rf venv
fi
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

# Generate SSH key for GitHub to clone repos
ssh-keygen -t ed25519 -C "josh@hakuna.co.uk" -f ~/.ssh/id_ed25519 -N ''

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_ed25519

# install istari repos
mkdir -p packages # make packages dir if not exists
cd packages
repos=(
    "git@github.com:istari-capital/quant-tools.git"
    "git@github.com:istari-capital/dataframe-tools.git"
    "git@github.com:istari-capital/backtest-client.git"
    "git@github.com:istari-capital/preprocessing.git"
    "git@github.com:istari-capital/spread-research.git"
)
# Loop through the repository URLs and clone them in parallel
for repo in "${repos[@]}"; do
    git clone "$repo" &
done
# Wait for all background jobs to finish
wait

# Loop through each new packages and install
for dir in */; do
    if [ -d "$dir" ]; then
        python3 -m pip install "$dir"
    fi
done

# change zsh defualts
echo "source $HOME_DIR/venv/bin/activate" >> /root/.zshrc

# start jupyter server in a detached screen session
screen -dmS jupyter zsh -c "cd $HOME_DIR && jupyter notebook --allow-root --no-browser --port=8888 --NotebookApp.token='' --NotebookApp.password=''"

# Print SSH public key
echo "---------"
echo "SSH key generated. Please add the following public key to GitHub:"
cat ~/.ssh/id_ed25519.pub
echo "---------"
echo "Logout and log back in to activate zsh if not already activated."
