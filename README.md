# Build a Lightweight Docker Container For Android Testing

[![Build Status](https://travis-ci.com/fastphat/android-container.svg?branch=master)](https://travis-ci.com/fastphat/android-container)

# Goals

* No Android Studio/GUI applications required.
* Android emulator runs on a Docker container.
* Accelerates build speed and stablize testing process, especially UI Tests.
* Has ability to cache Gradle distribution and dependencies.


# Gradle
You can either use Gradle Wrapper or Local Installation to perform desired tasks but IMO, you should choose first option whenever it's because of these following reasons:

* Reliable. Different users get the same build result on a given Gradle version.
* Configurable. Let's say that you want to provision a new version of Gradle to different users and execution environments (IDE, CI machine, etc), you only need to update the config file, Wrapper will take care the rest.


### Understand Gradle Wrapper
Gradle wrapper is simply a script that allow user to run the build with predefined version and settings. These distribution information is stored in `gradle/wrapper/gradle-wrapper.properties`

![gradle wrapper properties](https://github.com/fastphat/android-container/blob/master/images/gradle-wrapper.png?raw=true)

To change the version of Gradle Wrapper, grab one at [https://services.gradle.org/distributions/](https://services.gradle.org/distributions/) and update `distributionUrl`.

### How to cache gradle distribution and build dependencies?
By default all files downloaded under docker container doesn't persist if that container is removed. Therefore, Gradle needs to download it's distribution and build dependencies for every build. 

In order to prevent that behavior, Docker offers a solution called [Volume](https://docs.docker.com/storage/). Volumes are typically directories or files on host filesystem and are accessible from both container and host. That mean they will not be removed after the container is wiped out.

The Gradle cached files are by default located under `GRADLE_USER_HOME`, which is `/`, so you can keep it there and move them to another directory, just make sure to define a volume for that path. 

```
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME
```

![docker volume](https://github.com/fastphat/android-container/blob/master/images/docker-volume.png?raw=true)

Ok. Looks good, for more references, check out these directories to see how things are wired up on host machine:

- On Macos: `screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty`
- On Linux: under `~/var/lib/docker/volumes`

Some useful commands for Docker volume:

* To list all volumes are being use: `docker volume ls`
* To get detailed information of a specific volume, `docker volume inspect [volume_id]`

### Cached Gradle Test Result

The second build only tooks only 55s instead of 4m 25s for doing the same task. In other words, we save more than 3m for redownload Gradle distribution and app dependencies.

![build time comparision](https://github.com/fastphat/android-container/blob/master/images/build-time.png?raw=true)

# Emulator (x86 or ARM)

![warning emulator](https://github.com/fastphat/android-container/blob/master/images/arm.png?raw=true)

You probably see this prompt when booting an ARM-based emulator. They were old and deprecated since Android SDK Level 25. In the contrary, x86 (or x86_64) emulators are 10x faster. However, it requires your host to have hardware acceleration (HAXM on Mac & Windows, QEMU on Linux). 

I won't go too detail about architecture defination but focus more on improving the stability and perfomance of Android Emulator when perfoming UI tests. 

### Auto select right Emulator Arch
The script below simply checks if host system supports Hardware Accelerator and KVM. If the answer is yes, there you go, x86 Emulator. If it is not, let's go with ARM Emulator then.

```shell
  cpu_support_hardware_acceleration=$(grep -cw ".*\(vmx\|svm\).*" /proc/cpuinfo)
  kvm_support=$(kvm-ok)

  emulator_name=${EMULATOR_NAME_ARM}
  if [ "$cpu_support_hardware_acceleration" != 0 ] && [ "$kvm_support" != *"NOT"* ]; then
    emulator_name=${EMULATOR_NAME_x86}
  fi
```

### Avoid Flaky Tests
Long story short: Disable animation when Android emulator is fully loaded and ready to use.

```shell
#!/bin/bash

function wait_emulator_to_be_ready() {
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
  emulator -avd ${EMULATOR_NAME} -no-audio -no-boot-anim -no-window -accel on -gpu off -skin 1440x2880 &
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

```

There are few additional adb commands might suit for you in some cases.

```shell
# Disable soft keyboard
adb shell settings put secure show_ime_with_hard_keyboard 0
# Set the default locale 
adb shell am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE EN

```

### Emulator Startup Options

Here are some basic options for faster booting Emulator. Unlikne adb, you can only specify those when starting the emulator, not later on. Consider this command:


```
emulator -avd ${EMULATOR_NAME} -no-boot-anim -no-window -gpu off -accel auto -memory 2048 -skin 1440x2880
```

* `-no-boot-anim`: Disable the boot animation during emulator startup for faster booting
* `-acel auto`: Determine automatically if acceleration is supported and use it when possible
* `-no-window -gpu off`: This option is useful when running the emulator on servers that have no display. You'll still be able to access the emulator through adb or the console. UI tests result logs normally.
* `-skin 1440x2880`: In case you want the screen has enough room of item views, especially with ListView or RecyclerView. Use it at your risk, it's better to handle them properly. You always have customer using small android phone.
* `-memory 2048`: Specify the physical RAM size from 128 to 4096 MBs, especially suits with high permomance machine. Maximize RAM up to 4GB, why not 💪? 

# Build Steps 

Let's use [Sunflower](https://github.com/android/sunflower) as sample.

Build new Docker Image with name `android-container` and tag `sunflower`:

```shell
docker build -t android-container:sunflower .
```

Clone and go to top level directory of Sunflower project:

```shell
git clone https://github.com/android/sunflower && cd sunflower/
```

Mount `/sunflower` into container as `/data`, use volume `gradle-cache`, which is pointed to `/cache` in the container and run Gradle tasks!

```shell
docker run --privileged -it \
--rm -v $PWD:/data \
-v gradle-cache:/cache \
android-container:sunflower \
bash -c '. /start.sh && /data/gradlew test connectedAndroidTest -p /data'
```