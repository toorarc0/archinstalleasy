I made this version of "archinstall" to make it easier for ME to install Arch Linux (Manual installation is fine for me too, but I decided to write my first code in bash)

And everything works very crookedly, especially if you look closely in the file instead of letters there are squares somewhere, hehe... It may still not start, but this can be solved with dos2unix

(pacman -S dos2unix, dos2unix archinstall.sh)

In general there are a lot of ERRORS here, if anyone can help me with this I will be sooooo grateful

Well, the neural network also helped me a little, okay.

# disk partitions
ATTENTION! A PARTITION IS CREATED IN /dev/nvme0n1, USE THE SOURCE CODE TO CHANGE THE VALUES OF /dev/nvme0n1 TO YOUR DISK!!! (for example /dev/sda)

50G for Linux System

1G for efi

4G for swap

remaining Gb for home

# Computer and domain name, username
for the computer name and host I used 
"archpc"

for username
"superuser" (I love this nickname so much)

My first launch of my own program was a failure, it seems I made a lot of errors in my code... somewhere it did everything correctly, but the system could not start without installation disk (despite the fact that GRUB was installed haha)
