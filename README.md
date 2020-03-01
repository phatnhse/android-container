# Build a Lightweight Docker Container For Android Testing

# Goals

* No Android Studio/GUI applications required.
* Android emulator runs on a Docker container silently.
* Has ability to cache dependencies to dramatically reduce build time.


# Gradle
You can either use Gradle Wrapper or Local Installation to perform desired tasks but I strongly recommend to use Wrapper to take advantages of version/environment combatability.

### Understand Gradle Wrapper
Gradle wrapper is basically a script that allow user to run the build with predefined version and settings. These distribution information is stored in `gradle/wrapper/gradle-wrapper.properties`

![gradle-wrapper-properties](https://raw.githubusercontent.com/fastphat/android-container/migrate-to-gradle-wrapper/images/gradle-wrapper.png)

### How to cache gradle distribution and build dependencies?
By default all files downloaded under docker container doesn't persist if that container is removed. You can easily test whether the container is no longer exist by `docker ps -a`

So in order to prevent gradle from downloading again and again, Docker offer a solution called [Volume](https://docs.docker.com/storage/). Volumes are typically directories or files on host filesystem and are accessible from both container and host machine. 

Says that the cached files are by default located under `GRADLE_USER_HOME`, you can persist them by creating and change target location to new responsible . With that, you can easily define the cache will be use in `Dockerfile`

```
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME
```

![Image](https://github.com/fastphat/android-container/blob/migrate-to-gradle-wrapper/images/docker-volume.png?raw=true)

Check out these referenced directories to see how things are wired:

- On Macos: `screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty`
- On Linux: under `~/var/lib/docker/volumes`

### Test Result

You can see how this approach can dramatically increase your build speed. In the second build, it only take `55s` instead of `4m 25s` for doing same taks.

![Image](https://github.com/fastphat/android-container/blob/migrate-to-gradle-wrapper/images/build-time.png?raw=true)


# Build Steps 

The sample that we're going to use is [Sunflower](https://github.com/android/sunflower). It uses `Android API 28` and `Build tools v28.0.3` so we will build our container with following command:

```shell
docker build \
--build-arg ANDROID_API_LEVEL=28 \
--build-arg ANDROID_BUILD_TOOLS_LEVEL=28.0.3 \
-t android-container:sunflower .
```

Clone and go to top level directory of sunflower directory:

```shell
git clone https://github.com/android/sunflower && cd sunflower/
```

Mount `/sunflower` into container as `/data`, name volume `/cache` as `gradle-cache` and run all tests:

```shell
docker run --privileged -it \
--rm -v $PWD:/data \
-v gradle-cache:/cache \
android-container:sunflower \
bash -c '. /start.sh && /data/gradlew test connectedAndroidTest -p /data'
```