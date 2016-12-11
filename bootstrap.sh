#!/bin/bash -x
BASEPATH=$(cd `dirname $0`; pwd)
cd $BASEPATH
mkdir $HOME/bin
ln -s $HOME/dotfiles/.config            $HOME/
ln -s $HOME/dotfiles/.ctags             $HOME/
ln -s $HOME/dotfiles/.gitignore         $HOME/
ln -s $HOME/dotfiles/.gitconfig         $HOME/
ln -s $HOME/dotfiles/.gitconfig.local   $HOME/
ln -s $HOME/dotfiles/.peco              $HOME/
ln -s $HOME/dotfiles/.tmux.conf         $HOME/
ln -s $HOME/dotfiles/.zshrc             $HOME/
touch ~/.z

## macOS
xcode-select --install
sudo defaults write -g InitialKeyRepeat -int 14
sudo defaults write -g KeyRepeat -int 1

## Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/fonts
brew tap neovim/homebrew-neovim
#brew install ack                          || true
#brew install tree                         || true
#brew install watch                        || true
brew install --disable-etcdir zsh         || true
brew install ag                           || true
brew install ansible                      || true
brew install binutils                     || true
brew install caskroom/cask/brew-cask      || true
brew install cocot                        || true
brew install coreutils                    || true
brew install ctags                        || true
brew install curl                         || true
brew install findutils                    || true
brew install git                          || true
brew install go                           || true
brew install htop                         || true
brew install hub                          || true
brew install hugo                         || true
brew install jq                           || true
brew install mcrypt                       || true
brew install neovim                       || true
brew install nkf                          || true
brew install node                         || true
brew install openssl                      || true
brew install peco                         || true
brew install python3                      || true
brew install rbenv                        || true
brew install reattach-to-user-namespace   || true
ln -s $(which reattach-to-user-namespace) ~/bin/i
brew install tig                          || true
brew install tmux                         || true
brew install vim                          || true
brew install wget                         || true
brew install xz                           || true
brew install zsh                          || true
brew install imagemagick                  || true
brew install mysql                        || true
brew cask install atom                    || true
brew cask install slack                   || true
brew cask install dockertoolbox           || true
brew cask install font-anonymous-pro      || true
brew cask install font-fontawesome        || true
brew cask install font-lobster            || true
brew cask install font-noto-sans-japanese || true
brew cask install font-ricty-diminished   || true
brew cask install google-chrome           || true
brew cask install google-drive            || true
brew cask install google-japanese-ime     || true
brew cask install honer                   || true
brew cask install hoster                  || true
brew cask install iterm2                  || true
brew cask install licecap                 || true
brew cask install mysqlworkbench          || true
brew cask install showyedge               || true
brew cask install skype                   || true
brew cask install sourcetree              || true
brew cask install spectacle               || true
brew cask install the-unarchiver          || true
brew cask install vagrant                 || true
brew cask install virtualbox              || true
brew cask install cmd-eikana              || true
brew cask install gitify                  || true
brew update                               || true
brew cleanup                              || true

#brew install mas @todo
#mas install line
#mas install reeder3
#mas install kindle
#mas install Pixelmeter

## MacApp
#macapp install Google Chrome
#macapp install Spotify
#macapp install Evernote
#macapp install ScanSnap Manager
#macapp install ScanSnap Cloud
#macapp install Franz
#macapp install Xmind
#macapp install alfred

## Node
curl -L git.io/nodebrew | perl - setup
nodebrew install stable
nodebrew use stable

## Go, Ruby, Python, Java
sudo easy_install pip
pip3 install neovim
vim -c "PlugInstall" -c ":q" -c ":q"
go get github.com/motemen/ghq
sudo gem install tmuxinator
sudo gem install bundler
sudo gem update --system
#curl -s api.sdkman.io | bash

brew install homebrew/versions/v8-315
bundle config build.libv8 --with-system-v8
bundle config build.therubyracer --with-v8-dir=/usr/local/opt/v8-315/
curl get.pow.cx | sh
