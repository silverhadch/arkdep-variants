set -e
if [ -z "$workdir" ]; then echo "ERROR: workdir variable is not set."; exit 1; fi
printf '\e[1;32m-->\e[0m\e[1m Importing Chaotic-AUR GPG key\e[0m\n'
arch-chroot "$workdir" pacman-key --init
arch-chroot "$workdir" pacman-key --populate archlinux
arch-chroot "$workdir" pacman -Sy archlinux-keyring
arch-chroot "$workdir" pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
arch-chroot "$workdir" pacman-key --lsign-key 3056513887B78AEB
printf '\e[1;32m-->\e[0m\e[1m Installing Chaotic-AUR keyring and mirrorlist\e[0m\n'
arch-chroot "$workdir" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
arch-chroot "$workdir" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
arch-chroot "$workdir" bash -c "echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf"
printf '\e[1;32m-->\e[0m\e[1m Syncing package databases\e[0m\n'
arch-chroot "$workdir" pacman -Syyu
arch-chroot "$workdir" cat /etc/pacman.conf
printf '\e[1;32m-->\e[0m\e[1m Chaotic-AUR setup complete!\e[0m\n'
