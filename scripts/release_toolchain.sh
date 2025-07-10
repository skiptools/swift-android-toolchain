#!/bin/bash -e
# Example usage: ./scripts/release_toolchain.sh ~/Downloads/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-03-12-a-android-24-0.1.artifactbundle.tar.gz.zip
# download SDK artifact from https://github.com/swift-android-sdk/swift-android-sdk/actions

PROG=$(basename $0)

#RELEASE_REPO=skiptools/swift-android-toolchain
#RELEASE_REPO=swift-android-sdk/swift-android-sdk

# e.g., override with:
# RELEASE_REPO=skiptools/swift-android-toolchain release_toolchain.sh
RELEASE_REPO=${RELEASE_REPO:-"swift-android-sdk/swift-android-sdk"}

ARTIFACTBUNDLE=$1
SUFFIX="-android-0.1.artifactbundle.tar.gz"

if [ -z $ARTIFACTBUNDLE ]; then
    echo "Usage: $PROG <zip of artifact>"
    exit 1
fi

WD=`mktemp -d`
cp -s ${ARTIFACTBUNDLE} ${WD}
cd ${WD}
ARTIFACTBUNDLE=$(basename ${ARTIFACTBUNDLE})

if [[ $ARTIFACTBUNDLE == *.zip ]]; then
    unzip -o $ARTIFACTBUNDLE
    #ARTIFACTBUNDLE=$(basename $ARTIFACTBUNDLE .zip)
    ARTIFACTBUNDLE=$(ls -1 *.tar.gz | tail -n 1)
fi

if [[ $ARTIFACTBUNDLE != swift-* || $ARTIFACTBUNDLE != *${SUFFIX} ]]; then
    echo "$PROG: Invalid SDK name: $ARTIFACTBUNDLE"
    exit 1
fi

# TODO: run verification
#~/bin/swift-android-sdk-verify.sh ${ARTIFACTBUNDLE}

CHECKSUM=$(shasum -a 256 ${ARTIFACTBUNDLE} | cut -f 1 -d ' ')
SDKNAME=$(basename ${ARTIFACTBUNDLE} ${SUFFIX} | cut -c 7-)
LOCAL_ARTIFACTNAME=$(basename ${ARTIFACTBUNDLE} .tar.gz)

# trim trailing "-RELEASE" for full releases
SDKNAME=$(echo ${SDKNAME} | sed 's;-RELEASE$;;g')

# the swiftly name for the SDK release
SWIFTLY_NAME=$(echo "${SDKNAME}" | tr '[A-Z]' '[a-z]' | sed 's;-development-snapshot-;-snapshot-;g' | sed 's;development-snapshot-;main-snapshot-;g')

echo "$PROG: Creating release for SDK: $SDKNAME"

NOTES_FILE=$(mktemp)
cat > ${NOTES_FILE} << EOF
### Installing the Swift Android SDK

First install the matching Swift \`${SDKNAME}\` toolchain from https://swift.org/download/#releases and add it to your PATH, or by using [swiftly](https://www.swift.org/install/):

\`\`\`
swiftly install ${SWIFTLY_NAME}
\`\`\`

Then install the Swift Android SDK by running the command:

\`\`\`
swift sdk install https://github.com/${RELEASE_REPO}/releases/download/${SDKNAME}/${ARTIFACTBUNDLE} --checksum ${CHECKSUM}
\`\`\`

### Installing the Android NDK

The Swift Android SDK requires the Android Native Development Toolkit ([NDK](https://developer.android.com/ndk/)) to function, which must be installed separately.  Download and unzip the r27c LTS release and set the \`ANDROID_NDK_HOME\` environment variable to the local NDK installation and run the setup script. 

#### macOS configuration command for [android-ndk-r27c-darwin.zip](https://dl.google.com/android/repository/android-ndk-r27c-darwin.zip):

\`\`\`
ANDROID_NDK_HOME=~/Downloads/android-ndk-r27c ~/Library/org.swift.swiftpm/swift-sdks/${LOCAL_ARTIFACTNAME}/swift-android/scripts/setup-android-sdk.sh
\`\`\`

#### Linux configuration command for [android-ndk-r27c-linux.zip](https://dl.google.com/android/repository/android-ndk-r27c-linux.zip):

\`\`\`
ANDROID_NDK_HOME=~/android-ndk-r27c ~/.swiftpm/swift-sdks/${LOCAL_ARTIFACTNAME}/swift-android/scripts/setup-android-sdk.sh
\`\`\`

#### GitHub Actions:

\`\`\`
~/.swiftpm/swift-sdks/${LOCAL_ARTIFACTNAME}/swift-android/scripts/setup-android-sdk.sh
\`\`\`

> [!NOTE]
> GitHub Actions already includes the Android NDK and defines \`ANDROID_NDK_HOME\`, so there is no need to install the NDK separately. Alternatively, you can use the [swift-android-action](https://github.com/marketplace/actions/swift-android-action) to build Swift packages and run Android tests from a GitHub workflow.

### Building Swift Packages for Android

Now you can compile a Swift package for Android with:

\`\`\`
$ git clone https://github.com/apple/swift-algorithms.git
$ cd swift-algorithms/
$ swiftly run swift build --swift-sdk aarch64-unknown-linux-android28 +${SWIFTLY_NAME}
\`\`\`

### Running Swift Executables on Android

If you have a connected Android device with [USB debugging enabled](https://developer.android.com/studio/debug/dev-options#Enable-debugging), or are running an [Android emulator](https://developer.android.com/studio/run/emulator), you can create and run a Swift executable with the following commands:

\`\`\`
$ mkdir ExecutableDemo
$ cd ExecutableDemo
$ swift package init --type executable
$ swiftly run swift build --static-swift-stdlib --swift-sdk aarch64-unknown-linux-android28 +${SWIFTLY_NAME}
$ adb push .build/debug/ExecutableDemo /data/local/tmp/
$ adb shell /data/local/tmp/ExecutableDemo
\`\`\`

EOF

cat ${NOTES_FILE}

gh release create --repo ${RELEASE_REPO} --prerelease --notes-file ${NOTES_FILE} --title "${SDKNAME}" "${SDKNAME}" ${ARTIFACTBUNDLE}

