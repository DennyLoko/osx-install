#!/bin/sh
set -e

warn () {
    echo "WARNING: $1" >&2
}


die () {
    echo "FATAL: $1" >&2
    exit 2
}


fail_if_empty () {
    empty=1
    while read line; do
        echo "$line"
        empty=0
    done
    test $empty -eq 0
}


_check_brew_package_installed () {
    brew list --versions $(basename "$1") | fail_if_empty > /dev/null
}


_update_brew() {
    if [ -f ".brew_updated" ]; then
        return  # bail out -- already done
    fi

    trap "{ rm -f .brew_updated; exit 255; }" EXIT
    touch .brew_updated

    echo "Updating brew to have the latest packages... hang in there..."
    brew update && \
        echo "homebrew packages updated" || \
        die "could not update brew"
}


brew_me_some () {
    pkg="$1"
    _check_brew_package_installed "$pkg" || \
        (_update_brew && brew install "$pkg") || \
        die "$pkg could not be installed"

    echo "$pkg installed"
}


cask_me_some () {
    pkg="$1"
    brew cask list | grep -qxF "$pkg" || \
        brew cask install "$@" || \
        die "cask $pkg could not be installed"
    echo "$@ is already installed."
}


check_brew_is_installed () {
    if ! which -s brew; then
        echo "We rely on the Brew installer for the Mac OS X platform."
        echo "Please install Brew by following instructions here:"
        echo "    http://brew.sh/#install"
        echo ""
        exit 2
    fi
}


install_tools () {
    check_brew_is_installed

    # Used by brew
    brew_me_some git

    # Tap some kegs
    echo ""
    echo "#######################################################"
    echo "# KEGS"
    echo "#######################################################"
    brew tap homebrew/versions
    brew tap homebrew/science
    brew tap caskroom/versions

    echo ""
    echo "#######################################################"
    echo "# INSTALLING BREW PACKAGES"
    echo "#######################################################"
    brew_me_some gcc
    brew_me_some gnupg
    brew_me_some graphviz
    brew_me_some hub
    brew_me_some jq
    brew_me_some ssh-copy-id
    brew_me_some tree
    brew_me_some unrar
    brew_me_some vim
    brew_me_some watch
    brew_me_some wget
}


install_casks () {
    echo ""
    echo "#######################################################"
    echo "# CASKS"
    echo "#######################################################"
    brew_me_some caskroom/cask/brew-cask

    cask_me_some atom
    cask_me_some docker
    cask_me_some dropbox
    cask_me_some firefox
    cask_me_some flixtools
    cask_me_some flux
    cask_me_some google-chrome
    cask_me_some google-chrome-canary
    cask_me_some iterm2
    cask_me_some mailplane
    cask_me_some messenger
    cask_me_some mysqlworkbench
    cask_me_some skype
    cask_me_some slack
    cask_me_some spectacle
    cask_me_some spotify
    cask_me_some telegram
    cask_me_some toggldesktop
    cask_me_some tunnelblick
    cask_me_some utorrent
    cask_me_some virtualbox
    cask_me_some vlc
    cask_me_some whatsapp
}


install_fonts () {
    echo ""
    echo "#######################################################"
    echo "# FONTS"
    echo "#######################################################"
    brew tap caskroom/fonts

    # The fonts
    cask_me_some font-anonymous-pro
    cask_me_some font-hack
    cask_me_some font-inconsolata
    cask_me_some font-pt-mono
    cask_me_some font-roboto
    cask_me_some font-source-code-pro-for-powerline
    cask_me_some font-ubuntu-mono-powerline
}


main () {
    install_tools
    install_casks
    install_fonts
    curl -sSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-settings.sh | sh
}

main
