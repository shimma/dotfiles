export LANG=ja_JP.UTF-8
export LEuSCHARSET=utf-8
typeset -U name_of_the_variable
bindkey "^?" backward-delete-char
bindkey -e
setopt auto_list            # 補完候補が複数ある時に、一覧表示する
setopt auto_menu            # 補完キー（Tab,  Ctrl+I) を連打するだけで順に補完候補を自動で補完する
setopt auto_param_keys      # カッコの対応などを自動的に補完する
setopt auto_param_slash     # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt hist_ignore_all_dups # 登録済コマンド行は古い方を削除
setopt hist_ignore_dups
setopt hist_reduce_blanks   # 余分な空白は詰める
setopt list_packed          # 補完候補リストを詰めて表示
setopt list_types           # auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示
setopt magic_equal_subst    # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt noautoremoveslash    # 最後がディレクトリ名で終わっている場合末尾の / を自動的に取り除かない
setopt prompt_subst
setopt share_history        # historyの共有
autoload -U compinit        # 自動保管
compinit -C

autoload colors
colors
RESET="%{${reset_color}%}"
BLUE="%{${fg[blue]}%}"
WHITE="%{${fg[white]}%}"
PROMPT="${RESET}${BLUE}[%C]${RESET}${WHITE}$ ${RESET}"
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

function peco-git-branch-checkout () {
    local selected_branch_name="$(git branch -a | peco | tr -d ' ')"
    case "$selected_branch_name" in
        *-\>* )
            selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*->(.*?)\/(.*)$/\2/;print')";;
        remotes* )
            selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*?remotes\/(.*?)\/(.*)$/\2/;print')";;
    esac
    if [ -n "$selected_branch_name" ]; then
        BUFFER="git checkout ${selected_branch_name} && git pull origin ${selected_branch_name}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-git-branch-checkout
bindkey '^g' peco-git-branch-checkout

function peco-select-ssh() {
    BUFFER="ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v "*"|awk "{print \$2}" | peco --query="$LBUFFER")"
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-ssh
bindkey '^o' repo


# ------------------------------------------------------------
# Common Aliases
# ------------------------------------------------------------
alias ls="ls --color"
alias be='bundle exec' # bundler
alias vm='vagrant ssh'
alias cp='nocorrect cp -irp'
function p () {
    echo $@ | pbcopy
}
alias df="df -h"
alias du="du -h"
alias evs='vim ~/.ssh/config'
alias ga='git add .'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gf='git fetch --prune'
alias gl='git pull origin'
alias gp='git push'
alias gs='git status -sb'
alias gu='git add -u && git commit -am "update" && git push'
alias h='vim /etc/hosts'
alias j='z'
alias la="ls -a"
alias ll="ls -l"
alias pk='pkill -f'
alias w='repo'
alias s='sshpeco'
alias t="tmuxnew"
alias u='up'
alias up='cd ..; ll'
alias ur=root
alias root='cd $(git rev-parse --show-toplevel)'
alias v="vim"
alias X="tmux kill-server"
alias master='git checkout master && git pull origin master'
alias develop='git checkout develop && git pull origin develop'
alias gm='git compare'
alias c='bin/rails console'

tmuxnew() {
    name=$(basename `pwd` | sed 's/\./-/g')
    tmux new -s $name
}
sshpeco () {
    peco_query=$@
    target=$(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v "*"|awk "{print \$2}" | peco --query="$peco_query")
    if [ ! -z $target ]; then
        ssh $target
    fi
}
peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

repo () {
    peco_query=$@
    dir=$(ghq list -p | peco --query="$peco_query")
    if [[ -d $dir && -n $dir ]]; then
        cd $dir
    fi
}
zle -N repo
bindkey '^w' repo

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

import-gcloud() {
# curl https://sdk.cloud.google.com | bash
  source ~/google-cloud-sdk/completion.zsh.inc
  source ~/google-cloud-sdk/path.zsh.inc
}

# ------------------------------------------------------------
# Custom Aliases
# ------------------------------------------------------------
case "${OSTYPE}" in
darwin*)
    export EDITOR=/usr/local/bin/nvim
    export PATH=:~/.gvm/scripts:~/.rbenv/bin:~/.rbenv/shims:/usr/local/php5/bin:~/.composer/vendor/bin:~/dotfiles/bin:/usr/local/opt/coreutils/libexec/gnubin:~/Applications/Vagrant/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:~/bin:$GOPATH/bin:$PATH
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    export RBENV_SHELL=zsh
    export GOROOT_BOOTSTRAP=$GOROOT

    export GVM_ROOT=~/.gvm
    source $GVM_ROOT/scripts/gvm-default

    alias cp="nocorrect gcp -i" # required: brew install coreutils
    alias f='open .'
    alias git=hub # hub command - eval "$(hub alias -s)"
    alias tailf='tail -f'
    alias tma='env TERM=screen-256color-bce tmux attach'
    alias tmux="env TERM=screen-256color-bce tmux" #keep vim colorscheme in tmux mode
    alias vim='nvim'
    alias sourcetree='open -a SourceTree'
    alias agg='ag -ig'
    alias get='ghq get -p'
    cdf() {
      target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
      if [ "$target" != "" ]; then
        cd "$target"; pwd
      else
        echo 'No Finder window found' >&2
      fi
    }

    ## Ruby
    #source '/usr/local/Cellar/rbenv/1.0.0/libexec/../completions/rbenv.zsh'
    #command rbenv rehash 2>/dev/null
    rbenv() {
      local command
      command="$1"
      if [ "$#" -gt 0 ]; then
        shift
      fi

      case "$command" in
      rehash|shell)
        eval "$(rbenv "sh-$command" "$@")";;
      *)
        command rbenv "$command" "$@";;
      esac
    }
;;
esac

# ------------------------------------------------------------
# Z https://github.com/rupa/z
# ------------------------------------------------------------
# . ~/dotfiles/bin/z.sh #Loading Z
[ -d "${_Z_DATA:-$HOME/.z}" ] && {
    echo "ERROR: z.sh's datafile (${_Z_DATA:-$HOME/.z}) is a directory."
}

_z() {

    local datafile="${_Z_DATA:-$HOME/.z}"

    # bail if we don't own ~/.z and $_Z_OWNER not set
    [ -z "$_Z_OWNER" -a -f "$datafile" -a ! -O "$datafile" ] && return

    # add entries
    if [ "$1" = "--add" ]; then
        shift

        # $HOME isn't worth matching
        [ "$*" = "$HOME" ] && return

        # don't track excluded directory trees
        local exclude
        for exclude in "${_Z_EXCLUDE_DIRS[@]}"; do
            case "$*" in "$exclude*") return;; esac
        done

        # maintain the data file
        local tempfile="$datafile.$RANDOM"
        while read line; do
            # only count directories
            [ -d "${line%%\|*}" ] && echo $line
        done < "$datafile" | awk -v path="$*" -v now="$(date +%s)" -F"|" '
            BEGIN {
                rank[path] = 1
                time[path] = now
            }
            $2 >= 1 {
                # drop ranks below 1
                if( $1 == path ) {
                    rank[$1] = $2 + 1
                    time[$1] = now
                } else {
                    rank[$1] = $2
                    time[$1] = $3
                }
                count += $2
            }
            END {
                if( count > 9000 ) {
                    # aging
                    for( x in rank ) print x "|" 0.99*rank[x] "|" time[x]
                } else for( x in rank ) print x "|" rank[x] "|" time[x]
            }
        ' 2>/dev/null >| "$tempfile"
        # do our best to avoid clobbering the datafile in a race condition
        if [ $? -ne 0 -a -f "$datafile" ]; then
            env rm -f "$tempfile"
        else
            [ "$_Z_OWNER" ] && chown $_Z_OWNER:$(id -ng $_Z_OWNER) "$tempfile"
            env mv -f "$tempfile" "$datafile" || env rm -f "$tempfile"
        fi

    # tab completion
    elif [ "$1" = "--complete" -a -s "$datafile" ]; then
        while read line; do
            [ -d "${line%%\|*}" ] && echo $line
        done < "$datafile" | awk -v q="$2" -F"|" '
            BEGIN {
                if( q == tolower(q) ) imatch = 1
                q = substr(q, 3)
                gsub(" ", ".*", q)
            }
            {
                if( imatch ) {
                    if( tolower($1) ~ tolower(q) ) print $1
                } else if( $1 ~ q ) print $1
            }
        ' 2>/dev/null

    else
        # list/go
        while [ "$1" ]; do case "$1" in
            --) while [ "$1" ]; do shift; local fnd="$fnd${fnd:+ }$1";done;;
            -*) local opt=${1:1}; while [ "$opt" ]; do case ${opt:0:1} in
                    c) local fnd="^$PWD $fnd";;
                    h) echo "${_Z_CMD:-z} [-chlrtx] args" >&2; return;;
                    x) sed -i -e "\:^${PWD}|.*:d" "$datafile";;
                    l) local list=1;;
                    r) local typ="rank";;
                    t) local typ="recent";;
                esac; opt=${opt:1}; done;;
             *) local fnd="$fnd${fnd:+ }$1";;
        esac; local last=$1; [ "$#" -gt 0 ] && shift; done
        [ "$fnd" -a "$fnd" != "^$PWD " ] || local list=1

        # if we hit enter on a completion just go there
        case "$last" in
            # completions will always start with /
            /*) [ -z "$list" -a -d "$last" ] && cd "$last" && return;;
        esac

        # no file yet
        [ -f "$datafile" ] || return

        local cd
        cd="$(while read line; do
            [ -d "${line%%\|*}" ] && echo $line
        done < "$datafile" | awk -v t="$(date +%s)" -v list="$list" -v typ="$typ" -v q="$fnd" -F"|" '
            function frecent(rank, time) {
                # relate frequency and time
                dx = t - time
                if( dx < 3600 ) return rank * 4
                if( dx < 86400 ) return rank * 2
                if( dx < 604800 ) return rank / 2
                return rank / 4
            }
            function output(files, out, common) {
                # list or return the desired directory
                if( list ) {
                    cmd = "sort -n >&2"
                    for( x in files ) {
                        if( files[x] ) printf "%-10s %s\n", files[x], x | cmd
                    }
                    if( common ) {
                        printf "%-10s %s\n", "common:", common > "/dev/stderr"
                    }
                } else {
                    if( common ) out = common
                    print out
                }
            }
            function common(matches) {
                # find the common root of a list of matches, if it exists
                for( x in matches ) {
                    if( matches[x] && (!short || length(x) < length(short)) ) {
                        short = x
                    }
                }
                if( short == "/" ) return
                # use a copy to escape special characters, as we want to return
                # the original. yeah, this escaping is awful.
                clean_short = short
                gsub(/[\(\)\[\]\|]/, "\\\\&", clean_short)
                for( x in matches ) if( matches[x] && x !~ clean_short ) return
                return short
            }
            BEGIN {
                gsub(" ", ".*", q)
                hi_rank = ihi_rank = -9999999999
            }
            {
                if( typ == "rank" ) {
                    rank = $2
                } else if( typ == "recent" ) {
                    rank = $3 - t
                } else rank = frecent($2, $3)
                if( $1 ~ q ) {
                    matches[$1] = rank
                } else if( tolower($1) ~ tolower(q) ) imatches[$1] = rank
                if( matches[$1] && matches[$1] > hi_rank ) {
                    best_match = $1
                    hi_rank = matches[$1]
                } else if( imatches[$1] && imatches[$1] > ihi_rank ) {
                    ibest_match = $1
                    ihi_rank = imatches[$1]
                }
            }
            END {
                # prefer case sensitive
                if( best_match ) {
                    output(matches, best_match, common(matches))
                } else if( ibest_match ) {
                    output(imatches, ibest_match, common(imatches))
                }
            }
        ')"
        [ $? -gt 0 ] && return
        [ "$cd" ] && cd "$cd"
    fi
}

alias ${_Z_CMD:-z}='_z 2>&1'

[ "$_Z_NO_RESOLVE_SYMLINKS" ] || _Z_RESOLVE_SYMLINKS="-P"

if compctl >/dev/null 2>&1; then
    # zsh
    [ "$_Z_NO_PROMPT_COMMAND" ] || {
        # populate directory list, avoid clobbering any other precmds.
        if [ "$_Z_NO_RESOLVE_SYMLINKS" ]; then
            _z_precmd() {
                _z --add "${PWD:a}"
            }
        else
            _z_precmd() {
                _z --add "${PWD:A}"
            }
        fi
        [[ -n "${precmd_functions[(r)_z_precmd]}" ]] || {
            precmd_functions[$(($#precmd_functions+1))]=_z_precmd
        }
    }
    _z_zsh_tab_completion() {
        # tab completion
        local compl
        read -l compl
        reply=(${(f)"$(_z --complete "$compl")"})
    }
    compctl -U -K _z_zsh_tab_completion _z
elif complete >/dev/null 2>&1; then
    # bash
    # tab completion
    complete -o filenames -C '_z --complete "$COMP_LINE"' ${_Z_CMD:-z}
    [ "$_Z_NO_PROMPT_COMMAND" ] || {
        # populate directory list. avoid clobbering other PROMPT_COMMANDs.
        grep "_z --add" <<< "$PROMPT_COMMAND" >/dev/null || {
            PROMPT_COMMAND="$PROMPT_COMMAND"$'\n''_z --add "$(command pwd '$_Z_RESOLVE_SYMLINKS' 2>/dev/null)" 2>/dev/null;'
        }
    }
fi

# # Gcloud
# if [ -f '~/google-cloud-sdk/path.zsh.inc' ]; then source ~/google-cloud-sdk/path.zsh.inc; fi
# if [ -f '~/google-cloud-sdk/completion.zsh.inc' ]; then source ~/google-cloud-sdk/completion.zsh.inc; fi
#
# alias xpath="xmllint --html --xpath 2>/dev/null"

#if (which zprof > /dev/null) ;then
#  zprof | less
#fi

[[ -s "~/.gvm/scripts/gvm" ]] && source "~/.gvm/scripts/gvm"
