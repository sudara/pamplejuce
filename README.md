

## About This Repository

This repository is meant as an example of 2020 best practices for a JUCE app. 

Currently it supports:

1. C++20
2. JUCE 6.x as a submodule, tracking the devlop branch
3. CMake 3.18
4. Catch2
5. Github Actions for both CI and artifact building, including code signing on mac os
6. Proper .gitignore settings given the above

## What it doesn't handle

1. MacOS notarization.

## How to setup cmake for a new or existing JUCE project

1. [Download CMAKE](https://cmake.org/download/)

2. Take a look at [JUCE's default CMakeLists.txt](https://github.com/juce-framework/JUCE/tree/master/examples/CMake/AudioPlugin) and copy it over to your new project.

3. Replace `Pamplejuce` with the name of your project.

4. Set JUCE path. Uncomment the `add_subdirectory` example. Let's add JUCE as a submodule. I'm assuming we want the develop branch.

```
git submodule add --branch develop --force -- https://github.com/juce-framework/JUCE/ JUCE
git commit .gitmodules JUCE -m 'Adding JUCE as a submodule'
```

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md


## Resources

1. [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
2. JUCE's announcment of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700). 
