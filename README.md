# Build a Lightweight Docker Container For Android Testing

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-info-blue.svg)](https://hub.docker.com/r/codecaigicungduoc/android-container/)
[![Docker Stars](https://img.shields.io/docker/stars/thyrlian/android-sdk.svg)](https://hub.docker.com/r/codecaigicungduoc/android-container/)
[![Docker Pulls](https://img.shields.io/docker/pulls/thyrlian/android-sdk.svg)](https://hub.docker.com/r/codecaigicungduoc/android-container/)
[![Build Status](https://travis-ci.com/fastphat/android-container.svg?branch=master)](https://travis-ci.com/fastphat/android-container)

# Goals
* No Android Studio/GUI applications required.
* Android emulator runs on a Docker container.
* Accelerates build speed and stabilize testing process, especially UI Tests.
* Performance boost with Gradle dependencies and distribution caching.

# Release notes
Change logs can be found [here](https://github.com/fastphat/android-container/blob/master/release-notes.md)  

# Remarks
* No additional ARG(s) need to be provided in order to run this image.     
* Linux only. MacOS/Window or any solution which uses VirtualBox to embed Docker can't run x86 emulator because [nested virtualization](https://www.virtualbox.org/ticket/4032) is yet to support. In the contrary, ARM CPU is host machine independent, which can run anywhere, however _it was deprecated and extremely slow to boot_.  
* In the scope of this repo, x86 Emulator is chosen as default startup emulator since it is [10x faster](https://stackoverflow.com/questions/2662650/making-the-android-emulator-run-faster) than ARM. _KVM & nested virtualization will be needed_ so Linux-based OS as host system is required, especially if you want to build a CI machine with this image.    
* If you're planning to host this image on cloud, make sure you can access KVM and nested virtualization is available to use. 
     - AWS provides [bare
          metal](https://aws.amazon.com/about-aws/whats-new/2019/02/introducing-five-new-amazon-ec2-bare-metal-instances/)
          instances that provide access to KVM.
     - Azure: Follow these
          [instructions](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nested-virtualization)
          to enable nested virtualization.
     - GCE: Follow these
          [instructions](https://cloud.google.com/compute/docs/instances/enable-nested-virtualization-vm-instances)
          to enable nested virtualization.
 
# Quick start
 
We'll try to build and run E2E testing with project [Sunflower](https://github.com/android/sunflower).
 
Step 1: Build image with name & tag: `android-container:sunflower`
 
 ```shell
 docker build -t android-container:sunflower .
 ```
 
Step 2: Clone and go to top level directory of `sunflower`
 
 ```shell
 git clone https://github.com/android/sunflower && cd sunflower/
 ```
 
 Step 3: Run with privileged permission in order to boot emulator on the container, then run gradle tasks (build project and run test suite)
 
 ```shell
 docker run --privileged -it \
 --rm -v $PWD:/data -v gradle-cache:/cache android-container:sunflower \
 bash -c '. /start.sh && /data/gradlew test -p /data'
 ```

If you want to run UI test, make sure KVM is enable and run this gradle task `connectedAndroidTest` (See section #Emulator below)
```shell
/data/gradlew test connectedAndroidTest -p /data
```
 
# Gradle
You can either execute Gradle Wrapper or Local Installation but first option is [more preferable](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
> In a nutshell you gain the following benefits:
>  * Standardizes a project on a given Gradle version, leading to more reliable and robust builds.
>  * Provisioning a new Gradle version to different users and execution environment (e.g. IDEs or Continuous Integration servers) is as simple as changing the Wrapper definition. 


### Get the idea of Gradle Wrapper
Gradle wrapper is a script that allow you to run the build with predefined version and settings. The generated Wrapper properties file, `gradle/wrapper/gradle-wrapper.properties`, stores the information about the Gradle distribution.

![gradle wrapper properties](https://github.com/fastphat/android-container/blob/master/images/gradle-wrapper.png?raw=true)

Wanna use newer version? Grab one at [here](https://services.gradle.org/distributions/) and update `distributionUrl` accordingly. 

### Speed up build with Gradle Caching
By default, all files downloaded under docker container doesn't persist if the container is removed. 
Therefore, they will be re-downloaded in every build. 
However, Docker offers a solution called [Volume](https://docs.docker.com/storage/). 
It is typically directories or files on host filesystem and can be accessible from both container and host machine.
You just need to define a location where the volume references to and let it take care the rest.
Consider this following script and image:

```
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME
```

<img src="https://github.com/fastphat/android-container/blob/master/images/docker-volume.png?raw=true" width="350px" /> <br/>  


You can always check where the volumes are located and how they work:

- On Macos: 
```shell
~/Library/Containers/com.docker.docker/Data/vms/0/tty
```

- On Linux: 
```shell
~/var/lib/docker/volumes
```

- To list all volumes are being use: 
```shell
docker volume ls
```

- To get all properties of a volume:
```shell 
docker volume inspect [volume_id]
```

### Non-cached vs cached gradle dependencies

In some circumstances, you will see this one is huge improvement, especially when a project has used ton of dependencies. Let's see the different between cached and non-cached gradle for Sunflower project.   

```shell
BUILD SUCCESSFULL in 4m 25s
...
...
BUILD SUCCESSFULL in 55s 
``` 

![build time comparison](https://github.com/fastphat/android-container/blob/master/images/build-time.png?raw=true)

# Install missing android sdk packages
To get full list of install SDK packages, run:
```shell script
sdkmanager  --list | awk '/Installed packages/{flag=1; next} /Available Packages/{flag=0} flag' | awk '{ print $1  }'
```
The output will look like this 
```shell script
Path
-------
build-tools;27.0.3
build-tools;28.0.3
cmake;3.10.2.4988404
emulator
extras;android;m2repository
extras;google;m2repository
ndk-bundle
ndk;21.0.6113669
patcher;v4
platform-tools
...
```

Copy required packages to `android-packages` file. Remember to add new line for each package.
```
cmake;3.10.2.4988404
ndk;21.0.6113669
```

# Android Emulator
<img src="https://github.com/fastphat/android-container/blob/master/images/arm.png?raw=true" width="600px" />

If you're familiar with Android Studio, you definitely experience this warning when booting ARM emulators. They were old and deprecated since Android SDK 25. In the contrary, x86 emulators are 10x faster, but it needs hardware acceleration to run (HAXM on Mac & Windows, QEMU on Linux). On Docker, you will also need `Nested Virtualization`, which is not available on Virtual Box. So Linux-based OS is recommended in order to make it compatible with this image.   

### Check the availability of running android emulator in docker container
The script below simply checks if kvm & nested virtualization is supported. 

```shell
function check_kvm() {
    cpu_support_hardware_acceleration=$(grep -cw ".*\(vmx\|svm\).*" /proc/cpuinfo)
    kvm_support=$(kvm-ok)
    if [ "$cpu_support_hardware_acceleration" != 0 ] && [ "$kvm_support" != *"NOT"* ]; then
      echo 1
    else
      echo 0
    fi
}
```

### Reduce flaky tests
You can turn off following animations by using `adb shell` ( these can be found in developer options )
* Window animation scale
* Transition animation scale
* Animation duration scale

```shell
function disable_animation() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}

```

You can also disable keyboard or customize default locale language

```shell
adb shell settings put secure show_ime_with_hard_keyboard 0 
adb shell am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE EN

```

### Emulator startup options
Unlike `adb`, you can only specify emulator options when starting it, not later on. Consider following command & options: 

```shell
emulator -avd ${EMULATOR_NAME} -no-window -no-boot-anim -wipe-data -no-snapshot -gpu off -accel auto -memory 2048 -skin 1440x2880
```

| Option                   | Description                                                                                                                                         |
|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| -no-boot-anim            | Disable the boot animation                                                                                                                          |
| -acel auto               | Determine automatically if acceleration is supported and use it when possible                                                                       |
| -no-window -gpu off      | This option is useful when running the emulator on headless servers. <br>You'll still be able to access the emulator through adb or the console         |
| -skin 1440x2880          | In case you want the screen has more room, especially with list of items. <br>Use it at your risk, it would be better to support different screen sizes |
| -memory 2048             | Building CI Server with 4GB physical RAM, why not?                                                                                                  |
| -wipe-data               | Delete user data and fresh start emulator                                                                                                           |
| -no-snapshot             | Start app from initial state and delete snapshot data when emulator is closed                                                                      |

# License

Released under the [Apache License](https://www.apache.org/licenses/LICENSE-2.0). 

Read the [LICENSE](https://raw.githubusercontent.com/fastphat/android-container/master/LICENSE) for more details.