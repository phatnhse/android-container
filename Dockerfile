FROM ubuntu:18.04

LABEL maintainer "codecaigicungduoc@gmail"

WORKDIR /

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y openjdk-8-jdk wget unzip libglu1 libpulse-dev libasound2 libc6  libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxi6  libxtst6 libnss3

ARG ANDROID_API_LEVEL=28
ARG ANDROID_BUILD_TOOLS_LEVEL=28.0.3
ARG EMULATOR_NAME="device-test"

# gradle
ENV GRADLE_USER_HOME=/cache
VOLUME $GRADLE_USER_HOME

# android 
ARG ANDROID_EMULATOR_PACKAGE="system-images;android-25;google_apis;armeabi-v7a"
RUN wget "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" -P /tmp \
    && unzip -d /opt/android /tmp/sdk-tools-linux-4333796.zip \
    && yes Y | /opt/android/tools/bin/sdkmanager --install ${ANDROID_EMULATOR_PACKAGE} "platform-tools"  "platforms;android-${ANDROID_API_LEVEL}" "build-tools;${ANDROID_BUILD_TOOLS_LEVEL}" "emulator" \
    && yes Y | /opt/android/tools/bin/sdkmanager --licenses \
    && echo "no" | /opt/android/tools/bin/avdmanager --verbose create avd --force --name ${EMULATOR_NAME} --device "pixel" --package ${ANDROID_EMULATOR_PACKAGE} \
    && rm /tmp/sdk-tools-linux-*.zip

ENV ANDROID_HOME=/opt/android
ENV PATH "$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"
ENV EMULATOR_NAME=$EMULATOR_NAME

RUN apt-get remove -y unzip wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*   

ADD start.sh /
RUN chmod +x start.sh
