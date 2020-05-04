FROM ubuntu:20.04

LABEL MAINTAINER="Gartorware <gartorware@gmail.com>"

ARG NODEJS_VERSION="12.16.2"
ARG IONIC_VERSION="6.6.0"
ARG CORDOVA_VERSION="9.0.0"
ARG ANDROID_SDK_VERSION="6200805_latest"
ARG ANDROID_BUILD_TOOLS_VERSION="29.0.3"
ARG ANDROID_VERSION=29
ARG GRADLE_VERSION="6.3"

ARG NODEJS_URL="https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.xz"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}.zip"
ARG GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

ENV TZ "Europe/Madrid"
ENV ANDROID_SDK_ROOT "/opt/android-sdk"
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV BUILD_TOOLS_ROOT "${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}"
ENV GRADLE_HOME "/opt/gradle/gradle-${GRADLE_VERSION}"
ENV NODE_ROOT "/opt/node"

ENV PATH "${PATH}:${NODE_ROOT}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${BUILD_TOOLS_ROOT}:${GRADLE_HOME}/bin"

RUN mkdir -p /opt && cd /tmp \
    # 1) Install system package dependencies
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    build-essential \
    unzip \
    git \
    openjdk-8-jre \
    openjdk-8-jdk \
    # 2) Install Nodejs/NPM/Cordova/Ionic-Cli
    && curl -fSLk ${NODEJS_URL} -o node-${NODEJS_VERSION}.tar.xz \
    && mkdir -p ${NODE_ROOT} \
    && tar -xf node-${NODEJS_VERSION}.tar.xz -C ${NODE_ROOT} --strip-components=1 \
    && ln -s ${NODE_ROOT}/bin/node /usr/bin/node \
    && ln -s ${NODE_ROOT}/bin/npm /usr/bin/npm \
    && ln -s ${NODE_ROOT}/bin/npx /usr/bin/npx \
    && npm install -g cordova@${CORDOVA_VERSION} @ionic/cli@${IONIC_VERSION} \
    # 3) Install Android SDK & Android  SDK tool
    && curl -fSLk ${ANDROID_SDK_URL} -o commandlinetools-linux-${ANDROID_SDK_VERSION}.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -d ${ANDROID_SDK_ROOT}/cmdline-tools commandlinetools-linux-${ANDROID_SDK_VERSION}.zip \
    && (while sleep 3; do echo "y"; done) | $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --licenses \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager --update \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "tools" \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "platform-tools" \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "platforms;android-${ANDROID_VERSION}" \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "patcher;v4" \
    && $ANDROID_SDK_ROOT/cmdline-tools/tools/bin/sdkmanager "emulator" \
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