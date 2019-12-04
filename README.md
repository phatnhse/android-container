## Lightweight Android Container

#### First attempt: [Project Sunflower](https://github.com/android/sunflower)
> A gardening app illustrating Android development best practices with Android Jetpack.

Sunflower is currently configurated with `gradle-5.4.1` and `Android Build Tools v28`

Build the docker image that works for this project:
```shell
docker build \
--build-arg GRADLE_VERSION=5.4.1 \
--build-arg ANDROID_SDK_VERSION=28 \
--build-arg EMULATOR_NAME=test \
-t android-container:28-5.4.1 .
```

Clone and cd to the project dir: `git clone https://github.com/android/sunflower && cd sunflower/`

Start to build the project
```shell
docker run --privileged -it --rm -v $PWD:/data android-container:28-5.4.1 \
bash -c ". /start.sh && gradlew connectedAndroidTest -p /data"
```

Here is result that I observed on my terminal
```shell
> Task :app:connectedDebugAndroidTest

com.google.samples.apps.sunflower.PlantDetailFragmentTest > testShareTextIntent[test(AVD) - 9] SKIPPED 

08:44:46 V/InstrumentationResultParser: INSTRUMENTATION_RESULT: stream=
08:44:46 V/InstrumentationResultParser: 
08:44:46 V/InstrumentationResultParser: Time: 2.872
08:44:46 V/InstrumentationResultParser: 
08:44:46 V/InstrumentationResultParser: OK (11 tests)
08:44:46 V/InstrumentationResultParser: 
08:44:46 V/InstrumentationResultParser: 
08:44:46 V/InstrumentationResultParser: INSTRUMENTATION_CODE: -1
08:44:46 V/InstrumentationResultParser: 
08:44:46 I/XmlResultReporter: XML test result file generated at /data/app/build/outputs/androidTest-results/connected/TEST-test(AVD) - 9-app-.xml. Total tests 12, passed 11, ignored 1, 
08:44:46 V/ddms: execute 'am instrument -w -r   com.google.samples.apps.sunflower.test/androidx.test.runner.AndroidJUnitRunner' on 'emulator-5554' : EOF hit. Read: -1
08:44:46 V/ddms: execute: returning
08:44:46 V/ddms: execute: running pm uninstall com.google.samples.apps.sunflower.test
08:44:46 V/ddms: execute 'pm uninstall com.google.samples.apps.sunflower.test' on 'emulator-5554' : EOF hit. Read: -1
08:44:46 V/ddms: execute: returning
08:44:46 V/ddms: execute: running pm uninstall com.google.samples.apps.sunflower
08:44:46 V/ddms: execute 'pm uninstall com.google.samples.apps.sunflower' on 'emulator-5554' : EOF hit. Read: -1
08:44:46 V/ddms: execute: returning

Deprecated Gradle features were used in this build, making it incompatible with Gradle 6.0.
Use '--warning-mode all' to show the individual deprecation warnings.
See https://docs.gradle.org/5.4.1/userguide/command_line_interface.html#sec:command_line_warnings
```

Cool, it works!
