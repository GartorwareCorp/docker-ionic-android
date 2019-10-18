FROM ubuntu:18.04

LABEL MAINTAINER="Gartorware <gartorware@gmail.com>"

ARG NODEJS_VERSION="10.16.3"
ARG IONIC_VERSION="5.4.4"
ARG ANDROID_SDK_VERSION="4333796"
ARG ANDROID_HOME="/opt/android-sdk"
ARG ANDROID_BUILD_TOOLS_VERSION="29.0.1"

ENV NODEJS_URL="https://deb.nodesource.com/setup_${NODEJS_VERSION}.x"
ENV ANDROID_HOME "${ANDROID_HOME}"
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip"

RUN apt-get update \
    # 1) Install system package dependencies
    && apt-get install -y \
    build-essential \
    openjdk-8-jre \
    openjdk-8-jdk \
    curl \
    unzip \
    git \
    gradle \
    # 2) Install Nodejs/NPM/Cordova/Ionic-Cli
    && curl -sL ${NODEJS_URL} | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g cordova ionic@${IONIC_VERSION} \
    # 3) Install Android SDK & Android  SDK tool
    && cd /tmp \
    && curl -fSLk ${ANDROID_SDK_URL} -o sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir /opt/android-sdk \
    && mv tools /opt/android-sdk \
    && (while sleep 3; do echo "y"; done) | $ANDROID_HOME/tools/bin/sdkmanager --licenses \
    && $ANDROID_HOME/tools/bin/sdkmanager "platform-tools" \
    && $ANDROID_HOME/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    # 4) Cleanup
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /tmp/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \ 
    # 5) Add and set user for use by ionic and set work folder
    && mkdir /ionicapp

WORKDIR /ionicapp