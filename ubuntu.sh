
sudo apt update
sudo apt upgrade -y

gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

tput setaf 2; echo "Installing curl..."; tput sgr0
sudo apt install -y curl libglib2.0-dev-bin

tput setaf 2; echo "Installing tweaks..."; tput sgr0
sudo apt install -y gnome-tweaks

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

tput setaf 2; echo "Installing Spotify..."; tput sgr0
sudo snap install spotify

tput setaf 2; echo "Installing ffmpeg..."; tput sgr0
sudo apt install -y ffmpeg

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

tput setaf 2; echo "Installing Teams..."; tput sgr0
rm ./*.deb
aria2c -x 16 "https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x409&culture=en-us&country=US"
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
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -r -s)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb && rm ./packages-microsoft-prod.deb
sudo apt-get update
sudo DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_PRINT_TELEMETRY_MESSAGE="false" apt install -y apt-transport-https dotnet-sdk-6.0 libgdiplus
dotnet tool update --global dotnet-ef || dotnet tool install --global dotnet-ef

tput setaf 2; echo "Installing node..."; tput sgr0
curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install --global npm@latest
sudo npm install --global node-static typescript @angular/cli yarn

tput setaf 2; echo "Installing python..."; tput sgr0
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.8
sudo apt install python3-pip python-is-python3

tput setaf 2; echo "Installing kubectl..."; tput sgr0
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo rm ./kubectl

tput setaf 2; echo "Configuring git..."; tput sgr0
sudo apt autoremove -y

git config --global user.email "anduin@aiursoft.com"
git config --global user.name "Anduin Xue"

git clone https://github.com/AiursoftWeb/Infrastructures.git "$HOME/source/repos/AiursoftWeb/Infrastructures"
git clone https://github.com/Anduin2017/HowToCOok.git "$HOME/source/repos/Anduin2017/HowToCook"

tput setaf 2; echo "Installing themes..."; tput sgr0
git clone https://github.com/vinceliuice/Mojave-gtk-theme.git "$HOME/source/repos/Others/Mojave-gtk-theme"
~/source/repos/Others/Mojave-gtk-theme/install.sh

tput setaf 2; echo "Installing icons..."; tput sgr0
git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git "$HOME/.icons/la-capitaine-icon-theme"

sudo apt --fix-broken install
sudo apt --fix-missing install
curl "https://raw.githubusercontent.com/Anduin2017/configuration-script-win/main/test_env.sh" | bash
