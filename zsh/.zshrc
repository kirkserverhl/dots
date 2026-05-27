export PATH="$PATH:$HOME/.local/bin"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt append_history
setopt EXTENDED_GLOB
setopt REMATCH_PCRE

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export OPENER=mimeopen

# If git is not installed, tell the user it is needed for full functionality then exit.
if ! command -v git &>/dev/null; then
  echo "Git is required for full functionality for this zsh config! Please install it."
  exit 1
fi

# =============================================================================
# Plugin loading (no plugin manager)
# =============================================================================
#
# Plugins are loaded directly. Install the ones not in pacman with:
#   git clone https://github.com/<repo> ~/.local/share/zsh/plugins/<name>
#
# Then source them below using the standard paths.
# =============================================================================

# --- Early plugins (load before other keybindings) ---

# zsh-vi-mode (better vi mode)
if [[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
  ZVM_INIT_MODE=sourcing
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
fi

# --- Regular plugins ---

# zsh-autopair
[[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh" ]] && \
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-autopair/zsh-autopair.plugin.zsh"

# fzf-tab (needs to be loaded before compinit)
if [[ -r "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
fi

# zsh-completions (from pacman or manual)
fpath+=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-completions/src")

# zsh-syntax-highlighting (should be loaded before autosuggestions)
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-autosuggestions
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# eza completions (if using eza from pacman/AUR)
if command -v eza &>/dev/null; then
  fpath+=("${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/eza-completions")
fi

# Run compinit once
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

# Completion style settings (for use with fzf-tab plugin)
zstyle ':completion:*:git-checkout:*' sort false        # disable sort when completing `git checkout`
zstyle ':completion:*:descriptions' format '[%d]'       # set descriptions format to enable group support
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # set list-colors to enable filename colorizing
zstyle ':completion:*' menu no                          # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
if command -v "eza" &>/dev/null; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'  # preview directory's content with eza when completing cd
fi
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept   # custom fzf flags
zstyle ':fzf-tab:*' use-fzf-default-opts yes            # To make fzf-tab follow FZF_DEFAULT_OPTS.
zstyle ':fzf-tab:*' switch-group '<' '>'                # switch group using `<` and `>`

# Lower esc key delay for vi mode to 0.05s
export KEYTIMEOUT=5

# Custom keybindings (previously handled via zinit atload)
bindkey -r "^h"
bindkey "^h" backward-kill-word

# Useful aliases
alias '..'='cd ..'
alias less='less -R'

alias ls='ls --color=auto -l'
if command -v eza &>/dev/null; then
    alias ls='eza -l --color=auto --icons=auto --group-directories-first'
fi
alias la='ls -alh'

if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
fi

if command -v trash &>/dev/null; then
    alias rm='trash'
fi

alias lg='lazygit'

if command -v thefuck &>/dev/null; then
    eval "$(thefuck -a fuck)"
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init --cmd cd zsh)"
fi

if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# Source all zsh env files from ~/.config/zsh/
for f in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/*.zsh(N); do
  source "$f"
done

# =====================================================
# Matugen Terminal Colors (replaces old pywal)
# =====================================================
# Terminal colors are now managed by matugen.
if command -v python3 >/dev/null 2>&1; then
  python3 ~/.config/matugen/push_term_colors.py >/dev/null 2>&1 || true
fi

# Starship prompt
eval "$(starship init zsh)"
