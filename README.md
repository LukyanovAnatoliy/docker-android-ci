# docker-android-ci
This Docker image contains the Android SDK and most common packages necessary for building Android apps in a CI tool like GitLab CI.

A `.gitlab-ci.yml` with caching of your project's dependencies would look like this:

```
image: lavelek/android-ci:latest

stages:
- build

before_script:
- export GRADLE_USER_HOME=$(pwd)/.gradle
- chmod +x ./gradlew

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/

build:
  stage: build
  script:
  - ./gradlew assembleDebug
  artifacts:
    paths:
    - app/build/outputs/apk/app-debug.apk
```
