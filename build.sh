docker build \
--build-arg GRADLE_VERSION=5.4.1 \
--build-arg ANDROID_API_LEVEL=28 \
--build-arg ANDROID_BUILD_TOOLS_LEVEL=28.0.3 \
--build-arg EMULATOR_NAME=test \
-t android-container:sunflower . 
