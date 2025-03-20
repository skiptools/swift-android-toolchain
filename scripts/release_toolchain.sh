#!/bin/bash -e
# Example usage: ./scripts/release_toolchain.sh ~/Downloads/swift-6.1-DEVELOPMENT-SNAPSHOT-2025-03-12-a-android-24-0.1.artifactbundle.tar.gz.zip
# download SDK artifact from https://github.com/swift-android-sdk/swift-android-sdk/actions

PROG=$(basename $0)

ARTIFACTBUNDLE=$1
SUFFIX="-android-24-0.1.artifactbundle.tar.gz"

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

echo "$PROG: Creating release for SDK: $SDKNAME"

NOTES_FILE=$(mktemp)
cat > ${NOTES_FILE} << EOF
Install this SDK by installing the Swift ${SDKNAME} toolchain from https://swift.org/download/#releases and then running the command:

\`\`\`
swift sdk install https://source.skip.tools/swift-android-toolchain/releases/download/${SDKNAME}/${ARTIFACTBUNDLE} --checksum ${CHECKSUM}
\`\`\`
EOF

gh release create --repo skiptools/swift-android-toolchain --prerelease --notes-file ${NOTES_FILE} --title "${SDKNAME}" "${SDKNAME}" ${ARTIFACTBUNDLE}

