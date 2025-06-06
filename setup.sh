#!/bin/bash

# This scrips performs a number of setup steps for the overall project.

rp_hostname=""

# parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --rp-hostname)
            rp_hostname="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# Make sure rp_hostname is set
if [[ -z "$rp_hostname" ]]; then
    echo "Error: --rp-hostname argument is required."
    exit 1
fi

# 1. Copy marcos_client/local_config.py.example to marcos_client/local_config.py and ip_address = "${rp_hostname}"
if [[ -n "$rp_hostname" ]]; then
    echo "Setting up marcos_client/local_config.py with rp_hostname: $rp_hostname"
    cp marcos_client/local_config.py.example marcos_client/local_config.py
    sed -i "s/#ip_address = \"localhost\"/ip_address = \"$rp_hostname\"/" marcos_client/local_config.py

    # Uncomment #fpga_clk_freq_MHz = 122.88 # RP-122
    sed -i "s/#fpga_clk_freq_MHz = 122.88 # RP-122/fpga_clk_freq_MHz = 122.88 # RP-122/" marcos_client/local_config.py

    # uncomment #grad_board = "gpa-fhdo"
    sed -i "s/#grad_board = \"gpa-fhdo\"/grad_board = \"gpa-fhdo\"/" marcos_client/local_config.py
fi

# 2. Copy all the MaRGE/configs/*py.copy to MaRGE/configs/*py
for file in MaRGE/configs/*.py.copy; do
    if [[ -f "$file" ]]; then
        base_name=$(basename "$file" .copy)
        cp "$file" "MaRGE/configs/$base_name"
    fi
done

# In MaRGE/configs/hw_config.py, set the following:
# - set the bash_path = "/usr/bin/bash"
sed -i "s|bash_path = .*|bash_path = \"/usr/bin/bash\"|" MaRGE/configs/hw_config.py
# - set the rp_ip_address =  = "${rp_hostname}"
sed -i "s|rp_ip_address = \".*\"|rp_ip_address = \"$rp_hostname\"|" MaRGE/configs/hw_config.py

# Validate that it is possible to SSH to the RP
ssh root@"$rp_hostname" "uname -n" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "SSH connection to $rp_hostname failed; please check the IP address and try to connect manually."
    exit 1
fi

# Backup marcos_extras/copy_bitstream.sh
backup_file="marcos_extras/copy_bitstream.sh.bak"
if [[ -f "$backup_file" ]]; then
    echo "Backup file $backup_file already exists. Skipping backup."
else
    cp marcos_extras/copy_bitstream.sh "$backup_file"
fi

# Copy local copy_bitstream.sh to marcos_extras
cp copy_bitstream.sh marcos_extras/copy_bitstream.sh

# Now let's set up the MaRCoS server
echo "Setting up MaRCoS server..."
current_dir=$(pwd)
cd marcos_extras || exit 1
./marcos_setup.sh ${rp_hostname} rp-122 || {
    echo "Failed to set up MaRCoS server."
    exit 1
}
cd "$current_dir" || exit 1

echo "Setup completed successfully."