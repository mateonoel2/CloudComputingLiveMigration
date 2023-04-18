start_time=$(date +%s)

time_limit=300

while true; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    # Get the total and used memory information from the 'free' command
    memory_info=$(free | grep Mem)
    total_memory=$(echo "$memory_info" | awk '{print $2}')
    used_memory=$(echo "$memory_info" | awk '{print $3}')

    # Calculate the memory usage percentage
    memory_percentage=$((used_memory * 100 / total_memory))

    #Calculate cpu percentage
    cpu_percentage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    if (( $cpu_percentage > 50 )) && (( $memory_percentage > 50 )); then
        echo "Stress detected: CPU>50 and RAM>50"
        echo "CPU = $cpu_percentage and RAM = $memory_percentage"

        vm_list=$(VBoxManage list vms)
        # Filter out the running virtual machines
        non_running_vms=""
        while IFS= read -r vm; do
        vm_name=$(echo "$vm" | awk -F '"' '{print $2}')
        if ! VBoxManage showvminfo "$vm_name" | grep -q "State:\s*running"; then
            non_running_vms+="$vm_name "
        fi
        done <<< "$vm_list"

        # Check if there are any non-running virtual machines
        if [[ -z "$non_running_vms" ]]; then
        echo "No non-running virtual machines found."
        exit 1
        fi

        #select first non-running vm
        # Select the first non-running virtual machine
        selected_vm=$(echo "$non_running_vms" | awk '{print $1}')

        running_vms=$(VBoxManage list runningvms)
        
        selected_vm2=$(echo "$running_vms" | awk -F '"' '{print $2}' | head -n 1)

        #migrate
        echo "migration to VM $selected_vm"
        VBoxManage modifyvm $selected_vm --teleporter on --teleporterport 6000
        VBoxManage startvm $selected_vm &
        sleep 10

        echo "migration from VM $selected_vm2"
        VBoxManage controlvm $selected_vm2 teleport --host localhost --port 6000

        #kill stress process to simulate real migration

        # Find the PID of the stress-ng process
        stress_ng_pid=$(pgrep stress-ng)

        # Check if stress-ng is currently running
        if [[ -z "$stress_ng_pid" ]]; then
        echo "No stress-ng process found. Nothing to terminate."
        exit 1
        fi

        # Send a termination signal to the stress-ng process
        kill "$stress_ng_pid"
        
        echo "stress ng killed"
        echo "successfull live migration simulation" 
    fi 

    if(($elapsed_time >= $time_limit)); then
        echo "Simulation completed"
        break
    fi

    sleep 1
done