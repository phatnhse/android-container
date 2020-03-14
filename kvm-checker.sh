cpu_support_hardware_acceleration=$(grep -cw ".*\(vmx\|svm\).*" /proc/cpuinfo)
kvm_support=$(kvm-ok)
if [ "$cpu_support_hardware_acceleration" != 0 ] && [ "$kvm_support" != *"NOT"* ]
then echo 1
else echo 0
fi