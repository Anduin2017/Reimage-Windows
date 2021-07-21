rm ~/AppData/Local/Packages/TencentWeChatLimited.forWindows10_sdtnhv12zgd7a/LocalCache/Roaming/Tencent/WeChatAppStore/WeChatAppStore Files/xuefengxue22/Data -rvf
rm ~/AppData/Local/Microsoft/Edge/User\ Data/Default/Cache -rvf
rm ~/AppData/Local/Microsoft/OneDrive/logs -rvf
rm ~/AppData/Local/Microsoft/Windows/WebCache -rvf
rm ~/AppData/Local/Microsoft/Edge/User\ Data/Default/Service\ Worker -rvf
rm ~/AppData/Local/Temp -rvf
rm ~/AppData/Local/NuGet/v3-cache -rvf
rm ~/AppData/Local/Steam/htmlcache -rvf
rm ~/AppData/Local/cache -rvf
rm ~/AppData/Local/GitHubVisualStudio/GraphQLCache/cache -rvf
rm ~/AppData/Local/npm-cache -rvf
rm ~/AppData/Local/NuGet/v3-cache -rvf
rm ~/AppData/Local/OneDrive/cache -rvf
rm ~/AppData/Local/Packages/Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe/LocalState/cache -rvf
rm ~/AppData/Local/Softdeluxe/Free\ Download Manager/cache -rvf
rm ~/AppData/Local/Steam/htmlcache -rvf
rm ~/AppData/Local/Packages/SpotifyAB.SpotifyMusic_zpdnekdrzrea0/LocalCache
rm ~/AppData/Roaming/Microsoft/Teams/Service\ Worker/CacheStorage -rvf
rm ~/.anes -rvf
rm ~/IntelGraphicsProfiles -rvf
rm ~/.templateengine -rvf
rm ~/.omnisharp -rvf
rm ~/Downloads/*
rm ~/Postman -rvf
rm ~/.librarymanager/*
rm /c/_cache/ -rvf
rm /c/CloudBuildCache -rvf
rm /c/ProgramData/Package\ Cache -rvf
rm /c/Intel/ -rvf
rm /c/PerfLogs/* -rvf
rm /c/OneDriveTemp -rvf
rm /c/ProgramData/Microsoft/Windows\ Defender/Definition\ Updates/Backup -rvf

cd /c/
rm '/c/$Windows.~WS' -rvf
rm /c/Windows.Old -rvf
ls -a "/c/" | grep -v ProgramData | grep -v Windows | grep -v orus | grep -v Users | grep -v Program | grep -v Recovery | grep -v .sys | grep -v Settings | grep -v System | grep -v boot | xargs rm -rvf --


find ~/AppData/Local/Packages/TencentWeChatLimited.forWindows10_sdtnhv12zgd7a/LocalCache/Roaming/Tencent/WeChatAppStore -name "CustomEmoV1" -exec bash -c "rm -rvf '{}'" \;
find ~/AppData/Local/Packages/TencentWeChatLimited.forWindows10_sdtnhv12zgd7a/LocalCache/Roaming/Tencent/WeChatAppStore -name "Attachment" -exec bash -c "rm -rvf '{}'" \;
#find /c/ProgramData/Microsoft/VisualStudio/Packages/ -type d ! -name "_*" -exec bash -c "rm -rvf '{}'" \;

find ~/source/repos -name "bin" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name "obj" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name "objd" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name "TestResults" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name ".vs" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name "node_modules" -exec bash -c "rm -rvf '{}'" \;
find ~/source/repos -name "dist" -exec bash -c "rm -rvf '{}'" \;
