sudo apt-get update
sudo apt-get install verilator scala openjdk-8-jdk
sudo apt-get install -y sbt cmake
sudo apt-get install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev vim default-jdk default-jre

git clone https://github.com/ucb-bar/chipyard.git
cd chipyard
git checkout 1.7.1
./scripts/init-submodules-no-riscv-tools.sh


./scripts/build-toolchains.sh riscv-tools

source env.sh

cd sims/verilator/

make CONFIG=RocketConfig VERILATOR_THREADS=16 VERILATOR_FST_MODE=1 





conda install -n base conda-lock=1.4
conda activate base

git clone https://github.com/ucb-bar/chipyard.git
cd chipyard
git checkout 1.10.0

./build-setup.sh riscv-tools

source env.sh

cd sims/verilator/

make CONFIG=RocketConfig VERILATOR_THREADS=16 VERILATOR_FST_MODE=1 