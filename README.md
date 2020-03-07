# Build a Lightweight Docker Container For Android Testing

[![Build Status](https://travis-ci.com/fastphat/android-container.svg?branch=master)](https://travis-ci.com/fastphat/android-container)

# Goals

* No Android Studio/GUI applications required.
* Android emulator runs on a Docker container.
* Has ability to cache dependencies to dramatically reduce build time.


# Gradle
You can either use Gradle Wrapper or Local Installation to perform desired tasks but IMO, you should choose first option whenever it's possible, to gain the following benefits:

* Reliable. Different users get the same build result on a given Gradle version.
* Configurable. Let's say that you want to provision a new version of Gradle to different users and execution environments (IDE, CI machine, etc), imagin how easy it is when people just needs to get the lastest configs, Wrapper will take care the rest.


### Understand Gradle Wrapper
Gradle wrapper is simply a script that allow user to run the build with predefined version and settings. These distribution information is stored in `gradle/wrapper/gradle-wrapper.properties`

![gradle wrapper properties](https://github.com/fastphat/android-container/blob/master/images/gradle-wrapper.png?raw=true)

To change the version of Gradle Wrapper, grab one at [https://services.gradle.org/distributions/](https://services.gradle.org/distributions/) and update value of `distributionUrl`.

### How to cache gradle distribution and build dependencies?
By default all files downloaded under docker container doesn't persist if that container is removed. Therefore, Gradle needs to download it's distribution and build dependencies for every build. 

In order to prevent that behavior, Docker offers a solution called [Volume](https://docs.docker.com/storage/). Volumes are typically directories or files on host filesystem and are accessible from both container and host machine. That mean they will not be removed after the container is no longer exist.

The Gradle cached files are by default located under `GRADLE_USER_HOME`, which is `/`, so you can persist them in another directory, for instance, `/cache`. See how volume are defined as following:

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

### Test Result

The second build only tooks only 55s instead of 4m 25s for doing the same task. 

![Build time comparision](https://github.com/fastphat/android-container/blob/master/images/build-time.png?raw=true)


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