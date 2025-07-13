#!/usr/bin/bash

# Alpine Config
# BASH script to configure a blank Alpine Linux install for daily use
# By Nicholas Grogg

# Set to always use latest stable release, change if not desired
doas sed -i "s/v3\.22/latest-stable/g" /etc/apk/repositories

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
        mesa-dri-gallium \
        mesa-va-gallium \
        networkmanager \
        networkmanager-tui \
        networkmanager-wifi \
        network-manager-applet \
        shadow \
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

## Disable conflicting WIFI services
doas rc-service networking stop
doas rc-service wpa_supplicant stop

## Restart Network Manager
doas rc-service networkmanager restart

## Disable conflicting WIFI services
doas rc-update del networking boot
doas rc-update del wpa_supplicant boot

### Enable networkmanager on boot
doas rc-update add networkmanager default

# Change default shell to ZSH
mkdir -p ~/.zsh/cache
chsh -s $(which zsh)

# Configure desktop
cd ~/
doas setup-desktop
