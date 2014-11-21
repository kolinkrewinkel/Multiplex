XcodeUUID=$(defaults read /Applications/Xcode-Beta.app/Contents/Info DVTPlugInCompatibilityUUID)
defaults write /Users/kolin/CommandEdit/CommandEdit/CommandEdit-Info.plist "DVTPlugInCompatibilityUUIDs" -array-add $XcodeUUID
echo "Added $XcodeUUID"
