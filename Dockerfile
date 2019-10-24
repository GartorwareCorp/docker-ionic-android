FROM ubuntu:18.04

LABEL MAINTAINER="Gartorware <gartorware@gmail.com>"

ARG NODEJS_VERSION="10.16.3"
ARG IONIC_VERSION="5.4.4"
ARG CORDOVA_VERSION="9.0.0"
ARG ANDROID_SDK_VERSION="4333796"
ARG ANDROID_BUILD_TOOLS_VERSION="29.0.1"
ARG GRADLE_VERSION="5.6.3"

ARG NODEJS_URL="https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip"
ARG GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

ENV ANDROID_SDK_ROOT "/opt/android-sdk"
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV BUILD_TOOLS_ROOT "${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}"
ENV GRADLE_HOME "/opt/gradle/gradle-${GRADLE_VERSION}"

ENV PATH "${PATH}:${BUILD_TOOLS_ROOT}:${GRADLE_HOME}/bin"

RUN mkdir -p /opt && cd /tmp \
    # 1) Install system package dependencies
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    build-essential \
    unzip \
    git \
    openjdk-8-jre \
    openjdk-8-jdk \
    # 2) Install Nodejs/NPM/Cordova/Ionic-Cli
    && curl -fSLk ${NODEJS_URL} -o node-${NODEJS_VERSION}.tar.xz \
    && tar -xf node-${NODEJS_VERSION}.tar.xz -C / --strip-components=1 \
    && npm install -g cordova@${CORDOVA_VERSION} ionic@${IONIC_VERSION} \
    # 3) Install Android SDK & Android  SDK tool
    && curl -fSLk ${ANDROID_SDK_URL} -o sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir -p ${ANDROID_SDK_ROOT} \
    && unzip -d ${ANDROID_SDK_ROOT} sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
    && (while sleep 3; do echo "y"; done) | $ANDROID_SDK_ROOT/tools/bin/sdkmanager --licenses \
    && $ANDROID_SDK_ROOT/tools/bin/sdkmanager "platform-tools" \
    && $ANDROID_SDK_ROOT/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    # 4) Install gradle
    && curl -fSLk ${GRADLE_URL} -o gradle-${GRADLE_VERSION}-bin.zip \
    && mkdir -p ${GRADLE_HOME} \
    && unzip gradle-${GRADLE_VERSION}-bin.zip \
    && mv gradle-${GRADLE_VERSION}/* ${GRADLE_HOME} \
    # 5) Cleanup
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # 6) Add and set user for use by ionic and set work folder
    && mkdir /app

WORKDIR /app