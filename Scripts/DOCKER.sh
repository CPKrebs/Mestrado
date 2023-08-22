# Dependencias
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get install containerd.io

apt-cache policy docker-ce
sudo apt install docker-ce 

# Download Docker Gemmini
sudo docker run -it --privileged vnikifor/iiswc-gemmini:ver2 bash

# Download Docker chipyard
sudo docker pull ucbbar/chipyard-image
sudo docker run --name teste -it ucbbar/chipyard-image bash

# Download Docker Projeto
docker pull sitio/smr-gemmini:testing
sudo docker run --name smr-gemmini -it sitio/smr-gemmini:testing bash

sudo docker start smr-gemmini
sudo docker attach smr-gemmini

cd smr-gemmini
bash rv-validate.sh 

#Isso vai gerar os binários CPU only (em smr-gemmini/bin/validate/reference) 
#e os que usam gemmini (em smr-gemmini/bin/validate/gemmini). Ele gera todos menos os SYRK e o BICG.


# Iniciar docker
sudo docker start teste
sudo docker attach teste




# Copiar dados para dentro do Docker
sudo docker cp AA_teste.c \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/bareMetalC 

sudo docker cp AA_teste_CPU.c \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/bareMetalC && sudo docker cp AA_teste_ACC.c \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/bareMetalC 



# Copiar dados para fora do Docker 
sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste_CPU-baremetal \
AA_teste_CPU-baremetal16

sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste_ACC-baremetal \
AA_teste_ACC-baremetal8_8




# Copiar e simular
sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste-baremetal \
AA_teste-baremetal && ./aa_SIMULAR.sh

sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste-baremetal \
AA_teste-baremetal && sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste_CPU-baremetal \
AA_teste_CPU-baremetal && sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/AA_teste_ACC-baremetal \
AA_teste_ACC-baremetal && ./aa_SIMULAR.sh

sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/tiled_matmul_ws_full_C-baremetal \
tiled_matmul_ws_full_C && ./aa_SIMULAR.sh



sudo docker cp \
teste:root/chipyard/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/Gemmini_BLAS-baremetal \
Gemmini_BLAS && ./aa_SIMULAR.sh





sudo docker cp \
teste:root/BOOM/chipyard/sims/verilator/simulator-chipyard-GemminiFPMegaBoomConfig \
BOOM-4W_GemminiFP2.0-mod-DOCKER






sudo docker cp main.c teste:root/
sudo docker cp passo.sh teste:root/
sudo docker cp lib.a teste:root/
sudo docker cp Gemmini_BLAS.h teste:root/
sudo docker cp Gemmini_BLAS.o teste:root/
sudo docker cp gemmini_params.h teste:root/

