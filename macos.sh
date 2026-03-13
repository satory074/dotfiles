#!/bin/bash
# macOS system defaults for developer setup
# Run via: bash ~/dotfiles/macos.sh

# Keyboard: faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Input correction: disable auto-corrections that interfere with coding
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Finder: show hidden files, extensions, path bar, status bar
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Dock: auto-hide with zero delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Screenshots: save to ~/Screenshots, disable shadow
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# Dialogs: expand save/print panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

killall Dock Finder SystemUIServer 2>/dev/null || true
echo "macOS defaults applied. Some changes require logout/restart."
