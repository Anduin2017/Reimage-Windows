export DEBIAN_FRONTEND=noninteractive
sudo pro config set apt_news=false
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
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Code
echo "Setting ms..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Snap
sudo snap remove firefox
sudo snap remove snap-store
sudo snap remove gnome-3-38-2004
sudo snap remove gtk-common-themes
sudo snap remove snapd-desktop-integration
sudo snap remove core20
sudo snap remove bare
sudo snap remove snapd
sudo apt remove snapd
sudo rm ~/snap -rvf
sudo rm  /snap -rvf

# Node
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

sudo apt install nodejs google-chrome-stable\
  apt-transport-https code vim clevis clevis-luks\
  w3m git vim sl zip unzip wget curl neofetch jq\
  net-tools libglib2.0-dev-bin httping ffmpeg nano\
  gnome-tweaks gnome-shell-extension-prefs vim git\
  vlc golang-go aria2 adb ffmpeg nextcloud-desktop\
  ruby openjdk-17-jdk default-jre dotnet6 ca-certificates\
  gnupg lsb-release  docker-ce docker-ce-cli\
  containerd.io jq htop iotop iftop ntp ntpdate ntpstat\
  cockpit pass

# Repos
mkdir ~/Source
mkdir ~/Source/repos

# SSH Keys
mkdir ~/.ssh
cp ~/Nextcloud/Storage/SSH/* ~/.ssh/

# Upgrade
echo "Upgrading..."
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

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

# Script
cp ~/Nextcloud/Storage/Scripts/sync_lab_to_hub.sh ~/Source/repos/
chmod +x ~/Source/repos/sync_lab_to_hub.sh

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


gsettings set org.gnome.shell.extensions.ding show-trash true
