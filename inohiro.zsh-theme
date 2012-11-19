PROMPT=$'%{$fg[green]%}%n@%m %{$fg[blue]%}%D{[%I:%M:%S]} %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} %{$fg[red]%}[`~/.rvm/bin/rvm-prompt`]%{$reset_color%} $(git_prompt_info) \
%{$fg[blue]%}->%{$fg[blue]%} %(!.#.$)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# if expr $HOST : "inohiro-ng-mac.local" > /dev/null; then
#   PROMPT="%{$fg[blue]%}%n@%m %{$fg[yellow]%}[%c]%{$fg[blue]%} %(!.#.$) %{$reset_color%}"
# else
#   PROMPT="%{$fg[blue]%}%n%{$fg[yellow]%}@%m %{$fg[yellow]%}[%c]%{$fg[blue]%} %(!.#.$) %{$reset_color%}"
# fi

### my settings ###

## basic

export LANG=ja_JP.UTF-8
export EDITOR="emacs"

## aliases

alias zshconfig="emacs ~/.zshrc"
alias zshreload="source ~/.zshrc"

alias gst="git status -sb"
alias lns="ln -s"

if [[ "${OSTYPE}" = darwin* ]] ; then
   alias mysqld_start="sudo /Library/StartupItems/MySQLCOM/MySQLCOM start"
   alias mysqld_stop="sudo /Library/StartupItems/MySQLCOM/MySQLCOM stop"
   alias mysqld_restart="sudo /Library/StartupItems/MySQLCOM/MySQLCOM restart"

   alias tomcat_start="sudo /Library/Tomcat/bin/startup.sh"
   alias tomcat_stop="sudo /Library/Tomcat/bin/shutdown.sh"
   alias tomcat_restart="tomcat_stop && tomcat_start"

   alias tailf="tail -f"
   alias here="open ."
fi

if [[ "${OSTYPE}" = linux* ]] ; then
   alias mem_free="sudo sysctl -w vm.drop_caches=3"
   alias aptitude="nocorrect aptitude"
   alias mysql="nocorrect mysql"
   alias sudo="nocorrect sudo"
fi

## Search

bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

## history

HISTFILE=~/.zsh_history           # historyファイル
HISTSIZE=10000                    # ファイルサイズ
SAVEHIST=10000                    # saveする量
setopt hist_ignore_dups           # 重複を記録しない
setopt hist_reduce_blanks         # スペース排除
# setopt share_history              # 履歴ファイルを共有
setopt EXTENDED_HISTORY           # zshの開始終了を記録
