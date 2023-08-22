FROM sitio/chipyard:1.6.2


# Setup required package repositories
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt install software-properties-common lsb-release \
 # Add Python 3.9 repository
 && add-apt-repository ppa:deadsnakes/ppa -y \
 # Add latest CMake (newer than 3.14) repository
 && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
 && apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"

# install dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
 bc \
 clang \
 cmake \
 flang-7 \
 gfortran \
 git \
 gnuplot \
 libopenblas-dev \
 lld \
 nano \
 ninja-build \
 python3.9 \
 wget


WORKDIR /root/builds

# prepare MLIR build directories
RUN git clone --depth 1 -b release/11.x https://github.com/llvm/llvm-project.git \
 && mkdir mlir-build

# set FIR frontend build information
ARG FIR_BRANCH='fir-dev'
ARG FIR_COMMIT='8abd290c2c791c26cd1237b218def1b85998d403'
ARG FIR_REPO='https://github.com/flang-compiler/f18-llvm-project.git'

# prepare FIR frontend build directories
RUN git clone --depth 1 -b ${FIR_BRANCH} ${FIR_REPO} \
 && cd f18-llvm-project \
 && git fetch --depth=1 origin ${FIR_COMMIT} \
 && git reset --hard FETCH_HEAD \
 && cd .. && mkdir -p fir-build


WORKDIR /root/builds/mlir-build

# configure and build MLIR 11
RUN cmake -G Ninja ../llvm-project/llvm \
          -DLLVM_ENABLE_PROJECTS="mlir" \
          -DLLVM_TARGETS_TO_BUILD="X86" \
          -DCMAKE_BUILD_TYPE=Release \
          -DLLVM_ENABLE_ASSERTIONS=ON \
          -DCMAKE_C_COMPILER=clang \
          -DCMAKE_CXX_COMPILER=clang++ \
          -DLLVM_ENABLE_LLD=ON
RUN ninja install


WORKDIR /root/builds/fir-build

# configure FIR frontend build
RUN cmake ../f18-llvm-project/llvm \
 -G Ninja \
 -DLLVM_ENABLE_PROJECTS="clang;flang" \
 -DLLVM_TARGETS_TO_BUILD="X86;RISCV" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_C_COMPILER=clang \
 -DCMAKE_CXX_COMPILER=clang++ \
 -DCMAKE_CXX_STANDARD=17 \
 -DLLVM_BUILD_TOOLS=On

# NOTE: the first build attempt usually fails, but continuing the build tends
#       to result in a sucessful build. Hence the loop below. Also, increasing
#       the number of parallel jobs can cause high memory usage (> 32G).
#
# build FIR frontend
RUN RESULT=1; \
    while [ $RESULT != 0 ]; \
    do ninja -j 6; RESULT=$?; \
    done;

# add FIR binaries to default PATH
RUN ln -s $(pwd)/bin/bbc  /usr/local/bin/bbc \
 && ln -s $(pwd)/bin/tco  /usr/local/bin/tco

# set path to FIR libraries
ENV FIR_LIB='/root/builds/fir-build/lib'


WORKDIR /root/builds


# prepare SMR source code
COPY ./pat-compiler ./pat-compiler
RUN mkdir -p ./pat-compiler/build


WORKDIR /root/builds/pat-compiler/build


# configure and build SMR frontend
RUN cmake -G Ninja .. \
          -DCMAKE_BUILD_TYPE=Release \
          -DMLIR_DIR=/root/builds/mlir-build/lib/cmake/mlir \
          -DCMAKE_C_COMPILER=clang \
          -DCMAKE_CXX_COMPILER=clang++
RUN ninja SMR

# add SMR binary to default PATH
RUN ln -s $(pwd)/bin/SMR  /usr/local/bin/SMR



WORKDIR /root/chipyard/generators/gemmini


# add repository resources to container
ADD ./ /root/smr-gemmini

# update gemmini repository, set custom parameters and build spike simulator
ARG PARAMS_PATH="software/gemmini-rocc-tests/include/gemmini_params.h"
RUN git fetch && git checkout v0.6.4 \
 && git submodule update \
 && cp /root/smr-gemmini/libs/gemmini_params.h ${PARAMS_PATH} \
 && ./scripts/build-spike.sh


WORKDIR /root/smr-gemmini

# patch gnuplot shared lib (error observed in some cases)
RUN strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

# install polybench fortran benchmark
ARG POLYBECH_FORTRAN="http://web.cse.ohio-state.edu/~pouchet.2/software/polybench/download/polybench-fortran-1.0.tar.gz"
RUN wget -q -nc --no-check-certificate ${POLYBECH_FORTRAN} \
 && tar -x -f polybench-fortran-1.0.tar.gz && rm polybench-fortran-1.0.tar.gz

# patch polybench fortran to compile with clang
RUN for i in patches/*.patch; do patch -p0 < $i; done;

# reset workdir (otherwise the entrypoint.sh file won't be found)
WORKDIR /root

# use chipyard entrypoint
ENTRYPOINT [ "chipyard/scripts/entrypoint.sh" ]
