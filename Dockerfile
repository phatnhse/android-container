FROM ubuntu

LABEL maintainer "codecaigicungduoc@gmail"

WORKDIR /

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y openjdk-8-jdk vim unzip libglu1 libpulse-dev libasound2 libc6  libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxi6  libxtst6 libnss3 xdg-utils wget

ARG GRADLE_VERSION=5.4.1
ARG ANDROID_SDK_VERSION=28
ARG EMULATOR_NAME='test'

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
 && unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
 && mkdir /opt/gradlew \
 && /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type all -p /opt/gradlew  \
 && /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper -p /opt/gradlew

RUN wget 'https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip' -P /tmp \
 && unzip -d /opt/android /tmp/sdk-tools-linux-4333796.zip \
 && yes Y | /opt/android/tools/bin/sdkmanager --install "platform-tools" "system-images;android-${ANDROID_SDK_VERSION};google_apis;x86" "platforms;android-${ANDROID_SDK_VERSION}" "build-tools;${ANDROID_SDK_VERSION}.0.3" "emulator" \
 && yes Y | /opt/android/tools/bin/sdkmanager --licenses \
 && echo "no" | /opt/android/tools/bin/avdmanager --verbose create avd --force --name "test" --device "pixel" --package "system-images;android-${ANDROID_SDK_VERSION};google_apis;x86" --tag "google_apis" --abi "x86"

ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION \
    ANDROID_HOME=/opt/android
ENV PATH "$PATH:$GRADLE_HOME/bin:/opt/gradlew:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

ADD start.sh /
RUN chmod +x start.sh