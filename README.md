![PAMPLEJUCE](assets/images/pamplejuce.png)
[![](https://github.com/sudara/pamplejuce/workflows/Pamplejuce/badge.svg)](https://github.com/sudara/pamplejuce/actions)

Pamplejuce is a ~~template~~ lifestyle for creating and building JUCE plugins in 2023.

Out of the box, it:

1. Supports C++20.
2. Uses JUCE 7.x as a submodule tracking develop.
3. Relies on CMake 3.24.1 and higher for cross-platform building.
4. Has [Catch2](https://github.com/catchorg/Catch2) v3.4.0 for the test framework and runner.
5. Includes a Tests target and a Benchmarks target with examples to get started quickly.
6. Has [Melatonin Inspector](https://github.com/sudara/melatonin_inspector) installed as a JUCE module to help relieve headaches when building plugin UI.

It also has integration with GitHub Actions, specifically:

1. Building and testing cross-platform (linux, macOS, Windows) binaries
2. Running tests and benchmarks in CI
3. Running [pluginval](http://github.com/tracktion/pluginval) 1.x against the binaries for plugin validation
4. Config for [installing Intel IPP](https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html)
5. [Code signing and notarization on macOS](https://melatonin.dev/blog/how-to-code-sign-and-notarize-macos-audio-plugins-in-ci/)
6. [Windows EV/OV code signing via Azure Key Vault](https://melatonin.dev/blog/how-to-code-sign-windows-installers-with-an-ev-cert-on-github-actions/)

It also contains:

1. A `.gitignore` for all platforms.
2. A `.clang-format` file for keeping code tidy.
3. A `VERSION` file that will propagate through JUCE and your app.
4. A ton of useful comments and options around the CMake config.

## How does this all work at a high level?

If you are new to CMake, I suggest you read up about [JUCE and CMmake on my blog!](https://melatonin.dev/blog/how-to-use-cmake-with-juce/)


## Setting up for YOUR project

This is a template repo! 

That means the easiest thing to do is click "[Use this template](https://github.com/sudara/pamplejuce/generate)" here or at the top of the page to get your own repo with all the code here.

For an example of a plugin that uses this repo, check out [Load Monster!](https://github.com/sudara/load_monster_plugin).

After you've created a new repo from the template, you have a checklist of things to do to customize for your project:

* [ ] `git clone` your new repo (if you make it private, see the warning below about GitHub Actions minutes)

* [ ] [Download CMAKE](https://cmake.org/download/) if you aren't already using it (Clion and VS2022 both have it bundled, so you can skip this step in those cases).

* [ ] Populate the  JUCE by running `git submodule update --init` in your repository directory. By default, this will track JUCE's `develop` branch, which is a good default until you are at the point of releasing a plugin. It will also pull in the CMake needed and an example module, my component inspector.

* [ ] Replace `Pamplejuce` with the name of your project in `CMakeLists.txt` where the `PROJECT_NAME` variable is first set. Make this all one word, no spaces. 

* [ ] Adjust which plugin formats you want built as needed (VST3, AU, etc).

* [ ] Set the correct flags for your plugin `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md and be sure to change things like `PLUGIN_CODE` and `PLUGIN_MANUFACTURER_CODE` and everything that says `Change me!`.
  
* [ ] Build n' Run! If you want to generate an Xcode project, run `cmake -B Builds -G Xcode`. Or just open the project in CLion or VS2022. Running the standalone might be easiest, but you can also build the `AudioPluginHost` that comes with JUCE. Out of the box, Pamplejuce's VST3/AU targets should already be pointing to it's built location.

* [ ] If you want to package and code sign, you'll want to take a look at the packaging/ directory add assets and config that match your product. Otherwise, you can delete the GitHub Action workflow steps that handle packaging (macOS will need code signing steps to work properly).

This is what you will see when it's built, the plugin displaying its version number with a button that opens up the [Melatonin Inspector](https://github.com/sudara/melatonin_inspector): 

![Pamplejuce v1 - 2023-08-28 41@2x](https://github.com/sudara/pamplejuce/assets/472/33a9c8d5-fc3f-42e7-bd06-21a1559c7128)

## Conventions

1. Your tests go in "/tests", just add .cpp files there.
2. Additional 3rd party JUCE modules go in "/modules."
3. Your binary data target in CMake is called "Assets" (you need to include `BinaryData.h` to access it)
4. GitHub Actions will run against Linux, Windows, and macOS unless modified.

## Cutting GitHub Releases

Cut a release with downloadable assets by creating a tag starting with `v` and pushing it to GitHub. Note that you currently *must push the tag along with an actual commit*.

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

It also [code signs and notarizes on macOS, again, you can read my article for details](https://melatonin.dev/blog/how-to-code-sign-and-notarize-macos-audio-plugins-in-ci/).


## A note on GitHub Actions and macOS

:warning: GitHub gives you 2000 or 3000 free GitHub Actions "minutes" / month for private projects, but [they actually bill 2x the number of minutes you use on Windows and 10x on MacOS](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-billing-and-payments-on-github/about-billing-for-github-actions#about-billing-for-github-actions).

If you made the repo private, you might feel disincentivized to push as you would burn through minutes. Note you can push a commit with `[ci skip]` in the message if you are doing things like updating the README. You have a few other big picture options, like doing testing/pluginval only on linux and moving everything else to release only. The tradeoff is you won't be sure everything is happy on all platforms until the time you are releasing, which is the last place you really want friction. By default, multiple commits in quick succession will cancel the earlier builds.

## How do variables work in GitHub Actions?

It can be confusing, as the documentation is a big fragmented.

1. Things in double curly braces like `${{ matrix.name }}` are called ["contexts or expressions"](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions) and can be used to get, set, or perform simple operations.
2. In "if" conditions you can omit the double curly braces, as the whole condition is evaluated as an expression: `if: contains(github.ref, 'tags/v')`
3. You can set variables for the whole workflow to use in ["env"](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#env)
4. Reading those variables is done with the [env context](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions#env-context) when you are inside a `with`, `name`, or `if`: `${{ env.SOME_VARIABLE }}`
5. Inside of `run`, you have access to bash ENV variables *in addition* to contexts/expressions. That means `$SOME_VARIABLE` or `${SOME_VARIABLE}` will work but *only when using bash* and [not while using powershell on windows](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-syntax-for-github-actions#using-a-specific-shell). The version with curly braces (variable expansion) is often used [when the variable is forming part of a larger string to avoid ambiguity](https://stackoverflow.com/questions/8748831/when-do-we-need-curly-braces-around-shell-variables). Be sure that the ENV variable was set properly in the workflow/job/step before you use it. And if you need the variable to be os-agnostic, use the env context.

## How to update a repo based on Pamplejuce

1. Update with the latest CMake version [listed here](https://github.com/lukka/get-cmake), or the latest version supported by your toolchain like VS or Clion.
2. Update JUCE with `git submodule update --remote --merge JUCE`
3. Update the inspector with `git submodule update --remote --merge modules/melatonin_inspector`
4. Check for an [IPP update from Intel](https://github.com/oneapi-src/oneapi-ci/blob/master/.github/workflows/build_all.yml#L10).
5. If you want to update to the latest CMake config Pamplejuce uses, first check the repository's [CHANGELOG](https://github.com/sudara/cmake-includes/blob/main/CHANGELOG.md) to make sure you are informed of any breaking changes. Then. `git submodule update --remote --merge cmake`. Unfortunately, you'll have to manually compare `CMakeLists.txt`, but it should be pretty easy to see what changed.

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
