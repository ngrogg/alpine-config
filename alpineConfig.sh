#!/bin/sh

# Alpine Config
# BASH script to configure a blank Alpine Linux install for daily use
# By Nicholas Grogg

# Need curl installed to proceed
doas apk add curl grep

# Prompt user to select stable or rolling branch
echo ""
echo "Enter 1 for stable or 2 for edge release"
echo ""
echo "Be aware this script assumes the newest stable ISO is being used!"
echo "As of this running that release is:"

# Curl + parse latest Alpine Linux release
# Command breakdown
# curl -s, download page silently
# grep -oP 'v\d+\.\d+', parse versions
# sort -V, sort by version
# uniq, remove duplicate entries
# tail -n 1, output latest version
curl -s https://dl-cdn.alpinelinux.org/alpine/ \
    | grep -oP 'v\d+\.\d+' \
    | sort -V \
    | uniq \
    | tail -n 1

echo ""
echo "Input 1 or 2 and press enter when ready to proceed or control + c to cancel"
echo ""

read releaseVersion

# Parse Alpine releases for to find newest release
# Curl + parse latest Alpine Linux release
# Command breakdown
# curl -s, download page silently
# grep -oP 'v\d+\.\d+', parse versions
# sort -V, sort by version
# uniq, remove duplicate entries
# tail -n 1, output latest version
# sed "s/\./\\\./g", Change . to \. for sed string
latestRelease=$(curl -s https://dl-cdn.alpinelinux.org/alpine/ \
    | grep -oP 'v\d+\.\d+' \
    | sort -V \
    | uniq \
    | tail -n 1 \
    | sed "s/\./\\\./g")

if [[ $releaseVersion -eq 1 ]]; then
    echo ""
    echo "Stable"
    ## Set to always use latest stable release, update version as needed
    doas sed -i "s/$latestRelease/latest-stable/g" /etc/apk/repositories

    ## Enable community repo
    doas sed -i "s/#http/http/g" /etc/apk/repositories
elif [[ $releaseVersion -eq 2 ]]; then
    echo ""
    echo "Edge"
    ## Set to use edge rolling release
    doas sed -i "s/$latestRelease/edge/g" /etc/apk/repositories

    ## Enable community repo
    doas sed -i "s/#http/http/g" /etc/apk/repositories

    ## Append testing repo to repository file
    tail -n 1 /etc/apk/repositories | sed "s/community/testing/g" | doas tee -a /etc/apk/repositories
else
    echo "Invalid input detected"
    exit 1
fi

# Prompt user to check repo
echo ""
echo "Double check repo files before proceeding."
echo ""
echo "Ensure no typos and that community repo is enabled."
echo "If using Edge release check for testing repo as well"
echo ""
echo "Script WILL fail if either criteria is unmet."
echo ""
echo "Repo files at /etc/apk/repositories"
echo ""
echo "Press enter when ready to proceed or control + c to cancel"
echo ""

read junkInput

# Open repo
doas vi /etc/apk/repositories

# Check for package updates
doas apk update
doas apk upgrade

# Install packages
doas apk add \
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
        network-manager-applet \
        shadow \
        ufw \
        vim \
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

# Configure flatpak
doas apk add flatpak
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
