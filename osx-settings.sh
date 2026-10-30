#!/bin/sh
set -e

echo ""
echo "#######################################################"
echo "# SETTINGS"
echo "#######################################################"

# Appearance
defaults write -g AppleInterfaceStyle -string Dark

# Finder
defaults write com.apple.finder AppleShowAllExtensions -boolean yes
defaults write com.apple.finder PathBarRootAtHome -bool yes
defaults write com.apple.finder _FXShowPosixPathInTitle -bool yes
defaults write com.apple.finder ShowPathbar -bool yes
defaults write com.apple.finder FXPreferredViewStyle -string clmv
# New Finder windows open in Documents
defaults write com.apple.finder NewWindowTarget -string PfDo

# Dock
defaults write com.apple.dock autohide -boolean yes
defaults write com.apple.dock magnification -boolean yes
defaults write com.apple.dock tilesize -int 29
defaults write com.apple.dock largesize -int 55
defaults write com.apple.dock show-recents -bool no

# Make dock appear faster
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock expose-animation-duration -float 0.15

# Dock items: rebuilt from scratch, in order, so running again gives the same
# Dock. Override with DOCK_APPS (comma-separated .app paths) and DOCK_FOLDERS
# (comma-separated folders, shown as a fan sorted by date added).
# Needs dockutil (installed by osx-install.sh); skipped without it.
DOCK_APPS="${DOCK_APPS:-/System/Applications/Apps.app,/Applications/Spark Desktop.app,/Applications/Slack.app,/Applications/Google Chrome.app,/Applications/Warp.app,/System/Applications/System Settings.app}"
DOCK_FOLDERS="${DOCK_FOLDERS:-$HOME/Downloads}"

if command -v dockutil >/dev/null 2>&1; then
    dockutil --remove all --no-restart >/dev/null

    old_ifs="$IFS"; IFS=,
    for app in $DOCK_APPS; do
        app=$(printf '%s' "$app" | sed 's/^ *//; s/ *$//')
        [ -z "$app" ] && continue
        if [ -d "$app" ]; then
            dockutil --add "$app" --no-restart >/dev/null
        else
            echo "Dock: $app not found, skipping" >&2
        fi
    done
    for folder in $DOCK_FOLDERS; do
        folder=$(printf '%s' "$folder" | sed 's/^ *//; s/ *$//')
        [ -d "$folder" ] && dockutil --add "$folder" --view fan --display stack --sort dateadded --no-restart >/dev/null
    done
    IFS="$old_ifs"
else
    echo "dockutil not found, skipping the Dock items (brew install dockutil)" >&2
fi

# Desktop & windows: no click-on-wallpaper to reveal the desktop, no margins
# between tiled windows, hide desktop icons and widgets
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool no
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool no
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool yes
defaults write com.apple.WindowManager StandardHideWidgets -bool yes

# Hot corners
# Possible values:
#  0: no-op
#  1: disabled
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
# 10: Put display to sleep
# 11: Launchpad (Apps on macOS 26)
# 12: Notification Center
# 13: Lock screen
# 14: Quick Note

# Bottom right screen corner
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-br-modifier -int 0

# Trackpad: tap to click (built-in and Bluetooth) and tracking speed
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool yes
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool yes
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.trackpad.scaling -float 1.5

# Keyboard: faster key repeat, no autocorrect/auto-capitalization/double-space period
defaults write -g KeyRepeat -int 5
defaults write -g InitialKeyRepeat -int 25
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool no
defaults write -g NSAutomaticCapitalizationEnabled -bool no
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool no

# Show battery percentage
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool yes

# Screen saver after 3h (the display sleeps before that)
defaults -currentHost write com.apple.screensaver idleTime -int 10800

# Display sleep: 20 min on battery, 2h on power adapter. The Mac itself
# never sleeps on the power adapter.
sudo pmset -b displaysleep 20 sleep 1
sudo pmset -c displaysleep 120 sleep 0

killall Finder
killall Dock
killall SystemUIServer
killall ControlCenter

echo "Trackpad and keyboard changes take effect after logging out and back in."
