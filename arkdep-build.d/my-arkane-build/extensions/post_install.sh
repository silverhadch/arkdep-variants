# Set list of AUR packages to install
aur_packages=('yay-bin' 'dolphin-megasync-bin' 'megasync-bin' 'ttf-jetbrains-mono' 'ttf-nerd-fonts-symbols')

# Install build dependencies
printf '\e[1;32m-->\e[0m\e[1m Installing build dependencies\e[0m\n'
arch-chroot "$workdir" pacman -Sy --noconfirm --needed base-devel git

# Create temporary unprivileged user, required for fakeroot
printf '\e[1;32m-->\e[0m\e[1m Creating temporary user\e[0m\n'
arch-chroot "$workdir" useradd aur -m -p '!'

# Install yay manually first (because we need it to install others)
printf '\e[1;32m-->\e[0m\e[1m Bootstrapping yay-bin\e[0m\n'
arch-chroot -u aur:aur "$workdir" bash -c "
  cd /home/aur && 
  git clone https://aur.archlinux.org/yay-bin.git &&
  cd yay-bin &&
  makepkg -si --noconfirm
"

# Install AUR packages using yay
for package in "${aur_packages[@]}"; do
    printf "\e[1;32m-->\e[0m\e[1m Installing $package using yay\e[0m\n"
    arch-chroot -u aur:aur "$workdir" bash -c "yay -S --noconfirm $package"
done

# Cleanup
printf '\e[1;32m-->\e[0m\e[1m Performing cleanup\e[0m\n'
arch-chroot "$workdir" userdel -r aur
