# Configuration

## Set up remote connection

1. Use `wifi-menu` or `dhclient` for wired connections.
2. Install ssh `pacman -S openssh`
3. Configure initial SSH key `mkdir ~/.ssh && curl -fLsS https://github.com/grobie.keys > ~/.ssh/authorized_keys`
4. Start SSH server `systemctl start sshd.service`

## Gnome

### Install & configure Gnome

```console
sudo pacman -S gnome
sudo bash -c 'echo LC_ALL= >> /etc/locale.conf'
```

### NetworkManager with VPN support

```console
sudo pacman -S networkmanager networkmanager-openvpn
sudo systemctl enable --now NetworkManager.service
```

### Power management

```console
sudo pacman -S tlp tp_smapi acpi_call x86_energy_perf_policy
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo pacman -S tlp-rdw
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
```

### Start Gnome

```console
sudo systemctl enable --now gdm.service
```

## System configuration

### Input settings

- Change sensitivity
- Consider changing natural scrolling
- Increase typing key press speed

### Keyboard modifications

1. Install gnome-tweaks `pacman -S gnome-tweaks`
2. Swap CapsLock with Ctrl in Keyboard / Additional
3. Enable compose key (AltGr) for umlauts

### System notifications

- Disable audible bell `gsettings set org.gnome.desktop.wm.preferences audible-bell false`

### Clipboard manager

1. Install gpaste `pacman -S gpaste`
2. Start gpaste and enable the gnome-shell extension (requires user session restart)

### Package manager

Next to pacman, an AUR package manager/wrapper is useful to ease the
installation of user provided packages.

```console
# Install git, go, and base development tools
pacmans -S base-devel git go

# Download yay
mkdir -p ~/code/src/aur.archlinux.org/
git clone https://aur.archlinux.org/yay.git ~/code/src/aur.archlinux.org/yay

# Install yay
cd ~/code/src/aur.archlinux.org/yay
makepkg -si
```

As the [installation](/installation.md) instructions suggest to extract boot
into a separate encrypted device, package updates touching `/boot` will silently
fail. Install a guard hook to make such errors visible.

1. Install kernel modules hook (note the installation instructions) `yay -S kernel-modules-hook`
2. d

### Time sync

<https://wiki.archlinux.org/index.php/Chrony>

1. Install chrony package `yay -S chrony`
2. Update NTP pool servers `vim /etc/chrony.conf`
3. Enable chrony `systemctl enable --now chronyd.service`
4. Activate chrony by starting the console with `chronyc` and typing `online`

### Browser

1. Install Firefox `yay -S firefox`
2. Disable password saving
3. Install extensions LastPass, Dashlane, uBlock Origin
4. Install U2F host module `yay -S libu2f-host`
5. Disable "Ctrl+Tab cycles through tabs in recently used order"

## Programming

### Code editor

1. Install Visual Studio Code `yay -S visual-studio-code-bin`
2. Install extensions

   ```console
   code --install-extension TeddyDD.fish
   code --install-extension bungcip.better-toml
   code --install-extension caarlos0.language-prometheus
   code --install-extension DavidAnson.vscode-markdownlint
   code --install-extension eamodio.gitlens
   code --install-extension eriklynd.json-tools
   code --install-extension hoovercj.ruby-linter
   code --install-extension jetmartin.bats
   code --install-extension maelvalais.autoconf
   code --install-extension mauve.terraform
   code --install-extension ms-azuretools.vscode-docker
   code --install-extension ms-vscode.cpptools
   code --install-extension ms-vscode.Go
   code --install-extension ms-vscode.Theme-MarkdownKit
   code --install-extension ms-vscode.Theme-MaterialKit
   code --install-extension rebornix.ruby
   code --install-extension samverschueren.final-newline
   code --install-extension stkb.rewrap
   code --install-extension zhuangtongfa.Material-theme
   code --install-extension ziyasal.vscode-open-in-github
   ```

### Programming tools

```console
yay -S --needed \
    ack \
    aws-cli \
    base-devel \
    bind-tools \
    docker \
    fish \
    git \
    go \
    htop \
    hub \
    inetutils \
    ipmitool \
    jq \
    kubectl-bin \
    man \
    ruby \
    shellcheck-static \
    terraform \
    tmux \
    zsh
```

## Messaging

### Signal

```console
yay -S signal-desktop-bin
```
