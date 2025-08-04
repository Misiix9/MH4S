#!/bin/bash

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Create minimal theme
echo '# Minimal ZSH Theme

PROMPT="%F{white}%~ %F{white}→%f "
RPROMPT='"'"'$(git_prompt_info)'"'"'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{white}git:("
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{white})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{white}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""' > ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/minimal.zsh-theme

# Link zsh configuration
ln -sf ~/.config/zsh/.zshrc ~/.zshrc

# Change default shell to zsh
chsh -s $(which zsh)
