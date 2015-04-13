XcodeUUID=$(defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID)
defaults write ./Multiplex/Multiplex-Info.plist "DVTPlugInCompatibilityUUIDs" -array-add $XcodeUUID
echo "Added $XcodeUUID"
