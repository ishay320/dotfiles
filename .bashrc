# /etc/bash.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output. So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell. There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

# If not running interactively, don't do anything!
[[ $- != *i* ]] && return

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.
shopt -s histappend
# Ignore double commands in history
export HISTCONTROL=ignoreboth:erasedups
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

case ${TERM} in
xterm* | rxvt* | Eterm | aterm | kterm | gnome*)
	PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
	;;
screen)
	PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND; }'printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
	;;
esac

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS. Try to use the external file
# first to take advantage of user additions. Use internal bash
# globbing instead of external grep binary.

# sanitize TERM:
safe_term=${TERM//[^[:alnum:]]/?}
match_lhs=""

[[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs} ]] &&
	type -P dircolors >/dev/null &&
	match_lhs=$(dircolors --print-database)

if [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* || ($TERM == xterm-color || $TERM == *-256color || $TERM == "xterm-ghostty") ]]; then

	# we have colors :-)

	# Enable colors for ls, etc. Prefer ~/.dir_colors
	if type -P dircolors >/dev/null; then
		if [[ -f ~/.dir_colors ]]; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]]; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	# prints the branch of the path if repo exists
	__parse_git_branch() {
		local r=$?
		[[ $(git rev-parse --is-inside-work-tree 2>/dev/null) ]] && git symbolic-ref HEAD 2>/dev/null | sed 's#\(.*\)\/\([^\/]*\)$#(\2)#'
		return $r
	}

	PROMPT_COMMAND=__prompt_command
	__venv() {
		# Let's only check for a virtual environment if the VIRTUAL_ENV variable is
		# set. This should eek out a little more performance when we're not in one
		# since we won't need to call basename.
		if [ -n "${VIRTUAL_ENV}" ] && [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]; then
			echo "($(basename "${VIRTUAL_ENV}"))"
		fi
	}

	__prompt_command() {
		local EXIT="$?"         # This needs to be first
		printf '\033]133;A\007' # Mark the start of prompt

		PS1=""

		if [[ ${EUID} == 0 ]]; then
			PS1+='\[\033[01;31m\]\h'
			PS1+='\[\033]133;B\007\]' # Mark the end of prompt
			return
		fi
		local RCol='\[\e[0m\]'

		local Red='\[\e[0;31m\]'
		local BGre='\[\e[1;32m\]'
		local BBlu='\[\e[1;34m\]'
		local BIBla='\[\e[1;90m\]'

		PS1+="$(__venv)"                      # python venv
		PS1+="${BGre}\u@\h "                  # user and machine
		PS1+="${BBlu}\w"                      # show path
		PS1+=" ${BIBla}$(__parse_git_branch)" # show git branch if in one
		if [ $EXIT != 0 ]; then               # shows sad face if last command returned non zero value
			PS1+="${Red}:(${RCol}"
		fi
		PS1+="${BBlu}\$${RCol}"   # show $
		PS1+='\[\033]133;B\007\]' # Mark the end of prompt
	}

	alias ls="ls --color=auto"
	alias dir="dir --color=auto"
	alias grep="grep --color=auto"
	alias dmesg='dmesg --color'

	# Uncomment the "Color" line in /etc/pacman.conf instead of uncommenting the following line...!
	# alias pacman="pacman --color=auto"
else
	# show root@ when we do not have colors
	PS1="\u@\h \w \$([[ \$? != 0 ]] && echo \":( \")\$ "
fi

PS2="> "
PS3="> "
PS4="+ "

# Try to keep environment pollution down, EPA loves us :-)
unset safe_term match_lhs

# Try to enable the auto-completion (type: "pacman -S bash-completion" to install it).
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Try to enable the "Command not found" hook ("pacman -S pkgfile" to install it).
# See also: https://wiki.archlinux.org/index.php/Bash#The_.22command_not_found.22_hook
[ -r /usr/share/doc/pkgfile/command-not-found.bash ] && . /usr/share/doc/pkgfile/command-not-found.bash

# less colors
export LESS_TERMCAP_mb=$'\E[01;31m' \
	LESS_TERMCAP_md=$'\E[01;38;5;74m' \
	LESS_TERMCAP_me=$'\E[0m' \
	LESS_TERMCAP_se=$'\E[0m' \
	LESS_TERMCAP_so=$'\E[0;33m' \
	LESS_TERMCAP_ue=$'\E[0m' \
	LESS_TERMCAP_us=$'\E[04;38;5;146m'

if [ "$PS1" ]; then
	complete -cf sudo
	complete -F _root_command sudo
fi

# alias
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias mirrorx='sudo reflector --age 6 --latest 20 --fastest 20 --threads 20 --sort rate --protocol https --save /etc/pacman.d/mirrorlist'

alias beep='printf "\a"'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias vim='nvim'

export VISUAL=nvim
export EDITOR="$VISUAL"

# export HISTTIMEFORMAT="$(echo -e "\e[1;36m")[%d/%m %H:%M:%S]$(echo -e "\e[m") "

if [[ "$TERM" = xterm ]]; then
	TERM=xterm-256color
fi

export PATH=${PATH}:/opt/cuda/bin/:~/.local/bin/
export LD_LIBRARY_PATH=/opt/cuda/lib64/:$LD_LIBRARY_PATH

# **********
# ** tmux **
# **********
function t() {
	# Use -d to allow the rest of the function to run
	tmux new-session -d -s work -n neovim
	# send letter by letter so when the nvim closes the window remain
	tmux send-keys -t neovim "nvim ." Enter
	# -d to prevent current window from changing
	tmux new-window -d -n terminal
	# -d to detach any other client (which there shouldn't be,
	# since you just created the session).
	tmux attach-session -d -t work
}

# *********
# ** fzf **
# *********

if command -v fzf &>/dev/null; then
	eval "$(fzf --bash)"
fi
if [ -f ~/.fzf.bash ]; then
	source ~/.fzf.bash
fi
