# Install Homebrew
echo "Installing Homebrew:"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Successfully installed Homebrew"

# Install oh-my-zsh
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Successfully installed oh-my-zsh"

# Install LunarVim
echo "Install LunarVim by following steps: https://www.lunarvim.org/docs/installation"


# Install Homebrew packages
packages=(
    camo
    docker
    neovim
    node
    pnpm
    raycast
    starship
    yarn
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    zsh-history-substring-search
    zsh-you-should-use
    # powerlevel10k
    arc
    fd
    firefox
    font-cascadia-code
    font-caskaydia-cove-nerd-font
    font-fira-code
    font-fira-code-nerd-font
    font-fira-mono-nerd-font
    font-hack-nerd-font
    font-jetbrains-mono-nerd-font
    font-meslo-lg-nerd-font
    go
    google-chrome
    iterm2
    itsycal
    karabiner-elements
    kitty
    lazygit
    microsoft-edge
    microsoft-office
    notion
    numi
    ranger
    ripgrep
    scroll-reverser
    spotify
    tree-sitter
    visual-studio-code
    warp
    zoom
)

for package in "${packages[@]}"; do
    if brew list "$package" >/dev/null 2>&1; then
        echo "Package $package is already installed. Skipping..."
    else
        echo "Installing package $package..."
        brew install "$package"
        echo "Successfully installed package $package..."
    fi
done

