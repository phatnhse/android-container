git clone https://github.com/android/sunflower \
&& cd sunflower \
&& docker run --privileged -it --rm -v $PWD:/data android-container:sunflower bash -c ". /start.sh && gradlew test connectedAndroidTest -p /data"
