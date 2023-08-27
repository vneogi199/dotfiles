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
    neovim
    node
    pnpm
    yarn
    zsh-autosuggestions
    zsh-syntax-highlighting
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
    google-chrome
    # helix
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
