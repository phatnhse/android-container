FROM ubuntu

LABEL maintainer "codecaigicungduoc@gmail"

WORKDIR /root

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y libc6-dev-i386 lib32z1 openjdk-8-jdk vim unzip \
    libpulse-dev gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
    libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
    libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
    libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
    fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
 && apt clean all

RUN wget 'https://services.gradle.org/distributions/gradle-5.4.1-bin.zip' -P /tmp \
 && unzip -d /opt/gradle /tmp/gradle-5.4.1-bin.zip \
 && mkdir /opt/gradlew \
 && /opt/gradle/gradle-5.4.1/bin/gradle wrapper --gradle-version 5.4.1 --distribution-type all -p /opt/gradlew \
 && /opt/gradle/gradle-5.4.1/bin/gradle wrapper -p /opt/gradlew

RUN wget 'https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip' -P /tmp \
 && unzip -d /opt/android /tmp/sdk-tools-linux-4333796.zip \
 && yes Y | /opt/android/tools/bin/sdkmanager --install "platform-tools" "system-images;android-28;google_apis;x86" "platforms;android-28" "build-tools;28.0.3" "emulator" \
 && yes Y | /opt/android/tools/bin/sdkmanager --licenses \
 && echo "no" | /opt/android/tools/bin/avdmanager --verbose create avd --force --name "test" --device "pixel" --package "system-images;android-28;google_apis;x86" --tag "google_apis" --abi "x86"

ENV GRADLE_HOME=/opt/gradle/gradle-5.4.1 \
    ANDROID_HOME=/opt/android
ENV PATH "$PATH:$GRADLE_HOME/bin:/opt/gradlew:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

RUN emulator @test