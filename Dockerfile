FROM ubuntu:20.04
LABEL Anatolii Lukyanov <lukyanov.anatolii@gmail.com>

ENV VERSION_TOOLS "9477386"

ENV ANDROID_SDK_ROOT "/sdk"
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV ANDROID_TOOL_HOME "${ANDROID_HOME}/cmdline-tools"
ENV PATH "${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
    && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-17-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses6 \
      lib32z1 \
      unzip \
      locales \
      jq \
      npm \
      wget \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools/ ${ANDROID_HOME}/cmdline-tools/latest \
    && rm android-commandline-tools.zip && ls -la ${ANDROID_HOME}/cmdline-tools/latest/

# update node.js
RUN npm install -g n && n stable

# install appcenter cli
RUN npm install -g appcenter-cli

ENV LANG en_US.UTF-8

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
    && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
    && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license

RUN mkdir -p /root/.android \
    && touch /root/.android/repositories.cfg \
    && sdkmanager --update

RUN yes | sdkmanager --licenses

RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

RUN sdkmanager "build-tools;34.0.0"

RUN sdkmanager "platforms;android-33"

ENV GRADLE_VERSION 8.5
ENV GRADLE_USER_HOME /usr/local/gradle-${GRADLE_VERSION}
ENV ZIP_DIR ${GRADLE_USER_HOME}/wrapper/dists/gradle-${GRADLE_VERSION}-bin/5t9huq95ubn472n8rpzujfbqh
RUN mkdir -p ${ZIP_DIR}
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o ${ZIP_DIR}/gradle-${GRADLE_VERSION}-bin.zip  

ENV GRADLE_HOME ${ZIP_DIR}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH
