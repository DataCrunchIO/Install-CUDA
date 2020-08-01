#!/bin/bash

#Check distro compatibility
if [[ $(lsb_release -rs) == "18.04" || $(lsb_release -rs) == "20.04" ]]; then

       echo "Compatible Ubuntu version"
else
       echo "This script was made for Ubuntu 18.04 or 20.04"
fi

if (( $EUID != 0 )); then
    echo "Please run as root."
    exit
fi

#Choose CUDA version:
PS3='Please choose what version of CUDA you wish to install: '
options=("CUDA 10.2" "CUDA 11.0" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CUDA 10.2")
            mkdir ~/cuda_tmp/
            wget http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run -O ~/cuda_tmp/cuda.run
            break
            ;;
        "CUDA 11.0")
            mkdir ~/cuda_tmp/
            wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda_11.0.2_450.51.05_linux.run -O ~/cuda_tmp/cuda.run
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

#Install prerequisites:
sudo apt update
sudo apt install -y build-essential gcc-multilib dkms

chmod +x ~/cuda_tmp/cuda.run

#Start NVidia installer
echo "Starting CUDA driver installer, this will take some time."

sudo ~/cuda_tmp/cuda.run --silent --driver --toolkit

sudo bash -c "echo /usr/local/cuda/lib64/ > /etc/ld.so.conf.d/cuda.conf"

sudo ldconfig

FILE=/etc/rc.local
if [ -f "$FILE" ]; then
    echo "$FILE exists. Did not modify"
else 
    echo '#!/bin/bash' | sudo tee /etc/rc.local
    echo 'nvidia-smi -pm 1' | sudo tee -a /etc/rc.local
    echo 'nvidia-smi -e 0' | sudo tee -a /etc/rc.local
    echo 'exit 0' | sudo tee -a /etc/rc.local
fi

sudo chmod +x /etc/rc.local
sudo /etc/rc.local


echo "Driver and CUDA installed. Please check 'nvidia-smi' to confirm."
echo "Thank you for using DataCrunch.io's low-cost GPU servers!"

#cleanup
rm -rf ~/cuda_tmp
function finish {
    rm -rf $0
}

trap finish EXIT
