#!/bin/bash -e
# Example usage: ./scripts/release_toolchain.sh ~/Downloads/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-03-12-a-android-24-0.1.artifactbundle.tar.gz.zip
# download SDK artifact from https://github.com/swift-android-sdk/swift-android-sdk/actions

PROG=$(basename $0)

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
    ARTIFACTBUNDLE=$(basename $ARTIFACTBUNDLE .zip)
fi

if [[ $ARTIFACTBUNDLE != swift-* || $ARTIFACTBUNDLE != *${SUFFIX} ]]; then
    echo "$PROG: Invalid SDK name: $ARTIFACTBUNDLE"
    exit 1
fi

CHECKSUM=$(shasum -a 256 ${ARTIFACTBUNDLE} | cut -f 1 -d ' ')
SDKNAME=$(basename ${ARTIFACTBUNDLE} ${SUFFIX} | cut -c 7-)
LOCAL_ARTIFACTNAME=$(basename ${ARTIFACTBUNDLE} .tar.gz)

# trim trailing "-RELEASE" for full releases
SDKNAME=$(echo ${SDKNAME} | sed 's;-RELEASE$;;g')

echo "$PROG: Creating release for SDK: $SDKNAME"

NOTES_FILE=$(mktemp)
cat > ${NOTES_FILE} << EOF
Install this SDK by installing the Swift OSS ${SDKNAME} toolchain from https://swift.org/download/#releases and add it to your PATH.

Then install the SDK by running the command:

\`\`\`
swift sdk install https://source.skip.tools/swift-android-toolchain/releases/download/${SDKNAME}/${ARTIFACTBUNDLE} --checksum ${CHECKSUM}
\`\`\`

Next, set the \`ANDROID_NDK_HOME\` environment variable to the local NDK installation and run the setup script. For example, on macOS, run:

\`\`\`
ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/27.0.12077973 ~/Library/org.swift.swiftpm/swift-sdks/${LOCAL_ARTIFACTNAME}/swift-android/scripts/setup-android-sdk.sh
\`\`\`

EOF

cat ${NOTES_FILE}

gh release create --repo skiptools/swift-android-toolchain --prerelease --notes-file ${NOTES_FILE} --title "${SDKNAME}" "${SDKNAME}" ${ARTIFACTBUNDLE}

