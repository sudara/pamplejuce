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

2. Fork this repo and/or clone this repo locally

3. Replace `Pamplejuce` with the name of your project in CMakeLists.txt

4. Get the latest JUCE via `git submodule update --init`

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md


## How to build your project on MacOS

This will generate an Xcode project:

```
cmake -B Builds -G Xcode
```

You can skip the Xcode project and build Release only on the command line with: 

```
cmake -B Builds --config Release .
```

## Updating Pamplejuce

1. Update with latest CMake version.
2. Update JUCE with `git submodule update --remote --merge`

## FAQ 

### What is CTest?

### How do variables work in GitHub Actions?

It's very confusing.

1. Things in double curly braces like `${{ matrix.artifact }}` are called ["contexts or expressions"](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions) and can be used to get, set, or perform simple operations.
2. In "if" conditions you can omit the double curly braces, as the whole condition is evaluated as an expression: `if: contains(github.ref, 'tags/v')`
3. You can set variables for the whole workflow to use in ["env"](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#env)
4. Reading those variables is done with the [env context](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#env-context) when you are inside a `with`, `name`, or `if`: `${{ env.SOME_VARIABLE }}`
5. However, inside of `run`, you only have access to bash ENV variables. That means `$SOME_VARIABLE` or `${SOME_VARIABLE}`. The latter (variable expansion) is often used when the variable is forming only part of a larger string to avoid ambiguity. 

## References & Inspiration

1. [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
2. JUCE's announcment of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700)
3. [Eyalamir Music's JUCE / CMake prototype repository](https://github.com/eyalamirmusic/JUCECmakeRepoPrototype)
4. [Christian Adam's HelloWorld CMake and ccache repo](https://github.com/cristianadam/HelloWorld)
5. [Roman Golyshev's Github Actions & Catch2 repo](https://github.com/fedochet/github-actions-cpp-test)
6. [Maxwell Pollack's CMake + GitHub Actions repo](https://github.com/maxwellpollack/juce-plugin-ci)
7. [iPlug Packages and Inno Setup scripts](https://github.com/olilarkin/wdl-ol/tree/master/IPlugExamples/IPlugEffect/installer)
8. [Surge's pkgbuild installer script](https://github.com/kurasu/surge/blob/master/installer_mac/make_installer.sh)
9. [Chris Randall's PackageBuilder script](https://forum.juce.com/t/vst-installer/16654/15)