#!/bin/bash

# Убедитесь, что скрипт запускается с правами суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите этот скрипт с правами суперпользователя (sudo)."
    exit 1
fi

# Диск для форматирования
DISK="/dev/sda"

# Удаление всех существующих разделов на диске
echo "Удаление всех существующих разделов на $DISK..."
parted $DISK mklabel gpt

# Создание разделов
echo "Создание разделов..."

# 50 ГБ для системы
parted $DISK mkpart primary ext4 1MiB 50GiB -1

# 1 ГБ для EFI
parted $DISK mkpart primary fat32 50GiB 51GiB -1
parted $DISK set 2 esp on

# 4 ГБ для Swap
parted $DISK mkpart primary linux-swap 51GiB 55GiB -1

# Оставшееся пространство для Home
parted $DISK mkpart primary ext4 55GiB 100% -1

# Форматирование разделов
echo "Форматирование разделов..."

# Форматирование раздела для системы
mkfs.ext4 -F ${DISK}1

# Форматирование EFI-раздела
mkfs.fat -F32 ${DISK}2

# Форматирование Swap-раздела
mkswap -f ${DISK}3

# Форматирование раздела для Home
mkfs.ext4 -F ${DISK}4

# Активация Swap
swapon -a ${DISK}3

# Монтирование разделов
echo "Монтирование разделов..."

# Создание точек монтирования
mkdir -p /mnt
mkdir -p /mnt/home
mkdir -p /mnt/boot/efi

# Монтирование раздела для системы
mount ${DISK}1 /mnt

# Монтирование EFI-раздела
mount ${DISK}2 /mnt/boot/efi

# Монтирование раздела для Home
mount ${DISK}4 /mnt/home

echo "Разделы смонтированы."
echo "Система смонтирована в /mnt"
echo "EFI смонтирован в /mnt/boot/efi"
echo "Home смонтирован в /mnt/home"

pacstrap -i /mnt base base-devel linux linux-firmware linux-headers sudo nano networkmanager efibootmgr --noconfirm

genfstab -U -p /mnt >> /mnt/etc/fstab --noconfirm

arch-chroot /mnt /bin/bash --noconfirm

sed -i 's/#$en_US.UTF-8$/en_US.UTF-8/' /etc/locale.gen
sed -i 's/#$ru_RU.UTF-8$/ru_RU.UTF-8/' /etc/locale.gen
locale-gen --noconfirm
echo "LANG=en_US.UTF-8" > /etc/locale.conf --noconfirm
ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg /etc/localtime --noconfirm
hwclock --systohc --utc --noconfirm
echo archpc > /etc/hostname --noconfirm
echo "127.0.1.1 localhost.localdomain archpc" | sudo tee -a /etc/hosts --noconfirm
systemctl enable NetworkManager --noconfirm
useradd -m -g users -G wheel -s /bin/bash superuser --noconfirm
passwd superuser --noconfirm
EDITOR=nano
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers --noconfirm
mkdir /boot/efi --noconfirm
pacman -S grub --noconfirm
grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable --noconfirm
grub-mkconfig -o /boot/grub/grub.cfg --noconfirm
passwd --noconfirm
exit
umount -R /mnt
reboot
