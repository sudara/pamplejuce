![PAMPLEJUCE](pamplejuce.png)

This repository is a template for creating JUCE plugins with 2020 best practices.

Out of the box, it supports:

1. C++20
2. JUCE 6.x as a submodule, tracking develop
3. CMake 3.18
4. Catch2 2.13.2
5. Github Actions for both CI and artifact building
6. Proper .gitignore given the above

## What it doesn't handle (yet)

1. MacOS code signing, packaging, notarization.

## How to use the repo for YOUR project

1. [Download CMAKE](https://cmake.org/download/)

2. Fork, or clone this repo locally

3. Replace `Pamplejuce` with the name of your project.

4. `git submodule update --init`

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md


## How to build your project on MacOS

This will generate an Xcode project with a debug release defaulted. 

```
cmake -B Builds -G Xcode
```

This is *instead* of compiling in release mode, which this commond does on GitHub, for example:

```
cmake -B Builds 
```

## Updating Pamplejuce

1. Update with latest CMake version.
2. Update JUCE with `git submodule update --remote --merge`

## FAQ 

### What is CTest?


## References & Inspiration

1. [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
2. JUCE's announcment of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700)
3. [Eyalamir Music's JUCE / CMake prototype repository](https://github.com/eyalamirmusic/JUCECmakeRepoPrototype)
4. [Christian Adam's HelloWorld CMake and ccache repo](https://github.com/cristianadam/HelloWorld)
5. [Roman Golyshev's Github Actions & Catch2 repo](https://github.com/fedochet/github-actions-cpp-test)
6. [Maxwell Pollack's CMake + GitHub Actions repo](https://github.com/maxwellpollack/juce-plugin-ci)
7. [iPlug Packages and Inno Setup scripts](https://github.com/olilarkin/wdl-ol/tree/master/IPlugExamples/IPlugEffect/installer)