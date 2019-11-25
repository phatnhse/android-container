### android-container

- OS: `Ubuntu 18.04`
- Image: `ubuntu` with tag `latest` (18.04)
- Start ubuntu container: `docker run --privileged -dit --name android-container ubuntu`
- Attach to the container: `docker exec -it android-container bash`

### Install helpful dependencies
```
apt update && apt install -y libc6-dev-i386 lib32z1 openjdk-8-jdk vim unzip libpulse-dev gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
```

### Set up Android environment (without Android Studio)
- Download command tools only : `wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -P /tmp`
- Unzip it in /opt: `unzip -d /opt/android /sdk-tools-linux-4333796.zip`
- set up bash profile: 
```
echo 'export ANDROID_HOME=/opt/android' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> ~/.bashrc
source ~/.bashrc
```
- Let's check by this commander:
```
sdkmanager 
avdmanager
emulator
``` 
- If you face this error: `repositories.cfg could not be loaded`, then resolve it by simply create empty file: `touch ~/.android/repositories.cfg
- Update sdkamanger: sdkmanager --update
- Install build tool: `yes Y | sdkmanager --install "platform-tools" "system-images;android-28;google_apis;x86" "platforms;android-28" "build-tools;28.0.3"`
- Accept licenses: `sdkmanager --licenses`
- Install avd: `echo "no" | avdmanager --verbose create avd --force --name "test" --device "pixel" --package "system-images;android-28;google_apis;x86" --tag "google_apis" --abi "x86"`
- Let's add `platform-tools` to the bash file:
 ```
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```
- Double check:
```
emulator -list-avds ### test
adb devices => check all running emulator
```
- If you want to delete any avd: `avdmanager delete avd -n avd_name`

### Android Virtual Device
- export LD_LIBRARY_PATH: 
```
echo 'export LD_LIBRARY_PATH=${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib' >> ~/.bashrc
source ~/.bashrc
emulator -avd test -no-audio -no-boot-anim -no-window -accel on -gpu off &
```
- If you face this issue: `Missing emulator engine program for 'x86' CPUS` 
```
Please add `$ANDROID_HOME/emulator` before `$ANDROID_HOME/tools` (https://stackoverflow.com/questions/26483370/android-emulator-error-message-panic-missing-emulator-engine-program-for-x86)
source ~/.bashrc
```

- If you want to stop all emulator: `adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done`

### Install gradle
https://linuxize.com/post/how-to-install-gradle-on-ubuntu-18-04/

- Download gradle-5.4.1: `wget https://services.gradle.org/distributions/gradle-5.4.1-bin.zip -P /tmp`
- Unzip it in `/opt/gradle`: `unzip -d /opt/gradle /tmp/gradle-5.4.1-bin.zip`
- Export the environment variables:
```
echo 'export GRADLE_HOME=/opt/gradle/gradle-5.4.1' >> ~/.bashrc
echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> ~/.bashrc   
source ~/.bashrc
```
- Let's go to bin of gradle: `cd $GRADLE_HOME/bin`

### Install gradlew
- Let create a directory in /opt: mkdir /opt/gradlew
- cd /opt/gradlew: 
- Install gradle wrapper: `gradle wrapper --gradle-version 5.4.1 --distribution-type all`
- Download dependencies for gradle: `gradle wrapper` 
- Test it again: 
```
./gradlew
``` 
- Let's have it in `.bashrc`: `echo 'export PATH=$PATH:/opt/gradlew' >> ~/.bashrc`

### Create volume and include the project directory into `android-container`
- Add your source code into container by creating volume: `docker run --privileged -it --rm -v $PWD:/data phatphat bash`
- Run test on that project: `gradlew build -p /data`

### Final Step
- Wait for the emulator to be fully loaded
```
function wait_emulator_to_be_ready () {
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
```
- Let turn off animation to avoid flaky test
```
adb shell "settings put global window_animation_scale 0.0"
adb shell "settings put global transition_animation_scale 0.0"
adb shell "settings put global animator_duration_scale 0.0"
```