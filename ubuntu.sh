
sudo apt update
sudo apt upgrade -y

# You may need this to sacle.
#gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

# You may need this to make desktop looks modern.
# https://www.pling.com/p/1805660/

# You may need this to unload NVIDIA driver
# sudo systemctl isolate multi-user.target
# sudo modprobe -r nvidia-drm

tput setaf 2; echo "Installing curl..."; tput sgr0
sudo apt install -y w3m git vim sl zip unzip wget curl neofetch jq net-tools libglib2.0-dev-bin httping ffmpeg nano

tput setaf 2; echo "Installing tweaks..."; tput sgr0
sudo apt install -y gnome-tweaks gnome-shell-extension-prefs

tput setaf 2; echo "Installing vim..."; tput sgr0
sudo apt install -y vim

tput setaf 2; echo "Installing git..."; tput sgr0
sudo apt install -y git

tput setaf 2; echo "Installing vlc..."; tput sgr0
sudo apt install -y vlc

tput setaf 2; echo "Installing go..."; tput sgr0
sudo apt install -y golang-go

tput setaf 2; echo "Installing aria2..."; tput sgr0
sudo apt install -y aria2

tput setaf 2; echo "Installing adb..."; tput sgr0
sudo apt install -y adb

tput setaf 2; echo "Installing ffmpeg..."; tput sgr0
sudo apt install -y ffmpeg

tput setaf 2; echo "Installing Nextcloud..."; tput sgr0
sudo apt install -y nextcloud-desktop

tput setaf 2; echo "Installing ruby..."; tput sgr0
sudo apt install -y ruby

tput setaf 2; echo "Installing java..."; tput sgr0
sudo apt install -y openjdk-17-jdk default-jre

tput setaf 2; echo "Installing Chrome..."; tput sgr0
rm ./google-chrome-stable_current_amd64.deb
aria2c -x 16 https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb

tput setaf 2; echo "Installing Code..."; tput sgr0
rm ./*.deb
aria2c -x 16 "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
sudo dpkg -i ./*.deb
rm ./*.deb

tput setaf 2; echo "Installing Minecraft..."; tput sgr0
rm ./*.deb
aria2c -x 16 "https://launcher.mojang.com/download/Minecraft.deb"
sudo dpkg -i ./*.deb
rm ./*.deb

tput setaf 2; echo "Installing OBS Studio..."; tput sgr0
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo apt update
sudo apt install -y obs-studio

tput setaf 2; echo "Installing docker..."; tput sgr0
sudo apt-get install ca-certificates gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

tput setaf 2; echo "Installing .NET..."; tput sgr0
sudo DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_PRINT_TELEMETRY_MESSAGE="false" apt install -y apt-transport-https dotnet6
dotnet tool update --global dotnet-ef || dotnet tool install --global dotnet-ef

tput setaf 2; echo "Installing node..."; tput sgr0
curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install --global npm@latest
sudo npm install --global node-static typescript @angular/cli yarn

tput setaf 2; echo "Installing python..."; tput sgr0
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.8
sudo apt install -y python3-pip python-is-python3

tput setaf 2; echo "Installing kubectl..."; tput sgr0
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo rm ./kubectl

tput setaf 2; echo "Configuring git..."; tput sgr0
sudo apt autoremove -y

git config --global user.email "anduin@aiursoft.com"
git config --global user.name "Anduin Xue"

sudo apt --fix-broken install
sudo apt --fix-missing install
sudo apt autoremove -y
curl "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/main/test_env.sh" | bash
