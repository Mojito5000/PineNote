mkdir artifacts
export WORK_DIR=$PWD
#apt install -y build-essential wget file cpio git unzip bc rsync python3
#md5sum --check gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz.asc
#tar xf gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz
wget -q https://buildroot.org/downloads/buildroot-2021.02.1.tar.gz
tar xf buildroot-2021.02.1.tar.gz
cp buildroot_config buildroot-2021.02.1/.config
cd buildroot-2021.02.1

make > >(tee build.log |grep '>>>') 2>&1 || {
            echo 'Failed build last output'
            tail -200 build.log
            exit 1
        }
cp output/images/rootfs.cpio.lz4 ../artifacts/
