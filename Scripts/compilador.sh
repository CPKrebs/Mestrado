sudo apt-get update
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev \
libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
patchutils bc zlib1g-dev libexpat-dev


mkdir /opt/RISC-V
cd /opt/RISC-V

export RISCV=/opt/RISC-V/riscv
export PATH=$PATH:$RISCV/bin:$PATH

# Compilador
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
make clean
./configure --prefix=/opt/RISC-V/riscv_llvm --enable-multilib
make linux -j`nproc`
make newlib -j`nproc`


# Proxy Kernel
git clone https://github.com/riscv/riscv-pk.git
mkdir riscv-pk/build && cd riscv-pk/build
../configure --prefix=/opt/RISC-V/riscv_llvm \
--with-arch=rv64gc_zifencei \
--host=riscv64-unknown-linux-gnu 
make -j`nproc`
make install
cd ..
rm -R build


# Spike
git clone https://github.com/riscv/riscv-isa-sim.git
mkdir riscv-isa-sim/build && cd riscv-isa-sim/build
../configure --prefix=/opt/RISC-V/riscv_llvm
make -j`nproc`
make install
cd ..
rm -R build

