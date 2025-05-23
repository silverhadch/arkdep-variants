# Set list of AUR packages to install
aur_packages=('waydroid-helper' 'ttf-jetbrains-mono' 'ttf-nerd-fonts-symbols' 'usb-dirty-pages-udev' 'wayfire' 'wf-shell' 'wcm' 'cosmic-session-git')

# Install build dependencies
printf '\e[1;32m-->\e[0m\e[1m Installing build dependencies\e[0m\n'
arch-chroot "$workdir" pacman -Sy --noconfirm --needed base-devel git

# Create temporary unprivileged user, required for fakeroot
printf '\e[1;32m-->\e[0m\e[1m Creating temporary user\e[0m\n'
arch-chroot "$workdir" useradd aur -m -p '!'

# Allow 'aur' to use sudo without password
printf '\e[1;32m-->\e[0m\e[1m Allowing aur user passwordless sudo\e[0m\n'
arch-chroot "$workdir" bash -c "echo 'aur ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/aur"

# Install yay manually first (because we need it to install others)
printf '\e[1;32m-->\e[0m\e[1m Bootstrapping yay-bin\e[0m\n'
arch-chroot -u aur:aur "$workdir" bash -c "
  cd /home/aur &&
  git clone https://aur.archlinux.org/yay-bin.git &&
  cd yay-bin &&
  makepkg -si --noconfirm
"

# Install MEGA
arch-chroot -u aur:aur "$workdir" bash -c "
	sudo wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.zst && sudo pacman -U --noconfirm megasync-x86_64.pkg.tar.zst
"

# Install AUR packages using yay
for package in "${aur_packages[@]}"; do
    printf "\e[1;32m-->\e[0m\e[1m Installing $package using yay\e[0m\n"
    arch-chroot -u aur:aur "$workdir" bash -c "yay -Sy --noconfirm $package"
done

# Cleanup sudoers file
printf '\e[1;32m-->\e[0m\e[1m Removing temporary sudoers rule\e[0m\n'
arch-chroot "$workdir" rm -f /etc/sudoers.d/aur

# Cleanup user
printf '\e[1;32m-->\e[0m\e[1m Performing cleanup\e[0m\n'
arch-chroot "$workdir" userdel -r aur

# Set Plymouth theme inside chroot
printf '\e[1;32m-->\e[0m\e[1m Setting Plymouth theme to bgrt\e[0m\n'
arch-chroot "$workdir" plymouth-set-default-theme bgrt
arch-chroot "$workdir" plymouth-set-default-theme
