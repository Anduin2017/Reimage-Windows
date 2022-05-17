tput setaf 2; echo "Bash version:"; tput sgr0
bash --version | head -1

tput setaf 2; echo "gsudo version:"; tput sgr0
gsudo --version | head -1

tput setaf 2; echo "Winget version:"; tput sgr0
winget --version; echo ""

tput setaf 2; echo "Git version:"; tput sgr0
git --version

tput setaf 2; echo "Vim version:"; tput sgr0
vim --version | head -1

tput setaf 2; echo "SSH version:"; tput sgr0
ssh -V

tput setaf 2; echo "Go version:"; tput sgr0
go version

tput setaf 2; echo "Node version:"; tput sgr0
node --version
tput setaf 2; echo "npm version:"; tput sgr0
npm --version
tput setaf 2; echo "TypeScript version:"; tput sgr0
tsc --version
tput setaf 2; echo "Yarn version:"; tput sgr0
yarn --version

tput setaf 2; echo "Java version:"; tput sgr0
java --version
tput setaf 2; echo "Javac version:"; tput sgr0
javac --version

tput setaf 2; echo "dotnet version:"; tput sgr0
dotnet --version
tput setaf 2; echo "Entity Framework Core version:"; tput sgr0
dotnet ef --version

tput setaf 2; echo "Python version:"; tput sgr0
python --version
tput setaf 2; echo "pip version:"; tput sgr0
pip --version

tput setaf 2; echo "Ruby version:"; tput sgr0
ruby --version
tput setaf 2; echo "Gem version:"; tput sgr0
gem --version

tput setaf 2; echo "Adb version:"; tput sgr0
adb --version | head -2

tput setaf 2; echo "FFmpeg version:"; tput sgr0
ffmpeg -version | head -1

tput setaf 2; echo "Wget version:"; tput sgr0
wget --version | head -1

tput setaf 2; echo "PowerShell version:"; tput sgr0
pwsh --version

tput setaf 2; echo "Azure CLI version:"; tput sgr0
az version | tail -n 5 | head -n 1

tput setaf 2; echo "K8S CLI version:"; tput sgr0
kubectl version --client
