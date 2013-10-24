#!/bin/bash
#
# Auto setup tools @rskz
#
#########################################

main() {

    #Definition
    readonly BASEPATH=$(cd `dirname $0`; pwd)
    readonly CMDNAME=$(basename $0)

    ## 1. Create symbolic links
    DOT_FILES=( .zsh .zshrc .zshrc.alias .ctags .gitignore .vimrc .vrapperrc .tmux.conf .dir_colors .vim .gvimrc )
    for file in ${DOT_FILES[@]}
    do
        ln -s $HOME/dotfiles/$file $HOME/$file
    done

    ## 2. Create local configure files
    LOCAL_FILES=( .zshrc.alias.local .tmux.conf.local )
    for file in ${LOCAL_FILES[@]}
    do
        touch $HOME/$file
    done

    ## 3. Load submodules
    git submodule update --init

    ## 4. Install vim plugins
    vim +NeoBundleInstall

    ## 5. Copy gitdiff wrapper
    sudo cp -a $HOME/dotfiles/bin/git_diff_wrapper /usr/local/bin/

    ## 6. Finished messages
    echo "Finished! Install following packages (brew or epel)"
    echo "brew install vim tmux tig reattach-to-user-namespace"
}

main "$@"



