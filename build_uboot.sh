mkdir artifacts
#apt install -y build-essential gcc bc bison flex libssl-dev libncurses5-dev libelf-dev wget time xz-utils device-tree-compiler kmod
#python3 -m pip install pyelftools
#md5sum --check gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz.asc
#tar xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz
export CROSS_COMPILE=aarch64-none-linux-gnu-
export PATH="$PWD/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin":$PATH
#export BRANCH="${UPSTREAM_BRANCH_UBOOT:-quartz64}"
#echo "Building branch - $BRANCH"

wget https://gitlab.com/pgwipeout/u-boot-rockchip/-/archive/quartz64/u-boot-rockchip-quartz64.tar.gz

wget https://github.com/JeffyCN/rockchip_mirrors/archive/refs/heads/rkbin.zip
tar xf u-boot-rockchip-quartz64.tar.gz
unzip -q rkbin.zip
mv rockchip_mirrors-rkbin rkbin
cd u-boot-rockchip-quartz64
make rk3566-quartz64_defconfig

./make.sh
./tools/resource_tool --pack arch/arm/dts/rk3566-quartz64.dtb
cp idblock.bin ../artifacts/
cp uboot.img ../artifacts/
cp resource.img ../artifacts/
cp rk356x_spl_loader_*bin ../artifacts/
