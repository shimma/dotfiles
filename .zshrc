export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
autoload -U compinit
autoload colors
compinit -C
colors
bindkey -e
BLUE="%{${fg[blue]}%}"
RESET="%{${reset_color}%}"
WHITE="%{${fg[white]}%}"
PROMPT="${RESET}${BLUE}[%C]${RESET}${WHITE}$ ${RESET}"

setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt list_packed
setopt magic_equal_subst
setopt noautoremoveslash
setopt prompt_subst
setopt share_history
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
alias gl='git pull origin'
alias gm='git compare'
alias gp='git push'
alias gs='git status -sb'
alias gu='git add -u && git commit -am "update" && git push'
alias h='vim /etc/hosts'
alias la="ls -a"
alias ll="ls -l"
alias ls="ls --color"
alias m='master'
alias pk='pkill -f'
alias root='cd $(git rev-parse --show-toplevel)'
alias t="tmuxnew"
alias tailf='tail -f'
alias tma='tmux attach'
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
# git
# ------------------------------------------------------------
# デフォルトブランチ（main / master）に切り替えて pull
function master() {
  if git show-ref --verify --quiet refs/heads/main; then
    git checkout main && git pull origin main
  else
    git checkout master && git pull origin master
  fi
}


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

zle -N fbr
zle -N ghq-fzf
bindkey '^]' ghq-fzf
bindkey '^\' ghq-fzf
bindkey '^g' fbr

# ------------------------------------------------------------
# Exports
# ------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# 重複を除去（tmux などで zsh を入れ子にしても PATH が膨らまない）
typeset -U path PATH
path=(
  ~/.local/bin
  ~/dotfiles/bin
  ~/bin
  $path
)

export EDITOR=nvim
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

# Orca CLI
export PATH="$PATH:/Applications/Orca.app/Contents/Resources/bin"
