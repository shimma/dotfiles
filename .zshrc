export LANG=ja_JP.UTF-8
export LEuSCHARSET=utf-8
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
autoload -U compinit
autoload colors
compinit -C
colors
bindkey "^?" backward-delete-char
bindkey -e
typeset -U name_of_the_variable
BLUE="%{${fg[blue]}%}"
RESET="%{${reset_color}%}"
WHITE="%{${fg[white]}%}"
PROMPT="${RESET}${BLUE}[%C]${RESET}${WHITE}$ ${RESET}"

setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt list_packed
setopt list_types
setopt magic_equal_subst
setopt noautoremoveslash
setopt prompt_subst
setopt share_history
alias agg='ag -ig'
alias a='git add . && git commit -m "update"'
alias be='bundle exec' # bundler
alias c='code .'
alias df="df -h"
alias du="du -h"
alias evs='vim ~/.ssh/config'
alias evz='vim ~/.zshrc'
alias f='open .'
alias ga='git add .'
alias gb='git branch'
alias gc='git commit'
alias gt='git checkout -b'
alias gd='git diff'
alias get='ghq get'
alias gf='git fetch --prune'
alias git=hub # hub command - eval "$(hub alias -s)"
alias gl='git pull origin'
alias gm='git compare'
alias gp='git push'
alias gs='git status -sb'
alias gu='git add -u && git commit -am "update" && git push'
alias h='vim /etc/hosts'
alias la="ls -a"
alias ll="ls -l"
alias ls="ls --color"
alias master='git checkout main && git pull origin main || git checkout master && git pull origin master'
alias m='master'
alias pk='pkill -f'
alias root='cd $(git rev-parse --show-toplevel)'
alias t="tmuxnew"
alias tailf='tail -f'
alias tma='env TERM=screen-256color-bce tmux attach'
alias tmux="env TERM=screen-256color-bce tmux" #keep vim colorscheme in tmux mode
alias u='up'
alias up='cd ..; ll'
alias ur=root
alias v="vim"
alias vim='nvim'
alias d="docker"
alias dps="docker ps"
alias dclean="docker system prune -a"
alias dkill="docker ps -q | xargs docker stop | xargs docker rm"
alias cb="git checkout -b"
alias docker-clean-all="docker container prune -f && docker image prune -af"
alias python="python3"
alias diff='colordiff'
alias intel="env /usr/bin/arch -x86_64 /bin/zsh --login"
alias arm="env /usr/bin/arch -arm64 /bin/zsh --login"


# ------------------------------------------------------------
# tmux
# ------------------------------------------------------------
function tmuxnew() {
    name=$(basename `pwd` | sed 's/\./-/g')
    tmux new -s $name
}

# ------------------------------------------------------------
# fzf
# ------------------------------------------------------------
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --select-1 --bind=ctrl-k:kill-line --no-sort'

# 公式のシェル統合: ^R 履歴 / ^T ファイル / Alt-C cd
source <(fzf --zsh)

function ssh-fzf () {
  local selected_host=$(grep "Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf --query "$LBUFFER")

  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle reset-prompt
}

function ghq-fzf() {
  local root=$(ghq root)
  local selected_dir=$(ghq list | fzf --sort --query="$LBUFFER" \
    --preview "tree -C -L 1 $root/{}; echo; head -40 $root/{}/README.md 2>/dev/null")

  if [ -n "$selected_dir" ]; then
    BUFFER="cd $(ghq root)/${selected_dir}"
    zle accept-line
  fi

  zle reset-prompt
}

function fbr() {
  local branches branch
  git fetch --prune
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf --tmux center,80% +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##") && git pull origin $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  zle accept-line
}

function open-github() {
    git compare || git browse
    zle reset-prompt
}

bindkey '^]' ghq-fzf
bindkey '^\' ghq-fzf
#bindkey '^j' fzf-z-search
bindkey '^g' fbr
zle -N fbr
zle -N ghq-fzf
zle -N ssh-fzf
zle -N open-github

# ------------------------------------------------------------
# Gcloud
# ------------------------------------------------------------
function import-gcloud() {
    # curl https://sdk.cloud.google.com | bash
    source ~/google-cloud-sdk/completion.zsh.inc
    source ~/google-cloud-sdk/path.zsh.inc
}

# ------------------------------------------------------------
# Exports
# ------------------------------------------------------------
export GOPATH=~/go
export PATH=:~/.local/bin/:~/.rbenv/bin:~/.rbenv/shims:/opt/homebrew/opt/mysql-client/bin:/opt/homebrew/bin:~/google-cloud-sdk/platform/google_appengine:~/.gvm/scripts:~/dotfiles/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:~/bin:$GOPATH/bin:~/.bun/bin:$PATH

export HOMEBREW_PREFIX=/opt/homebrew

export EDITOR=/usr/local/bin/nvim
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
function cdf() {
    target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
        if [ "$target" != "" ]; then
            cd "$target"; pwd
        else
            echo 'No Finder window found' >&2
        fi
    }

function p() {
    echo $@ | pbcopy
}

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
