#!/bin/bash

function check_kvm() {
  cpu_support_hardware_acceleration=$(grep -cw ".*\(vmx\|svm\).*" /proc/cpuinfo)
  if [ "$cpu_support_hardware_acceleration" != 0 ]; then
    echo 1
  else
    echo 0
  fi
}

function config_emulator_settings() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
  adb shell "settings put global always_finish_activities 1"
  adb shell "settings put secure show_ime_with_hard_keyboard 0"
  adb shell "am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE EN"
}

function wait_emulator_to_be_ready() {
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
  emulator -avd "${EMULATOR_NAME_x86}" -verbose -no-boot-anim -wipe-data -no-snapshot -no-window -gpu off &
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

function start_emulator_if_possible() {
  check_kvm=$(check_kvm)
  if [ "$check_kvm" != "1" ]; then
    echo "run emulator failed, nested virtualization is not supported"
    return
  else
    wait_emulator_to_be_ready
    sleep 1
    config_emulator_settings
  fi
}

start_emulator_if_possible
