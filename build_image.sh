mkdir tmp
ls -al ./
ls -al artifacts/
DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" apt-get -y install tzdata
apt install -y build-essential dosfstools e2fsprogs util-linux coreutils parted libfdisk-dev libfuse-dev fusefat wget unzip pkg-config
wget -q https://github.com/phf/partfs/archive/refs/heads/develop.zip
unzip -q develop.zip
cd partfs-develop
make
cd ..
wget -q https://deb.debian.org/debian/dists/buster/main/installer-arm64/current/images/netboot/SD-card-images/partition.img.gz
gzip -d partition.img.gz
fusefat -o rw+ partition.img tmp

for IMAGE_NAME in $(ls artifacts/ | grep 'rk356.*dtb') ; do
        echo "Bulding image for $IMAGE_NAME" ;
        mkdir part efi ;
        fallocate -l 1G image.img ;
        parted -s image.img mklabel gpt ;
        parted -s image.img unit s mkpart loader 64 8MiB ;
        parted -s image.img unit s mkpart uboot 8MiB 16MiB ;
        parted -s image.img unit s mkpart env 16MiB 32MiB ;
        parted -s image.img unit s mkpart resource 32MiB 64MiB ;
        parted -s image.img unit s mkpart efi fat32  64MiB 256MiB ;
        parted -s image.img unit s mkpart boot ext4  256MiB 768MiB ;
        parted -s image.img unit s mkpart root ext4  768MiB 100% ;
        parted -s image.img set 5 esp on ;
        parted -s image.img set 6 legacy_boot on ;
        ./partfs-develop/partfs -o dev=image.img part ;
        mkfs.vfat -n "efi" part/p5 ;
        mkfs.ext4 -L "boot" part/p6 ;
        mkfs.ext4 -L "rootfs" part/p7 ;
        tune2fs -o journal_data_writeback part/p7 ;
        dd if=artifacts/idblock.bin of=part/p1 ;
        dd if=artifacts/uboot.img of=part/p2 ;
        fusefat -o rw+ part/p5 efi ;
        cp tmp/INITRD.GZ efi/ ;
        mkdir efi/extlinux ;
        cp extlinux/extlinux.conf efi/extlinux/extlinux.conf ;
        sed -i s/REPLACE_ME.DTB/$IMAGE_NAME/ efi/extlinux/extlinux.conf ;
        mkdir -p efi/dtbs/rockchip ;
        cp artifacts/Image efi/vmlinuz;
        cp artifacts/$IMAGE_NAME efi/dtbs/rockchip/ ;
        cp artifacts/kernel-modules.tar.gz efi/ ;
        cp artifacts/rootfs.cpio.lz4 efi/ ;
        cp efi/extlinux/extlinux.conf artifacts/$IMAGE_NAME-extlinux.conf ;
        fusermount -u efi ;
        fusermount -u part ;
        xz image.img ;
        cp image.img.xz artifacts/$IMAGE_NAME.img.xz ;
        rm -rf efi part image.img.xz ;
      done
