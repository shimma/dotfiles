# ------------------------------------------------------------
# Env / PATH
# ------------------------------------------------------------
# compinit より前に読む（Homebrew の補完を fpath に追加するため）
eval "$(/opt/homebrew/bin/brew shellenv)"

export LANG=ja_JP.UTF-8
export LESSCHARSET=utf-8
export EDITOR=nvim
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export VOLTA_HOME="$HOME/.volta"

# 重複を除去（tmux などで zsh を入れ子にしても PATH が膨らまない）
typeset -U path PATH
path=(
  ~/.local/bin
  $VOLTA_HOME/bin
  $path
  /Applications/Orca.app/Contents/Resources/bin # Orca CLI
)

# ------------------------------------------------------------
# Options
# ------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt list_packed
setopt magic_equal_subst
setopt noautoremoveslash
setopt prompt_subst

bindkey -e

autoload -Uz compinit
compinit -C

PROMPT='%F{blue}[%C]%f$ '

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
# git
alias cb='git checkout -b'
alias ga='git add .'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gf='git fetch --prune'
alias gl='git pull origin'
alias gm='git compare'
alias gp='git push'
alias gs='git status -sb'
alias gt='git checkout -b'
alias gu='git add -u && git commit -am "update" && git push'
alias get='ghq get'
alias m='main'
alias root='cd $(git rev-parse --show-toplevel)'
alias ur=root

# editor / files
alias v='vim'
alias vim='nvim'
alias f='open .'
alias evs='vim ~/.ssh/config'
alias evz='vim ~/.zshrc'

# shell
alias ls='ls --color'
alias la='ls -a'
alias ll='ls -l'
alias up='cd ..; ll'
alias u='up'
alias df='df -h'
alias du='du -h'
alias diff='colordiff'
alias python='python3'
alias tma='tmux attach'

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------
# main に切り替えて pull
function main() {
  git checkout main && git pull origin main
}

# 最前面の Finder ウィンドウのディレクトリへ cd
function cdf() {
  local target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
  if [[ -n "$target" ]]; then
    cd "$target" && pwd
  else
    echo 'No Finder window found' >&2
  fi
}

function p() {
  echo "$@" | pbcopy
}

# ------------------------------------------------------------
# fzf
# ------------------------------------------------------------
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --select-1 --bind=ctrl-k:kill-line --no-sort'

# 公式のシェル統合: ^R 履歴 / ^T ファイル / Alt-C cd
source <(fzf --zsh)

# ghq 管理のリポジトリへ cd
function ghq-fzf() {
  local root=$(ghq root)
  local selected_dir=$(ghq list | fzf --sort --query="$LBUFFER" \
    --preview "tree -C -L 1 $root/{}; echo; head -40 $root/{}/README.md 2>/dev/null")

  if [[ -n "$selected_dir" ]]; then
    BUFFER="cd ${root}/${selected_dir}"
    zle accept-line
  fi

  zle reset-prompt
}

# ブランチを選んで checkout & pull
function fbr() {
  local branch
  git fetch --prune
  branch=$(git branch --all | grep -v HEAD | fzf --tmux center,80% +m) &&
  branch=$(echo "$branch" | sed -e 's/.* //' -e 's#remotes/[^/]*/##') &&
  git checkout "$branch" && git pull origin "$branch"
  zle accept-line
}

zle -N fbr
zle -N ghq-fzf
bindkey '^]' ghq-fzf
bindkey '^\' ghq-fzf
bindkey '^g' fbr
