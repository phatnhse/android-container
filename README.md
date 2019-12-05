# Lightweight Android Container

A lightweight Android Container to isolate the testing process. 

* No Android Studio/GUI applications require.
* Android emulator running on Docker container.
* Ability to cache dependencies for later build.
* Wipeout everything after the process.

### Motivation
As the team is scaling up, increase CI machine power should be considered as a must! 

By using docker container, it's easier to run multiple runners on difference branches hence speed up the development as well as productivity. 

It's easy to scale, maintain and stabilize the testing processes.

### Build Steps 

The sample that we're going to use is [Sunflower](https://github.com/android/sunflower).

> A gardening app illustrating Android development best practices with Android Jetpack.

Sunflower is built and compiled with `gradle-5.4.1`, `Android API 28` and `Build tools v28.0.3`. 

To run docker image that works for this project, run: 

```shell
docker build \
--build-arg GRADLE_VERSION=5.4.1 \
--build-arg ANDROID_API_LEVEL=28 \
--build-arg ANDROID_BUILD_TOOLS_LEVEL=28.0.3 \
--build-arg EMULATOR_NAME=test \
-t android-container:sunflower .
```

Then clone and go to top level directory: `git clone https://github.com/android/sunflower && cd sunflower/`

Build project and run unit & UI tests:

```shell
docker run --privileged -it --rm -v $PWD:/data android-container:sunflower bash -c ". /start.sh && gradlew test && gradlew connectedAndroidTest -p /data"
```

Observe the result:

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

BUILD SUCCESSFUL in 2m 4s
66 actionable tasks: 6 executed, 60 up-to-date

```

Cool, it just takes 2.872 seconds to run 11 UI tests and everything is wiped out after testing!