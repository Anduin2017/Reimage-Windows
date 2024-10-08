echo "Setting timezone..."
sudo timedatectl set-timezone UTC

sudo apt install -y dotnet8 aria2 ffmpeg

# Chrome
wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub
sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable

# code
cd ~
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install code

# nextcloud
sudo add-apt-repository -y ppa:nextcloud-devs/client
sudo apt update
sudo apt install nextcloud-desktop nautilus-nextcloud

# wechat
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh
sudo apt install com.qq.weixin.deepin

# qget
echo '# generated by anduinos
alias qget="aria2c -c -s 16 -x 16 -k 1M -j 16"
' >> ~/.bashrc
source ~/.bashrc

# Microsoft
echo "This is a hack here. This is because Microsoft's repo is soooooooo stupid that it mixed up the .NET SDK!"
wget -q "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb"
sudo dpkg -i ./packages-microsoft-prod.deb
rm ./packages-microsoft-prod.deb
sudo apt update
sudo apt install powershell
sudo rm /etc/apt/sources.list.d/microsoft-prod.list
sudo apt update

# Powershell Profile
URL="https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/PROFILE_LINUX.ps1"
mkdir -p ~/.config
mkdir -p ~/.config/powershell
curl "$URL" --output - > ~/.config/powershell/Microsoft.PowerShell_profile.ps1

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
mkdir ~/Source > /dev/null 2>&1
mkdir ~/Source/Repos > /dev/null 2>&1

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
git config --global pull.rebase false 

# Test ssh with ssh to git@github
echo "Testing SSH connection to github.com..."
echo "yes" | ssh git@github.com

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
    fi
  fi
}

TryInstallDotnetTool "dotnet-ef"
TryInstallDotnetTool "Anduin.Parser"
TryInstallDotnetTool "Aiursoft.Static"
TryInstallDotnetTool "Anduin.HappyRecorder"
~/.dotnet/tools/happy-recorder config set-db-location --path ~/Nextcloud/Storage/HappyRecords/
TryInstallDotnetTool "Aiursoft.NugetNinja"
TryInstallDotnetTool "Aiursoft.Dotlang"
TryInstallDotnetTool "Aiursoft.DotDownload"
TryInstallDotnetTool "Aiursoft.NiBot"
TryInstallDotnetTool "JetBrains.ReSharper.GlobalTools"

sudo ln -s ~/Nextcloud/ ~/Desktop/
sudo ln -s ~/Source/Repos/ ~/Desktop/
