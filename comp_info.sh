#!/bin/bash


exec > "$(dirname "$0")/output.txt"

function open_txt_file(){
    if command -v open >/dev/null 2>&1; then
        open "$(dirname "$0")/output.txt"
    else
        echo "The 'open' command is not available on this system."
    fi    
}


# Get the IP address
ip_address=$(ifconfig en0 | awk '/inet / {print $2}')

# Make an HTTP request to retrieve the public IP address
public_ip=$(curl -s https://api.ipify.org)

# Get current User
current_user=$(whoami)

# Get the CPU information using sysctl
cpu_info=$(sysctl -n machdep.cpu.brand_string)

# Run system_profiler command and store the output in a variable
profiler_output=$(system_profiler SPHardwareDataType)

# Extract specific information using text processing
serial_number=$(echo "$profiler_output" | awk '/Serial Number/ {print $NF}')
model_name=$(echo "$profiler_output" | awk -F ': ' '/Model Name/ {print $2}')
model_identifier=$(echo "$profiler_output" | awk '/Model Identifier/ {print $NF}')
model_number=$(echo "$profiler_output" | awk '/Model Number/ {print $NF}')
chip=$(echo "$profiler_output" | awk '/Chip/ {print $NF}')
memory=$(echo "$profiler_output" | awk -F ': ' '/Memory/ {print $NF}')

# Add more fields and filters as needed
live_admins=`dscl . read /groups/admin GroupMembership | cut -d " " -f 2-`

# Example: if you wish to add a third admin called 'admin' change below to
# declare -a my_admins=('root' 'administrator' 'admin')

declare -a my_admins=('root' 'administrator')
declare -a found_admins=()
function check_admin {

        while [ $# -ne 0 ]
        do
                if [[ ! " ${my_admins[@]} " =~ " $1 " ]]; then
                        found_admins+=($1)
                fi
                shift
        done
}

check_admin $live_admins

#Users command
output=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]')

# Extract only the usernames using awk
usernames=$(echo "$output" | awk -F ": " '/name:/ { printf "%s ", $2 }')


# Print the extracted information
echo ""
echo "  Mac Info"
echo "  -------- "

echo "      Serial Number   : $serial_number"
echo "      Model Name      : $model_name"
echo "      Model Identifier: $model_identifier"
echo "      Model Number    : $model_number"
echo "      CPU             : $chip"
echo "      Memory          : $memory"
echo "      IP Address      : $ip_address"
echo "      Public IP       : $public_ip"
echo "      User            : $current_user"
echo "      Local Admins    : ${found_admins[@]}"
echo "      Users           : $usernames"
echo ""


open_txt_file

exit 0




