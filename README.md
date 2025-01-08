# Native Swift Toolchain for Android

This is a swift cross-compilation toolchain for Android.
It publishes release and development builds from the
[swift-android-sdk](https://github.com/finagolfin/swift-android-sdk)
project.

It can be installed and updated on macOS with
the [Homebrew](https://brew.sh) command:

```
brew install skiptools/skip/swift-android-toolchain@6.0
```

or by using the [Skip](https://skip.tools) command:

```
skip android sdk install
```

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


