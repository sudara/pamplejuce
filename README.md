![PAMPLEJUCE](pamplejuce.png)
[![](https://github.com/sudara/pamplejuce/workflows/Pamplejuce/badge.svg)](https://github.com/sudara/pamplejuce/actions)

Pamplejuce is a ~~template~~ lifestyle for creating and building JUCE plugins in 2022.

Out of the box, it supports:

1. C++20
2. JUCE 7.x as a submodule tracking develop
3. CMake 3.24.1 and higher for building cross-platform
4. [Catch2](https://github.com/catchorg/Catch2) v3.3.2 as the test framework and runner
5. [pluginval](http://github.com/tracktion/pluginval) 1.x for plugin validation
6. GitHub Actions config for [installing Intel IPP](https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html), building binaries, running Catch2 tests and pluginval, artifact building on the Windows, Linux and macOS platforms, including [code signing and notarization on macOS](https://melatonin.dev/blog/how-to-code-sign-and-notarize-macos-audio-plugins-in-ci/) and [Windows EV/OV code signing via Azure Key Vault](https://melatonin.dev/blog/how-to-code-sign-windows-installers-with-an-ev-cert-on-github-actions/)

It also contains:

1. Proper `.gitignore` for all platforms
2. A `.clang-format` file 
3. A `VERSION` file that will propagate through to JUCE and your app.

## How does this all work at a high level?

Read up about [JUCE and CMmake on my blog!](https://melatonin.dev/blog/how-to-use-cmake-with-juce/).


## Setting up for YOUR project

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

7. If you are packaging and code signing, you'll want to take a look at the packaging/ directory and add assets and config that match your product. Otherwise you can delete the steps which do this.

## Conventions

1. Your tests will be in "Tests" and you can just add new .cpp files there.
2. Your binary data target is called "Assets"

## Releases

You can cut a release with downloadable assets by creating a tag starting with `v` and pushing it to GitHub. Note that you currently *must push the tag along with an actual commit*.

I recommend the workflow of bumping the VERSION file and then pushing that as a release, like so:

```
# edit VERSION
git commit -m "Releasing v0.0.2"
git tag v0.0.2
git push --tags
```

I'll work on making this less awkward...

Releases are set to `prerelease`, which means that uploaded release assets are visible to other users, but it's not explicitly listed as the latest release until changed in the GitHub UI.

## Code signing and Notarization

This repo [codesigns Windows via Azure Key Vault, read more about how to do that on my blog](https://melatonin.dev/blog/how-to-code-sign-windows-installers-with-an-ev-cert-on-github-actions/).

It also code signs and notarizes macOS, blog article coming soon, but there are many more examples of this in the wild.


## Tips n' Tricks

1. :warning: GitHub gives you 2000 or 3000 free GitHub Actions "minutes" for private projects, but [they actually bill 2x the number of minutes you use on Windows and 10x on MacOS](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-billing-and-payments-on-github/about-billing-for-github-actions#about-billing-for-github-actions).

2. There's a `VERSION` file in the root that you can treat as the main place to bump the version.

3. You might feel disincentivized to push to a private repo due to burning minutes. You can push a commit with `[ci skip]` in the message if you are doing things like updating the README. You have a few other big picture options, like doing testing/pluginval only on linux and moving everything else to release. The tradeoff is you won't be sure everything is happy on all platforms until the time you are releasing, which is the last place you really want friction. By default, multiple commits in quick succession will cancel the earlier builds.

## How do variables work in GitHub Actions?

It can be confusing, as the documentation is a big fragmented.

1. Things in double curly braces like `${{ matrix.name }}` are called ["contexts or expressions"](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions) and can be used to get, set, or perform simple operations.
2. In "if" conditions you can omit the double curly braces, as the whole condition is evaluated as an expression: `if: contains(github.ref, 'tags/v')`
3. You can set variables for the whole workflow to use in ["env"](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#env)
4. Reading those variables is done with the [env context](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#env-context) when you are inside a `with`, `name`, or `if`: `${{ env.SOME_VARIABLE }}`
5. Inside of `run`, you have access to bash ENV variables *in addition* to contexts/expressions. That means `$SOME_VARIABLE` or `${SOME_VARIABLE}` will work but *only when using bash* and [not while using powershell on windows](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#using-a-specific-shell). The version with curly braces (variable expansion) is often used [when the variable is forming part of a larger string to avoid ambiguity](https://stackoverflow.com/questions/8748831/when-do-we-need-curly-braces-around-shell-variables). Be sure that the ENV variable was set properly in the workflow/job/step before you use it. And if you need the variable to be os-agnostic, use the env context.

## How to update a repo based on Pamplejuce

1. Update with the latest CMake version [listed here](https://github.com/lukka/get-cmake), or the latest version supported by your toolchain like VS or Clion.
2. Update JUCE with `git submodule update --remote --merge`
3. Check for an [IPP update from Intel](https://github.com/oneapi-src/oneapi-ci/blob/master/.github/workflows/build_all.yml#L10).
4. You'll have to manually compare CMakeLists.txt, as I assume you made a changes. In the future, I may move most of the cmake magic into helpers to keep the main CMakesList.txt cleaner. 

## References & Inspiration

### CMake

* [The "Modern CMake" gitbook](https://cliutils.gitlab.io/) which also has a section on [https://cliutils.gitlab.io/modern-cmake/chapters/testing/catch.html](Catch2).
* [Effective Modern CMake](https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1)
* JUCE's announcement of [native CMake support](https://forum.juce.com/t/native-built-in-cmake-support-in-juce/38700)
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

### Packaging, Code Signing and Notarization 

* [iPlug Packages and Inno Setup scripts](https://github.com/olilarkin/wdl-ol/tree/master/IPlugExamples/IPlugEffect/installer)
* [Surge's pkgbuild installer script](https://github.com/kurasu/surge/blob/master/installer_mac/make_installer.sh)
* [Chris Randall's PackageBuilder script](https://forum.juce.com/t/vst-installer/16654/15)
* [David Cramer's GA Workflow for signing and notarizing](https://medium.com/better-programming/indie-mac-app-devops-with-github-actions-b16764a3ebe7) and his [notarize-cli tool](https://github.com/bacongravy/notarize-cli)
