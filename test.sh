rm -rf sunflower && \
git clone https://github.com/android/sunflower && cd sunflower && \
docker run --privileged -it --rm -v $PWD:/data -v gradle-cache:/cache android-container:sunflower bash -c ". /start.sh && /data/gradlew test connectedAndroidTest -p /data"
