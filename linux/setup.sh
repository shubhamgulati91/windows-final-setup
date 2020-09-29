hwclock --systohc
ln -sf /usr/share/zoneinfo/Asia/Kolkata
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo KEYMAP=us >> /etc/vconsole.conf
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable sshd
systemctl enable dhcpcd
useradd -m shubham
usermod -aG wheel shubham
systemctl enable sshd.service
systemctl enable NetworkManager.service

# Disable automatic core dumps
echo 'kernel.core_pattern=|/bin/false' > /etc/sysctl.d/50-coredump.conf

# Add wheel group to sudoers
echo '%wheel        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

exit
