echo "Setting timezone..."
sudo timedatectl set-timezone UTC

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
