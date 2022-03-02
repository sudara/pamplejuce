![PAMPLEJUCE](pamplejuce.png)
[![](https://github.com/sudara/pamplejuce/workflows/CMake/badge.svg)](https://github.com/sudara/pamplejuce/actions)

Pamplejuce is a ~~template~~ lifestyle for creating and building JUCE plugins in 2021.

Out of the box, it supports:

1. C++20
2. JUCE 6.1.5 as a submodule (tracking develop)
3. CMake 3.21
4. Catch2 v3 (tracking devel via FetchContent) as the test framework and runner
5. GitHub Actions config for building binaries, running Catch2 tests, running pluginval and artifact building for the Windows, Linux and MacOS platforms.

It also contains:

1. Proper `.gitignore` for all platforms
2. A `.clang-format` file 
3. A `VERSION` file that will propagate through to JUCE and your app.


## How does this all work at a high level?

Read up about [JUCE and CMmake on my blog!](https://melatonin.dev/blog/how-to-use-cmake-with-juce/).


## What Pamplejuce doesn't handle (yet)

1. MacOS code signing, packaging, notarization.
2. Windows signing

## How to use for YOUR project

This is a template repo! 

That means the easiest thing to do is  click "[Use this template](https://github.com/sudara/pamplejuce/generate)" here or at the top of the page to get your own repo with all the code here.

For an example of a plugin that uses this repo, check out [Load Monster!](https://github.com/sudara/load_monster_plugin).

After you've created a new repo:

0. `git clone` your new repo (if you make it private, see the warning below about GitHub Actions minutes)

1. [Download CMAKE](https://cmake.org/download/) if you aren't already using it (Clion and VS2022 both have it bundled, so you can skip this step in those cases).

2. Populate the latest JUCE by running `git submodule update --init` in your repository directory. By default, this will track JUCE's `develop` branch, which IMO is what you want until you are at the point of releasing a plugin.

3. Replace `Pamplejuce` with the name of your project in CMakeLists.txt line 5, where the `PROJECT_NAME` variable is set. Make this all one word, no spaces. 

4. Pick which formats you want built on line 8.

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md and be sure to change things like `PLUGIN_CODE` and `PLUGIN_MANUFACTURER_CODE`.  

6. Rename `AudioPluginAudioProcessor` to your plugin name in the code.

## Conventions

1. Your tests will be in "Tests" and you can just add new .cpp files there.
2. Your binary data target is called "Assets"

## Tips n' Tricks

1. :warning: GitHub gives you 2000 or 3000 free GitHub Actions "minutes" for private projects, but [they actually bill 2x the number of minutes you use on Windows and 10x on MacOS](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-billing-and-payments-on-github/about-billing-for-github-actions#about-billing-for-github-actions).

2. There's a `VERSION` file in the root that you can treat as the main place to bump the version.

3. Catch2 will update on each CMake configure, you can lock this down if you prefer by changing the `GIT_TAG`.


## How do variables work in GitHub Actions?

It's very confusing, as the documentation is a big framented.

1. Things in double curly braces like `${{ matrix.artifact }}` are called ["contexts or expressions"](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions) and can be used to get, set, or perform simple operations.
2. In "if" conditions you can omit the double curly braces, as the whole condition is evaluated as an expression: `if: contains(github.ref, 'tags/v')`
3. You can set variables for the whole workflow to use in ["env"](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#env)
4. Reading those variables is done with the [env context](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#env-context) when you are inside a `with`, `name`, or `if`: `${{ env.SOME_VARIABLE }}`
5. Inside of `run`, you have access to bash ENV variables *in addition* to contexts/expressions. That means `$SOME_VARIABLE` or `${SOME_VARIABLE}` will work but *only when using bash* and [not while using powershell on windows](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#using-a-specific-shell). The version with curly braces (variable expansion) is often used [when the variable is forming part of a larger string to avoid ambiguity](https://stackoverflow.com/questions/8748831/when-do-we-need-curly-braces-around-shell-variables). Be sure that the ENV variable was set properly in the workflow/job/step before you use it. And if you need the variable to be os-agnostic, use the env context.

## Pamplejuce dev

When working on the template repo itself, I clear out the Builds directory when altering the CMake. 

```
rm -rf Builds && cmake -B Builds -G Xcode
rm -rf Builds && cmake -B Builds && cmake --build Builds --config Release 
```

## How to update a repo based on Pamplejuce

1. Update with latest CMake version [listed here](https://github.com/lukka/get-cmake), or the latest version supported by your toolchain like VS or Clion.
2. Update JUCE with `git submodule update --remote --merge`
3. Update Xcode to [latest available version](https://github.com/actions/virtual-environments/blob/main/images/macos/macos-11.0-Readme.md) and change `DEVELOPER_DIR` env var in the GitHub action.

## References & Inspiration

### CMake

* [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
* [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1)
* JUCE's announcment of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700)
* [Eyalamir Music's JUCE / CMake prototype repository](https://github.com/eyalamirmusic/JUCECmakeRepoPrototype)

### GitHub Actions

* [Christian Adam's HelloWorld CMake and ccache repo](https://github.com/cristianadam/HelloWorld)
* [Maxwell Pollack's JUCE CMake + GitHub Actions repo](https://github.com/maxwellpollack/juce-plugin-ci)
* [Oli Larkin's PDSynth iPlug2 template](https://github.com/olilarkin/PDSynth)
* [Running pluginval in CI](https://github.com/Tracktion/pluginval/blob/develop/docs/Adding%20pluginval%20to%20CI.md)

### Catch2 & CTest

* [Catch2's docs on CMake integration](https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md)
* [Roman Golyshev's Github Actions & Catch2 repo](https://github.com/fedochet/github-actions-cpp-test)
* [Matt Clarkson's CMakeCatch2 repo](https://github.com/MattClarkson/CMakeCatch2)
* [CMake Cookbook example](https://github.com/dev-cafe/cmake-cookbook/tree/master/chapter-04/recipe-02/cxx-example)
* [Unit Testing With CTest](https://bertvandenbroucke.netlify.app/2019/12/12/unit-testing-with-ctest/)
* [Mark's Catch2 examples from his 2020 ADC talk](https://github.com/Sinecure-Audio/TestsTalk)

### Packaging & Notorization (tbd)

* [iPlug Packages and Inno Setup scripts](https://github.com/olilarkin/wdl-ol/tree/master/IPlugExamples/IPlugEffect/installer)
* [Surge's pkgbuild installer script](https://github.com/kurasu/surge/blob/master/installer_mac/make_installer.sh)
* [Chris Randall's PackageBuilder script](https://forum.juce.com/t/vst-installer/16654/15)
* [David Cramer's GA Workflow for signing and notarizing](https://medium.com/better-programming/indie-mac-app-devops-with-github-actions-b16764a3ebe7) and his [notarize-cli tool](https://github.com/bacongravy/notarize-cli)
