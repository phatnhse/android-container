FROM adoptopenjdk/openjdk8:alpine

WORKDIR /

SHELL ["/bin/sh", "-c"]

RUN apk update && apk upgrade && apk add --no-cache bash git unzip wget libvirt-daemon qemu-img qemu-system-x86_64 dbus polkit virt-manager

# gradle caching
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME

# android pre-installed sdk tools/libs
ARG ANDROID_VERSION="android-30"
ARG ANDROID_EMULATOR_PACKAGE_x86="system-images;${ANDROID_VERSION};google_apis;x86"
ARG ANDROID_PLATFORM_VERSION="platforms;${ANDROID_VERSION}"
ARG ANDROID_SDK_VERSION="sdk-tools-linux-4333796.zip"
ARG ANDROID_SDK_PACKAGES="${ANDROID_EMULATOR_PACKAGE_x86} ${ANDROID_PLATFORM_VERSION} platform-tools emulator"

RUN wget https://dl.google.com/android/repository/${ANDROID_SDK_VERSION} -P /tmp && \
    unzip -d /opt/android /tmp/${ANDROID_SDK_VERSION}
ENV ANDROID_HOME=/opt/android
ENV PATH "$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# sdkmanager
RUN mkdir /root/.android/
RUN touch /root/.android/repositories.cfg
RUN yes Y | sdkmanager --licenses 
RUN yes Y | sdkmanager --verbose --no_https ${ANDROID_SDK_PACKAGES} 

# avdmanager
ENV EMULATOR_NAME_x86="android_x86"
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME_x86}" --device "pixel" --package "${ANDROID_EMULATOR_PACKAGE_x86}"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

# clean up
RUN apk del unzip wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

ADD start.sh /
RUN chmod +x start.sh