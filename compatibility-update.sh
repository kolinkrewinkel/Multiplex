XcodeUUID=$(defaults read /Applications/Xcode-beta.app/Contents/Info DVTPlugInCompatibilityUUID)
defaults write /Users/kolin/Catalyst/Catalyst/Catalyst-Info.plist "DVTPlugInCompatibilityUUIDs" -array-add $XcodeUUID
echo "Added $XcodeUUID"
