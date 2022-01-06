alias vi="vi -X"
export EDITOR=vim

export BASH_SILENCE_DEPRECATION_WARNING=1

# Enable colors in bash
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# git prompt
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
export PS1='\[\033[0;32m\]\u\[\033[0m\]:\[\033[1;35m\]\W\[\033[0m\]\[\033[0;34m\]$(__git_ps1 " [%s]")\[\033[0m\]\$ '

# bash autocomplete
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
