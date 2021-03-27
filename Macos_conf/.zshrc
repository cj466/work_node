ZSH_DISABLE_COMPFIX=true
#export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/sunhongfan/.oh-my-zsh"
export LANG=en_US.UTF-8


ZSH_THEME="robbyrussell"
ZSH_THEME="myys"

plugins=(
	git
)

source $ZSH/oh-my-zsh.sh

# zplug configruation
if [[ ! -d "${ZPLUG_HOME}" ]]; then
  if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
    # If we can't get zplug, it'll be a very sobering shell experience. To at
    # least complete the sourcing of this file, we'll define an always-false
    # returning zplug function.
    if [[ $? != 0 ]]; then
      function zplug() {
        return 1
      }
    fi
  fi
  export ZPLUG_HOME=~/.zplug
fi
if [[ -d "${ZPLUG_HOME}" ]]; then
  source "${ZPLUG_HOME}/init.zsh"
fi
zplug 'plugins/git', from:oh-my-zsh, if:'which git'
zplug "plugins/vi-mode", from:oh-my-zsh
zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions', defer:2
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zsh-users/zsh-syntax-highlighting', defer:2

if ! zplug check; then
  zplug install
fi

zplug load

### alias 

alias stopsleep="sudo pmset -b sleep 0; sudo pmset -b disablesleep 1"
alias startsleep="sudo pmset -b sleep 5; sudo pmset -b disablesleep 0"
alias sub='open -a /Applications/Sublime\ Text.app'
alias tl="tmux list-sessions"
alias tkss="tmux kill-session -t"
alias ta="tmux attach -t"
alias ts="tmux new-session -s"


### 终端代理

function proxy_off(){
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo -e "已关闭代理"
}
function proxy_on() {
    export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
    echo -e "已开启代理"
}

##########fzf_config 

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --follow --hidden --exclude .git '
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 40% --reverse --border"



#------------Pure Themes-------------
# https://github.com/sindresorhus/pure
# ------------------------------------
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
style="%D{%L:%M:%S} $PROMPT"
PROMPT=$style

