#!/bin/sh

# Alpine Config
# BASH script to configure a blank Alpine Linux install for daily use
# By Nicholas Grogg

# Set to always use latest stable release, change if not desired
doas sed -i "s/v3\.22/latest-stable/g" /etc/apk/repositories

# Prompt user to check repo
echo ""
echo "Double check repo files before proceeding."
echo "Ensure no typos and that community repo is enabled."
echo "Script WILL fail if either criteria is unmet."
echo ""
echo "Press enter when ready to proceed"
echo ""

read junkInput

# Open repo
doas vi /etc/apk/repositories

# Check for package updates
doas apk update
doas apk upgrade

# Install packages
doas apk add \
        vim \
        fastfetch \
        font-awesome \
        font-dejavu \
        font-inconsolata \
        font-noto \
        font-noto-cjk \
        font-noto-extra \
        font-terminus \
        git \
        ip6tables \
        mesa-dri-gallium \
        mesa-va-gallium \
        networkmanager \
        networkmanager-tui \
        networkmanager-wifi \
        network-manager-applet \
        shadow \
        ufw \
        zsh \
        zsh-vcs

# Add user to plugdev group for NetworkManager
doas adduser $(whoami) plugdev

# Clone Repos
## Make gits directory
mkdir -p ~/Documents/gits
cd ~/Documents/gits

## Clone repos
git clone https://github.com/ngrogg/dotfiles.git
git clone https://github.com/ngrogg/alpine-config.git

## Put dotfile files in place
cp dotfiles/.zshrc ~/.zshrc
cp dotfiles/.vimrc.simple ~/.vimrc

## Put Alpine Linux NetworkManager files in place
doas cp alpine-config/NetworkManagerFiles/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
doas cp alpine-config/NetworkManagerFiles/any-user.conf /etc/NetworkManager/conf.d/any-user.conf

## Restart Network Manager
doas rc-service networkmanager restart

### Enable networkmanager on boot
doas rc-update add networkmanager default

# Configure UFW w/ basic setup. May need adjusted depending on exact system setup
doas ufw default deny incoming
doas ufw default allow outgoing
doas ufw default deny forward
doas ufw allow in on lo
doas ufw allow out on lo
doas ufw logging on
doas ufw limit ssh
doas ufw enable
doas ufw status verbose

# Add UFW init scripts
doas rc-update add ufw

# Change default shell to ZSH
mkdir -p ~/.zsh/cache
chsh -s $(which zsh)

# Configure desktop
cd ~/
doas setup-desktop
