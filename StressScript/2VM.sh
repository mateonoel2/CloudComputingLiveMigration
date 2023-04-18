VBoxManage modifyvm ubuntu1 --teleporter off
VBoxManage modifyvm ubuntu2 --teleporter off
VBoxManage modifyvm ubuntu3 --teleporter off
VBoxManage modifyvm ubuntu4 --teleporter off
VBoxManage startvm ubuntu1
VBoxManage startvm ubuntu2
echo "SIMULATION BEGUIN"
sleep 60

echo "start stress"
# Load all CPU's to 50% and RAM to 50% for 30 seconds
stress-ng -c 8 --cpu-load 50 -m 1 --vm-bytes $(free -g | awk '/Mem:/ {print int($2*0.5)}')G --vm-keep --timeout 30
echo "stress finished"

# Descanzar 15s
sleep 30

echo "start stress"
# Load all CPU's to 50% and RAM to 50% for 30 seconds
stress-ng -c 8 --cpu-load 50 -m 1 --vm-bytes $(free -g | awk '/Mem:/ {print int($2*0.5)}')G --vm-keep --timeout 30
echo "stress finished"

# Descanzar 15s
sleep 30

echo "start stress"
# Load all CPU's to 50% and RAM to 50% for 30 seconds
stress-ng -c 8 --cpu-load 50 -m 1 --vm-bytes $(free -g | awk '/Mem:/ {print int($2*0.5)}')G --vm-keep --timeout 30
echo "stress finished"
echo "SIMULATION END"