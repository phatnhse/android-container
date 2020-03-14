FROM ubuntu:18.04

LABEL maintainer "codecaigicungduoc@gmail"

WORKDIR /

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y cpu-checker openjdk-8-jdk wget unzip libglu1 libpulse-dev libasound2 libc6  libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxi6  libxtst6 libnss3

# gradle
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME

# android 
ARG ANDROID_EMULATOR_PACKAGE_ARM="system-images;android-25;google_apis;armeabi-v7a"
ARG ANDROID_EMULATOR_PACKAGE_x86="system-images;android-R;google_apis;x86"
ARG ANDROID_PLATFORM_VERSION="platforms;android-R"
ARG ANDROID_SDK_VERSION="sdk-tools-linux-4333796.zip"
ARG ANDROID_SDK_PACKAGES="${ANDROID_EMULATOR_PACKAGE_ARM} ${ANDROID_EMULATOR_PACKAGE_x86} ${ANDROID_PLATFORM_VERSION} platform-tools emulator"

RUN wget https://dl.google.com/android/repository/${ANDROID_SDK_VERSION} -P /tmp && \
    unzip -d /opt/android /tmp/${ANDROID_SDK_VERSION} && \
    rm /tmp/${ANDROID_SDK_VERSION}
ENV ANDROID_HOME=/opt/android
ENV PATH "$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# sdkmanager
RUN yes Y | sdkmanager --install ${ANDROID_SDK_PACKAGES}
RUN yes Y | sdkmanager --licenses 

# avdmanager
ENV EMULATOR_NAME_x86="android_x86"
ENV EMULATOR_NAME_ARM="android_arm"
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME_x86}" --device "pixel" --package "${ANDROID_EMULATOR_PACKAGE_x86}"
RUN echo "no" | avdmanager --verbose create avd --force --name "${EMULATOR_NAME_ARM}" --device "pixel" --package "${ANDROID_EMULATOR_PACKAGE_ARM}"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

# clean up
RUN  apt-get remove -y unzip wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*   

ADD start.sh /
RUN chmod +x start.sh
