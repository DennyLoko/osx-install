#!/bin/sh
set -e

info () {
    context="$1"
    msg="$2"

    echo '\033[1;34m'"[$context] $msg"'\033[0m';
}

ok () {
    context="$1"
    msg="$2"

    echo '\033[1;32m'"[$context] $msg"'\033[0m';
}

warn () {
    context="$1"
    msg="$2"

    echo '\033[1;33m'"[$context] WARNING: $msg"'\033[0m' >&2;
}

die () {
    context="$1"
    msg="$2"

    echo '\033[1;31m'"[$context] ERROR: $msg"'\033[0m' >&2;
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

install_brew_if_not_installed () {
    if ! which -s brew; then
        warn brew "installing brew..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
}


_check_brew_package_installed () {
    brew list --versions $(basename "$1") | fail_if_empty > /dev/null
}

_check_cask_package_installed () {
    brew list --cask --versions $(basename "$1") | fail_if_empty > /dev/null
}

_check_env_is_set () {
    cat ~/.zshrc | grep -i "$1" | fail_if_empty > /dev/null
}

_update_brew() {
    if [ -f ".brew_updated" ]; then
        return  # bail out -- already done
    fi

    trap "{ rm -f .brew_updated; exit 255; }" EXIT
    touch .brew_updated

    info brew "updating to have the latest formulas..."
    brew update && \
        ok brew "packages updated" || \
        die brew "failed to update"
}


brew_me_some () {
    pkg="$1"

    info brew "installing '$pkg'"

    _check_brew_package_installed "$pkg" || \
        (_update_brew && brew install "$pkg") || \
            _check_brew_package_installed "$pkg" || \
                die brew "'$pkg' could not be installed"

    ok brew "'$pkg' installed"
}

cask_me_some () {
    pkg="$1"

    info brew "installing '$pkg'"

    _check_cask_package_installed "$pkg" || \
        (_update_brew && brew install --cask "$pkg") || \
            _check_cask_package_installed "$pkg" || \
                die brew "'$pkg' could not be installed"

    ok brew "'$pkg' installed"
}

goget () {
    pkg="$1"

    info go "installing '$pkg'"

    if ! which -s go; then
        die go "go binary not found"
    else
        go get -u "$pkg" || \
            die go "'$pkg' could not be installed"
    fi

    ok go "'$pkg' installed"
}

npm_me () {
    pkg="$1"

    info npm "installing '$pkg'"

    if ! which -s npm; then
        die npm "npm binary not found"
    else
        npm list -g | grep -qF "$pkg" || \
            npm install -g "$pkg" || \
                die npm "'$pkg' could not be installed"
    fi

    ok npm "'$pkg' installed"
}

git_me () {
    pkg="$1"
    repo="$2"
    dir="$3"

    info git "installing '$pkg'"

    git clone "$repo" "$dir" 2>/dev/null || \
        [ -d "$dir" ] || \
            die git "failed to clone '$pkg'"

    ok git "'$pkg' installed"
}


install_tools () {
    install_brew_if_not_installed

    # Used by brew
    echo ""
    echo "#######################################################"
    echo "# DEPENDENCIES"
    echo "#######################################################"
    brew_me_some git

    echo ""
    echo "#######################################################"
    echo "# INSTALLING BREW PACKAGES"
    echo "#######################################################"
    brew_me_some gcc
    brew_me_some git-crypt
    brew_me_some gnupg
    brew_me_some go
    brew_me_some httpie
    brew_me_some hub
    brew_me_some jq
    # brew_me_some kryptco/tap/kr
    brew_me_some reattach-to-user-namespace
    brew_me_some ssh-copy-id
    brew_me_some tfenv
    brew_me_some tmux
    brew_me_some tree
    brew_me_some vim
    brew_me_some watch
    brew_me_some wget
    brew_me_some xz
    brew_me_some zsh

    echo ""
    echo "#######################################################"
    echo "# INSTALLING GIT PACKAGES"
    echo "#######################################################"
    git_me nodenv https://github.com/nodenv/nodenv.git ~/.nodenv
    git_me nodenv-build https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build

    if [ ! (_check_env_is_set nodenv) ]; then
        echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(nodenv init -)"' >> ~/.zshrc
    fi

    git_me phpenv https://github.com/phpenv/phpenv.git ~/.phpenv
    git_me phpenv-build https://github.com/php-build/php-build ~/.phpenv/plugins/php-build

    if [ ! (_check_env_is_set phpenv) ]; then
        echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(phpenv init -)"' >> ~/.zshrc
    fi

    curl -L https://raw.githubusercontent.com/php-build/php-build/master/install-dependencies.sh | bash
}


install_casks () {
    echo ""
    echo "#######################################################"
    echo "# CASKS"
    echo "#######################################################"
    cask_me_some bitbar
    cask_me_some bittorrent
    cask_me_some charles
    cask_me_some discord
    cask_me_some docker
    cask_me_some expo-xde
    cask_me_some firefox
    cask_me_some flux
    cask_me_some google-chrome
    cask_me_some google-chrome-canary
    cask_me_some google-cloud-sdk
    cask_me_some iterm2
    cask_me_some keybase
    cask_me_some postman
    cask_me_some rar
    cask_me_some slack
    cask_me_some spotify
    cask_me_some stremio
    cask_me_some telegram
    cask_me_some toggl
    cask_me_some tunnelblick
    cask_me_some virtualbox
    cask_me_some visual-studio-code
    cask_me_some vlc
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
    cask_me_some font-inconsolatalgc-nerd-font
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

    goget github.com/variadico/noti/cmd/noti

    # Do not install atom packages, since I'm not using it anymore
    # git clone -q https://github.com/DennyLoko/dotatom.git ~/.atom
    # apm install --packages-file ~/.atom/packages.list

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#    git clone git@github.com:DennyLoko/dotfiles.git ~/dotfiles
#    sh ~/dotfiles/install.sh

    curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
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
