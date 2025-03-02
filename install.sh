# Install Homebrew
echo "Installing Homebrew:"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "Successfully installed Homebrew"

# Install oh-my-zsh
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "Successfully installed oh-my-zsh"

# Install Homebrew packages
packages=(
    # camo
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
    zoxide
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
    font-geist-mono-nerd-font
    go
    google-chrome
    itsycal
    # karabiner-elements
    keyclu
    kitty
    lazygit
    microsoft-edge
    microsoft-office
    notion
    numi
    pearcleaner
    ranger
    ripgrep
    scroll-reverser
    # spotify
    tmux
    tpm
    tree-sitter
    visual-studio-code
    warp
    wezterm
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

