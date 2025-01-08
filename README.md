# Native Swift Toolchain for Android

This is a swift cross-compilation toolchain for Android.
It publishes release and development builds from the
[swift-android-sdk](https://github.com/finagolfin/swift-android-sdk)
project.

## Installing on macOS

The latest version can be installed and updated on macOS with
the [Homebrew](https://brew.sh) command:

```
$ brew install skiptools/skip/swift-android-toolchain@6.0
```

or by using the [Skip](https://skip.tools) command:

```
$ skip android sdk install
```

Both these commands will install the corresponding Swift OSS
toolchain, which is required to match the version
of the Android SDK:

```
$ ls ~/Library/Developer/Toolchains/ ~/.swiftpm/swift-sdks/

~/.swiftpm/swift-sdks/:
swift-6.0.3-RELEASE-android-24-0.1.artifactbundle

~/Library/Developer/Toolchains/:
swift-6.0.3-RELEASE.xctoolchain
```

## Installing on Linux

To install on Linux, first download and install the corresponding
Swift version from [swift.org](https://www.swift.org/install/linux/#platforms).

Then install the toolchain with the `swift sdk install`
command corresponding to the toolchain
[release](https://github.com/skiptools/swift-android-toolchain/releases).

## Checking Installed Versions

You can also list the installed versions of the SDK with:

```
$ swift sdk list

swift-6.0.3-RELEASE-android-24-0.1
```

Any particular version can be removed with:

```
$ swift sdk remove swift-6.0.3-RELEASE-android-24-0.1
```

## GitHub Actions

It can also be used from a GitHub workflow with the
[swift-android-action](https://github.com/marketplace/actions/swift-android-action)
to build and test Swift packages on Android from macOS or Linux runners:

```
- uses: actions/checkout@v4
- name: "Test Swift Package"
  run: swift test
- name: "Test Swift Package on Android"
  uses: skiptools/swift-android-action@v2
```


