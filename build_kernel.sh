mkdir artifacts
mkdir modules
export INSTALL_MOD_PATH=$PWD/modules
#apt install -y build-essential gcc bc bison flex libssl-dev libncurses5-dev libelf-dev wget time xz-utils device-tree-compiler kmod
#md5sum --check gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz.asc
#tar xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz
export ARCH=arm64
export CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH="$PWD/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin":$PATH


cd linux-next

cp ../quartz64_defconfig arch/arm64/configs/quartz64_defconfig
make quartz64_defconfig
make -j$(nproc)

cp arch/arm64/boot/Image ../artifacts/
cp arch/arm64/boot/dts/rockchip/rk356*.dtb ../artifacts/

make modules_install
cd ../modules
tar -czf kernel-modules.tar.gz lib
cp kernel-modules.tar.gz ../artifacts/
