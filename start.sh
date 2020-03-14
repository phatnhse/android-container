#!/bin/bash

function wait_emulator_to_be_ready() {
  cpu_support_hardware_acceleration=$(grep -cw ".*\(vmx\|svm\).*" /proc/cpuinfo)
  kvm_support=$(kvm-ok)

  emulator_name=${EMULATOR_NAME_ARM}
  if [ "$cpu_support_hardware_acceleration" != 0 ] && [ "$kvm_support" != *"NOT"* ]; then
    emulator_name=${EMULATOR_NAME_x86}
  fi

  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
  emulator -avd "${emulator_name}" -no-boot-anim -no-window -gpu off -accel auto -skin 1440x2880 &
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi
  done
}

function disable_animation() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}

wait_emulator_to_be_ready
sleep 1
disable_animation
