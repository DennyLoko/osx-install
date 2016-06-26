#!/bin/sh
set -e

echo ""
echo "#######################################################"
echo "# SETTINGS"
echo "#######################################################"

# Finder
defaults write com.apple.finder AppleShowAllExtensions -boolean yes
defaults write com.apple.finder PathBarRootAtHome -bool yes
defaults write com.apple.finder _FXShowPosixPathInTitle -bool yes

# Dock
defaults write com.apple.dock autohide -boolean yes
defaults write com.apple.dock magnification -boolean yes
defaults write com.apple.dock largesize 70

# Make dock appear faster
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock expose-animation-duration -float 0.15

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# Bottom left screen corner
defaults write com.apple.dock wvous-br-corner -int 11
defaults write com.apple.dock wvous-br-modifier -int 0

killall Finder
killall Dock
killall SystemUIServer
