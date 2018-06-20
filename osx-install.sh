#!/bin/sh
set -e

ok () {
    echo '\033[1;32m'"$1"'\033[0m';
}

warn () {
    echo '\033[1;33m'"WARNING: $1"'\033[0m' >&2;
}

die () {
    echo '\033[1;31mERROR: '"ERROR: $1"'\033[0m' >&2;
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
        ok "homebrew packages updated" || \
        die "could not update brew"
}


brew_me_some () {
    pkg="$1"
    _check_brew_package_installed "$pkg" || \
        (_update_brew && brew install "$pkg") || \
            _check_brew_package_installed "$pkg" || \
                die "$pkg could not be installed"

    ok "$pkg installed"
}


cask_me_some () {
    pkg="$1"
    brew cask list | grep -qxF "$pkg" || \
        brew cask install "$pkg" || \
            die "cask $pkg could not be installed"

    ok "$pkg installed"
}


goget () {
    pkg="$1"
    if ! which -s go; then
        die "Go not found!"
    else
        go get -u "$pkg"
    fi

    ok "$pkg installed"
}

npm_me () {
    pkg="$1"
    if ! which -s npm; then
        die "npm not found!"
    else
        npm list -g | grep -qF "$pkg" || \
            npm install -g "$pkg" || \
                die "npm package $pkg could not be installed"
    fi

    ok "$pkg installed"
}


install_brew_if_not_installed () {
    if ! which -s brew; then
        warn "Installing brew..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}


install_tools () {
    install_brew_if_not_installed

    # Used by brew
    brew_me_some git

    # Tap some kegs
    echo ""
    echo "#######################################################"
    echo "# KEGS"
    echo "#######################################################"
    brew tap caskroom/versions

    echo ""
    echo "#######################################################"
    echo "# INSTALLING BREW PACKAGES"
    echo "#######################################################"
    brew_me_some gcc
    brew_me_some git-flow
    brew_me_some gnupg
    brew_me_some go
    brew_me_some hub
    brew_me_some jq
    brew_me_some kryptco/tap/kr
    brew_me_some node
    brew_me_some php
    brew_me_some ssh-copy-id
    brew_me_some tmux
    brew_me_some tree
    brew_me_some unrar
    brew_me_some vim
    brew_me_some watch
    brew_me_some wget
    brew_me_some xz
}


install_casks () {
    echo ""
    echo "#######################################################"
    echo "# CASKS"
    echo "#######################################################"
    cask_me_some authy
    cask_me_some bitbar
    cask_me_some bittorrent
    cask_me_some charles
    cask_me_some discord
    cask_me_some docker
    cask_me_some dropbox
    cask_me_some expo-xde
    cask_me_some firefox
    cask_me_some flixtools
    cask_me_some flux
    cask_me_some google-chrome
    cask_me_some google-chrome-canary
    cask_me_some impactor
    cask_me_some iterm2
    cask_me_some keeweb
    cask_me_some keybase
    cask_me_some minikube
    cask_me_some postman
    cask_me_some skype
    cask_me_some slack
    cask_me_some spectacle
    cask_me_some spotify
    cask_me_some stremio
    cask_me_some telegram
    cask_me_some toggl
    cask_me_some tunnelblick
    cask_me_some virtualbox
    cask_me_some visual-studio-code
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
    cask_me_some font-ubuntu-mono-derivative-powerline
}

install_gotools () {
    echo ""
    echo "#######################################################"
    echo "# GO TOOLS"
    echo "#######################################################"
    goget golang.org/x/tools/cmd/goimports
    goget github.com/kardianos/govendor
}

install_misc () {
    echo ""
    echo "#######################################################"
    echo "# MISC"
    echo "#######################################################"
    npm_me diff-so-fancy
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

    # Do not install atom packages, since I'm not using it anymore
    # git clone -q https://github.com/DennyLoko/dotatom.git ~/.atom
    # apm install --packages-file ~/.atom/packages.list
}


main () {
    install_tools
    install_casks
    install_fonts
    install_gotools
    install_misc
    curl -sSL https://raw.githubusercontent.com/DennyLoko/osx-install/master/osx-settings.sh | sh
}

main
