#!/bin/bash

# Original Vlad Negnevitsky, October 2020
# Modified by Michael Hansen, June 2025 to work with Red Pitaya's 2.0 image

if [[ "$#" -ne 2 || ($2 != "rp-125" && $2 != "rp-122" ) ]]; then
    echo "Usage: ./copy_bitstream.sh IP DEVICE"
    echo "IP: the IP address of your SDRLab/RP"
    echo "DEVICE: your SDRLab/RP hardware, either rp-122 or rp-125"
    echo "Example usage: "
    echo "   ./copy_bitstream.sh 192.168.1.163 rp-122"
    echo "*Warning*: marga bitstream currently only runs on rp-122 for now!"
    exit
fi

rp_hostname=$1
rp_device=$2

# if rp_device is blank, set it to rp-122
if [[ -z "$rp_device" ]]; then
    rp_device="rp-122"
fi

if [[ $rp_device != "rp-122" ]]; then
    echo "Invalid device type: $rp_device. Must be rp-122 or blank."
    exit 1
fi

dirname=$(dirname "$0")

scp ${dirname}/marcos_fpga_${rp_device}.bit.bin root@${rp_hostname}:/tmp/marcos_fpga.bit.bin

ssh root@${rp_hostname} <<EOF
/opt/redpitaya/bin/fpgautil -b /tmp/marcos_fpga.bit.bin
rm /tmp/marcos_fpga.bit.bin
EOF
