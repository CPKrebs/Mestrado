wget https://github.com/xianyi/OpenBLAS/releases/download/v0.3.20/OpenBLAS-0.3.20.tar.gz




sed -i 's/syscall(SYS_mbind, addr, len, mode, nodemask, maxnode, flags)/0/g' common_linux.h

CC="riscv64-unknown-linux-gnu-gcc \
  -march=rv64gc -Wa,-march=rv64gcxhwacha \
  -mcmodel=medany \
  --sysroot=${RISCV}/sysroot"


FC="riscv64-unknown-linux-gnu-gfortran \
  -march=rv64gc -Wa,-march=rv64gcxhwacha \
  -mcmodel=medany \
  --sysroot=${RISCV}/sysroot" \


make -j`nproc`\
  USE_THREAD=0 \
  USE_OPENMP=0 \
  BUILD_STATIC_LIBS=1 \
  HOSTCC=gcc \
  CC=$CC \
  FC=$FC \
  TARGET=RISCV64_GENERIC