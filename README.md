![PAMPLEJUCE](pamplejuce.png)

This repository is a template for creating JUCE plugins with 2020 best practices.

Out of the box, it supports:

1. C++20
2. JUCE 6.x as a submodule, tracking develop
3. CMake 3.18
4. Catch2 2.13.2
5. Github Actions for both CI and artifact building, including code signing on mac os (n)
6. Proper .gitignore given the above

## What it doesn't handle

1. MacOS notarization.

## How to setup cmake for a new or existing JUCE project

1. [Download CMAKE](https://cmake.org/download/)

2. Take a look at [JUCE's default CMakeLists.txt](https://github.com/juce-framework/JUCE/tree/master/examples/CMake/AudioPlugin) and copy it over to your new project.

3. Replace `AudioPluginExample` with the name of your project.

4. Set JUCE path. Uncomment the `add_subdirectory` example. Let's add JUCE as a submodule. I'm assuming we want the develop branch.

```
git submodule add --branch develop --force -- https://github.com/juce-framework/JUCE/ JUCE
git commit .gitmodules JUCE -m 'Adding JUCE as a submodule'
```

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md


## Manually building the project on MacOS

```
cmake -B Builds -G Xcode
```

## Updating this repository

1. Check for latest CMake version.
2. Update JUCE with `git submodule update --remote --merge`

## FAQ 

### What is CTest?



## References

1. [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
2. JUCE's announcment of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700).
3. [Eyalamir Music's JUCE / CMake prototype repository](https://github.com/eyalamirmusic/JUCECmakeRepoPrototype)
4. [Christian Adam's HelloWorld CMake and ccache repo](https://github.com/cristianadam/HelloWorld)
5. [Roman Golyshev's Github Actions & Catch22 repo](https://github.com/fedochet/github-actions-cpp-test)