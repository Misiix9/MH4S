# ZSH Configuration

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme Configuration
ZSH_THEME="minimal"

# Plugin Configuration
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    sudo
    history
    copypath
    dirhistory
    web-search
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# History Configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt incappendhistory
setopt sharehistory

# Basic auto/tab completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files

# Better searching in command mode
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Environment Variables
export EDITOR='code'
export VISUAL='code'
export TERMINAL='kitty'
export BROWSER='zen-browser'
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_THEME=Adwaita:dark
export GDK_BACKEND=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland

# Custom Functions
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function update() {
    yay -Syu --noconfirm
}

# Core Task Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System Aliases
alias sdn='shutdown now'
alias rb='reboot'
alias suspend='systemctl suspend'

# Package Management
alias yi='yay -S'
alias yr='yay -R'
alias yu='yay -Syu'
alias yc='yay -Yc'

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline'

# Hyprland Specific
alias hyconf='vim ~/.config/hypr/hyprland.conf'
alias wayconf='vim ~/.config/waybar/config'
alias kitconf='vim ~/.config/kitty/kitty.conf'

# Quick Edit Configs
alias zshrc='vim ~/.zshrc'
alias aliasrc='vim ~/.config/zsh/aliases'
alias reload='source ~/.zshrc'

# Directory Navigation
alias home='cd ~'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'
alias pictures='cd ~/Pictures'
alias videos='cd ~/Videos'
alias music='cd ~/Music'

# Utility Functions
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias free='free -m'
alias top='htop'
alias diff='diff --color=auto'

# Network
alias ping='ping -c 5'
alias myip='curl ifconfig.me'
alias ports='netstat -tulanp'

# System Info
alias sysinfo='neofetch'
alias diskspace='du -sh * | sort -h'
alias meminfo='free -h'
alias cpuinfo='cat /proc/cpuinfo'

# Quick Open
alias open='xdg-open'
alias o='xdg-open'

# Color Output
alias diff='diff --color=auto'
alias ip='ip -color=auto'

# Development
alias py='python'
alias pip='pip3'
alias npm='npm'
alias npmi='npm install'
alias npmu='npm update'
alias npmr='npm run'

# Docker
alias dk='docker'
alias dkc='docker-compose'
alias dkps='docker ps'
alias dkst='docker stats'
alias dkimg='docker images'

# Safety
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'

# Clipboard
alias copy='wl-copy'
alias paste='wl-paste'

# Start Hyprland
if [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
