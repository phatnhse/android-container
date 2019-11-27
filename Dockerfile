FROM ubuntu

LABEL maintainer "codecaigicungduoc@gmail"

WORKDIR /

RUN apt update && apt install -y libc6-dev-i386 lib32z1 openjdk-8-jdk vim unzip \
    libpulse-dev gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
    libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 \
    libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 \
    libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 \
    libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
    fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
 && apt clean all

RUN wget https://services.gradle.org/distributions/gradle-5.4.1-bin.zip -P /tmp \
 && unzip -d /opt/gradle /tmp/gradle-5.4.1-bin.zip \
 && echo 'export GRADLE_HOME=/opt/gradle/gradle-5.4.1' >> /.bashrc \
 && echo 'export PATH=$PATH:$GRADLE_HOME/bin' >> /.bashrc \
 && . /.bashrc \
 && mkdir /opt/gradlew \
 && gradle wrapper --gradle-version 5.4.1 --distribution-type all -p /opt/gradlew \
 && gradle wrapper -p /opt/gradlew \
 && echo 'export PATH=$PATH:/opt/gradlew' >> /.bashrc \
 && . /.bashrc

RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -P /tmp \
 && unzip -d /opt/android tmp/sdk-tools-linux-4333796.zip \
 && echo 'export ANDROID_HOME=/opt/android' >> /.bashrc \
 && echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> /.bashrc \
 && echo 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> /.bashrc \
 && . /.bashrc \
 && yes Y | sdkmanager --install "platform-tools" "system-images;android-28;google_apis;x86" "platforms;android-28" "build-tools;28.0.3" "emulator" \
 && yes Y | sdkmanager --licenses \
 && echo "no" | avdmanager --verbose create avd --force --name "test" --device "pixel" --package "system-images;android-28;google_apis;x86" --tag "google_apis" --abi "x86" \
 && echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> /.bashrc \
 && echo 'export LD_LIBRARY_PATH=${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib' >> /.bashrc \
 && . /.bashrc

CMD emulator @test