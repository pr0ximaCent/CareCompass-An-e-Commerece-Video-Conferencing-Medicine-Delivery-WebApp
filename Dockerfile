# Use official Debian-based image as the parent image
FROM debian:bullseye-slim

# Set environment variables for Flutter and Java
ENV FLUTTER_HOME=/usr/local/flutter
ENV FLUTTER_VERSION=2.10.0
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$FLUTTER_HOME/bin:$JAVA_HOME/bin:$PATH

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# Install required dependencies
RUN apt-get update && \
    apt-get install -y curl unzip git openjdk-11-jdk && \
    apt-get clean

# Download and install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter precache --version $FLUTTER_VERSION && \
    flutter config --no-analytics

# Accept Android licenses
RUN mkdir -p $ANDROID_SDK_ROOT/licenses && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_SDK_ROOT/licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" >> $ANDROID_SDK_ROOT/licenses/android-sdk-license

# Create a directory for the Flutter app and set it as the working directory
WORKDIR /app

# Copy the Flutter project files into the container
COPY . .

# Run Flutter commands to build the APK
RUN flutter upgrade && \
    flutter pub get && \
    flutter build apk --release

# Expose the build output directory
VOLUME /app/build/app/outputs/flutter-apk

# Set the entry point to copy the generated APK to a mounted volume
CMD cp -r build/app/outputs/flutter-apk /app/build_output
