export DEBIAN_FRONTEND=noninteractive

# Sudo
# Avoid appending to sudoers file if already exists
if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/anduin; then
  echo "Adding $USER to sudoers..."
  sudo mkdir -p /etc/sudoers.d
  sudo touch /etc/sudoers.d/anduin
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/anduin
fi

#sudo pro config set apt_news=false
sudo rm /var/lib/ubuntu-advantage/messages/*

echo "Preinstall..."
sudo apt-get install wget gpg curl

echo "Setting timezone..."
sudo timedatectl set-timezone UTC

# Docker
echo "Setting docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Chrome
echo "Setting google..."
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' 
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Code
echo "Setting ms..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Spotify
echo "Setting spotify..."
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Nextcloud
echo "Setting nextcloud..."
sudo add-apt-repository ppa:nextcloud-devs/client --yes

# Snap
echo "Removing snap..."
sudo snap remove firefox
sudo snap remove snap-store
sudo snap remove gnome-3-38-2004
sudo snap remove gtk-common-themes
sudo snap remove snapd-desktop-integration
sudo snap remove core20
sudo snap remove bare
sudo snap remove snapd
sudo apt remove snapd -y
sudo rm ~/snap -rvf
sudo rm  /snap -rvf

# Firefox
echo "Setting firefox..."
sudo add-apt-repository ppa:mozillateam/ppa --yes
echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | sudo tee /etc/apt/preferences.d/mozilla-firefox

# Node
echo "Setting node..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

echo "Installing node, google, firefox, ibus-rime, apt-transport-https, code, vim, remmina, remmina-plugin-rdp, w3m, git, vim, sl, zip, unzip, wget, curl, neofetch, jq, net-tools, libglib2.0-dev-bin, httping, ffmpeg, nano, gnome-tweaks, gnome-shell-extension-prefs, spotify-client, vlc, golang-go, aria2, adb, ffmpeg, nextcloud-desktop, ruby, openjdk-17-jdk, default-jre, dotnet6, ca-certificates, gnupg, lsb-release, docker-ce, docker-ce-cli, pinta, aisleriot, containerd.io, jq, htop, iotop, iftop, ntp, ntpdate, ntpstat, docker-compose, tree, smartmontools..."
sudo apt install nodejs google-chrome-stable firefox ibus-rime\
  apt-transport-https code vim remmina remmina-plugin-rdp\
  w3m git vim sl zip unzip wget curl neofetch jq\
  net-tools libglib2.0-dev-bin httping ffmpeg nano\
  gnome-tweaks gnome-shell-extension-prefs spotify-client\
  vlc golang-go aria2 adb ffmpeg nextcloud-desktop\
  ruby openjdk-17-jdk default-jre dotnet6 ca-certificates\
  gnupg lsb-release  docker-ce docker-ce-cli pinta aisleriot\
  containerd.io jq htop iotop iftop ntp ntpdate ntpstat\
  docker-compose tree smartmontools blender hugo\

# NPM
sudo npm i -g node-static yarn

# XRay
echo "Installing xray..."
sudo bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
sudo cp ~/Nextcloud/Storage/XRay/xray.json /usr/local/etc/xray/config.json
sudo systemctl restart xray.service
#echo "Setting system proxy settings to use xray..."
#export http_proxy="http://localhost:10809/"
#export https_proxy="http://localhost:10809/"

# Repos
echo "Adding repos..."
mkdir ~/Source
mkdir ~/Source/Repos

# Chinese input
echo "Setting Chinese input..."
wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip
unzip main.zip -d rime-ice-main
mkdir -p ~/.config/ibus/rime
mv rime-ice-main/*/* ~/.config/ibus/rime/
rm -rf rime-ice-main
rm main.zip
echo "Rime configured!"

# Git
echo "Setting git..."
git config --global user.email "anduin@aiursoft.com"
git config --global user.name "Anduin Xue"

# SSH Keys
echo "Setting SSH keys..."
mkdir ~/.ssh
cp -r ~/Nextcloud/Storage/SSH/* ~/.ssh/
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa

# GPG Keys
echo "Setting GPG keys..."
sudo rm ~/.gnupg -rf
mkdir ~/.gnupg
gpg --import ~/Nextcloud/Storage/GPG/private.key
chmod 700 ~/.gnupg
SIGNKEY=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | awk -F/ '{print $2}')
git config --global user.signingkey $SIGNKEY
git config --global commit.gpgsign true

# Upgrade
echo "Upgrading..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Script
cp ~/Nextcloud/Storage/Scripts/sync_lab_to_hub.sh ~/Source/Repos/
chmod +x ~/Source/Repos/sync_lab_to_hub.sh

# Rider
echo "Installing Rider... (INOP)"
echo "Please download Rider from https://www.jetbrains.com/rider/download/#section=linux"
echo "[Desktop Entry]
Name=JetBrains Rider
Comment=Integrated Development Environment
Exec=/opt/rider/bin/rider.sh
Icon=/opt/rider/bin/rider.png
Terminal=false
Type=Application
Categories=Development;IDE;" | sudo tee /usr/share/applications/jetbrains-rider.desktop

# Installing wps-office
if ! dpkg -s wps-office > /dev/null 2>&1; then
    echo "wps-office is not installed, downloading and installing..."
    # Download the deb package
    wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11698/wps-office_11.1.0.11698.XA_amd64.deb
    # Install the package
    sudo dpkg -i wps-office_11.1.0.11698.XA_amd64.deb
    # Remove the package file
    rm wps-office_11.1.0.11698.XA_amd64.deb
else
    echo "wps-office is already installed"
fi

# Installing docker-desktop
if ! dpkg -s docker-desktop > /dev/null 2>&1; then
    echo "docker-desktop is not installed, downloading and installing..."
    # Download the deb package
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.0-amd64.deb
    # Install the package
    sudo dpkg -i docker-desktop-4.22.0-amd64.deb
    # Remove the package file
    rm docker-desktop-4.22.0-amd64.deb
else
    echo "docker-desktop is already installed"
fi


# Nextcloud talk
echo "Installing Nextcloud talk... (INOP)"
echo "Please download Nextcloud talk from https://github.com/nextcloud/talk-desktop"
echo "[Desktop Entry]
Name=Nextcloud talk
Comment=Social
Exec=/opt/nct/nct
Icon=/opt/nct/nct.png
Terminal=false
Type=Application
Categories=Social;" | sudo tee /usr/share/applications/nct.desktop

# Dotnet tools
function TryInstallDotnetTool {
  toolName=$1
  globalTools=$(dotnet tool list --global)

  if [[ $globalTools =~ $toolName ]]; then
    echo "$toolName is already installed. Updating it.." 
    dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
  else
    echo "$toolName is not installed. Installing it.."
    if ! dotnet tool install --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null; then
      echo "$toolName failed to be installed. Trying updating it.."
      dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
      echo "Failed to install or update .NET $toolName"
    fi
  fi
}

TryInstallDotnetTool "dotnet-ef"
TryInstallDotnetTool "Anduin.Parser"
TryInstallDotnetTool "Anduin.HappyRecorder"
~/.dotnet/tools/happy-recorder config set-db-location --path ~/Nextcloud/Storage/HappyRecords/
TryInstallDotnetTool "Aiursoft.NugetNinja"
TryInstallDotnetTool "Aiursoft.Dotlang"
TryInstallDotnetTool "Aiursoft.NiBot"
TryInstallDotnetTool "JetBrains.ReSharper.GlobalTools"

# Theme
git clone https://github.com/vinceliuice/Fluent-icon-theme.git
./Fluent-icon-theme/install.sh
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
./Fluent-gtk-theme/install.sh --tweak noborder

rm ./Fluent-icon-theme -rvf
rm ./Fluent-gtk-tehem -rvf
#rm -rf ~~/.local/share/gnome-shell/extensions/
unzip -o ~/Nextcloud/Storage/Gnome/extensions.zip -d ~/.local/share/gnome-shell/extensions/
dconf load /org/gnome/ < ~/Nextcloud/Storage/Gnome/backup.txt

# Other settings:

# * Setup scale
# * Login Chrome
# * Login Nextcloud
# * Login VSCode & GitHub
# * Install Outlook PWA
# * Configure Theme
# * Configure weather plugin
# * Setup mouse speed
# * Install Docker Desktop
# * Install fingerprint driver

# Fix
echo "Removing deprecated packages..."
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-broken  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-missing  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sleep 1