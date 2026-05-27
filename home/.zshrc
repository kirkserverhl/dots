# =====================================================
# Core Environment
# =====================================================
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export PATH="$HOME/.config/hyprgruv/scripts:$PATH"
export PATH=Z"HOME/scripts:$PATH"
export QT_QPA_PLATFORMTHEME=qt6ct
export TERMINAL=kitty

# Test Path
export PATH="/home/$USER/.local/bin:$PATH"

if command -v bat >/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# GPG / SSH agent (quiet)
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpgconf --launch gpg-agent >/dev/null 2>&1

# =====================================================
# Matugen Terminal Colors (replaces old pywal/wal)
# =====================================================
if command -v python3 >/dev/null 2>&1; then
  # Apply current matugen-generated terminal colors on startup
  python3 ~/.config/matugen/push_term_colors.py >/dev/null 2>&1 || true
fi

# =====================================================
# History
# =====================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=$HISTSIZE

setopt extended_history hist_expire_dups_first hist_ignore_all_dups \
       hist_ignore_space hist_verify inc_append_history share_history \
       complete_in_word list_ambiguous nolisttypes listpacked automenu autocd

unsetopt correct

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Test
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# =====================================================
# Aliases
# =====================================================
if command -v eza >/dev/null; then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons'
  alias la='eza -Alh --icons'
  alias lls='eza -l --icons'
  alias ldir="eza -l --icons | egrep '^d'"
else
  alias ls='ls --color=auto -A'
  alias ll='ls --color=auto -al'
fi

if command -v bat >/dev/null; then
  export BAT_THEME="gruvbox-dark"
  alias cat='bat -pp'
  alias less='bat'
else
  alias less='less -R'
fi

# Directory navigation
alias ..='cd .. && ls'
alias ...='cd ../.. && ls'
alias ....='cd ../../.. && ls'
alias .....='cd ../../../../.. && ls'
alias bd='cd "$OLDPWD"'

# General
alias rmd='/bin/rm -rfv'
alias hypr='$EDITOR ~/.config/hypr/'
alias hyprstow='$HOME/bin/migrate-config-to-stow'
alias c='clear && $SHELL'
alias ff='fastfetch'
alias tm='tmux'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gsp='git stash && git pull'
alias ping='ping -c 5'
alias fastping='ping -c 100 -i .2'
alias keybinds='nvim ~/.config/hypr/conf/keybindings/default.conf'
alias reload='hyprctl reload'
alias hyprscripts= '$EDITOR ~/.config/hypr/scripts'

# Zoxide
alias za='zoxide add'
alias zr='zoxide remove'
alias zl='zoxide query -l'
alias zi='zoxide query -i'


# YAY
alias i="yay -S"
alias r="yay -Rns"
alias u="yay -Syu"
alias s="yay -Ss"
alias q="yay -Q"

# Test
plugins=(git zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Matugen Palette Output
alias palette='~/.config/hypr/scripts/palette.sh'

# Errors
alias hyprerror='hyprctl configerrors'

# Unlock Faillock
alias unlock='~/.config/hypr/scripts/unlockroot.sh'

# =====================================================
# Functions
# =====================================================
trim() {
  local var=$*; var="${var#"${var%%[![:space:]]*}"}"; var="${var%"${var##*[![:space:]]}"}"; print -r -- "$var"
}

extract() {
  for f in "$@"; do
    [[ -f "$f" ]] || { echo "Not a file: $f"; continue; }
    case "$f" in
      *.tar.bz2) tar xvjf "$f" ;;
      *.tar.gz)  tar xvzf "$f" ;;
      *.bz2)     bunzip2 "$f" ;;
      *.rar)     unrar x "$f" ;;
      *.gz)      gunzip "$f" ;;
      *.tar)     tar xvf "$f" ;;
      *.tbz2)    tar xvjf "$f" ;;
      *.tgz)     tar xvzf "$f" ;;
      *.zip)     unzip "$f" ;;
      *.Z)       uncompress "$f" ;;
      *.7z)      7z x "$f" ;;
      *)         echo "Don't know how to extract: $f" ;;
    esac
  done
}

cd() {
  if builtin cd "$@"; then
    ls
  fi
}

ftext() { grep -iIHrn --color=always "${1:?pattern}" . | less -r; }

whatsmyip() {
  echo -n "Internal IP: "
  ip -o -4 addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
  echo -n "External IP: "
  curl -fsS ifconfig.me || echo "unavailable"
}
alias whatismyip='whatsmyip'

# Yazi wrapper
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# =====================================================
# FZF
# =====================================================
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# =====================================================
# Zoxide
# =====================================================
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# =====================================================
# Matugen Terminal Colors
# =====================================================
# Terminal theming is now handled by matugen (not pywal).
# This applies the current wallpaper-based colors to the terminal.
if command -v python3 >/dev/null 2>&1; then
  python3 ~/.config/matugen/push_term_colors.py >/dev/null 2>&1 || true
fi

# =====================================================
# Prompt (Starship)
# =====================================================
eval "$(starship init zsh)"

# =====================================================
# Fastfetch intro
# =====================================================
if [[ $TERM == "kitty" && -t 1 ]]; then
  clear
  command -v fastfetch >/dev/null && fastfetch
fi

# =====================================================
# Atuin (keep near the end)
# =====================================================
eval "$(atuin init zsh)"
. "$HOME/.atuin/bin/env"

# Control + Backspace
bindkey '^H' backward-kill-word

export PATH="$HOME/bin:$PATH"

export CLUTTER_BACKEND=wayland

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
