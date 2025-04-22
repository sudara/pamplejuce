![PAMPLEJUCE](assets/images/pamplejuce.png)
[![](https://github.com/sudara/pamplejuce/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/sudara/pamplejuce/actions)

Pamplejuce is a ~~template~~ lifestyle for creating and building JUCE plugins in 2025.

Out-of-the-box, it:

1. Supports C++20.
2. Uses JUCE 8.x as a git submodule (tracking develop).
3. Uses CPM for dependency management.
3. Relies on CMake 3.25 and higher for cross-platform building.
4. Has [Catch2](https://github.com/catchorg/Catch2) v3.7.1 for the test framework and runner.
5. Includes a `Tests` target and a `Benchmarks` target with examples to get started quickly.
6. Has [Melatonin Inspector](https://github.com/sudara/melatonin_inspector) installed as a JUCE module to help relieve headaches when building plugin UI.

It also has integration with GitHub Actions, specifically:

1. Building and testing cross-platform (linux, macOS, Windows) binaries
2. Running tests and benchmarks in CI
3. Running [pluginval](http://github.com/tracktion/pluginval) 1.x against the binaries for plugin validation
4. Config for [installing Intel IPP](https://www.intel.com/content/www/us/en/developer/tools/oneapi/ipp.html)
5. [Code signing and notarization on macOS](https://melatonin.dev/blog/how-to-code-sign-and-notarize-macos-audio-plugins-in-ci/)
6. [Windows code signing via Azure Trusted Signing](https://melatonin.dev/blog/code-signing-on-windows-with-azure-trusted-signing/)

It also contains:

1. A `.gitignore` for all platforms.
2. A `.clang-format` file for keeping code tidy.
3. A `VERSION` file that will propagate through JUCE and your app.
4. A ton of useful comments and options around the CMake config.

## How does this all work at a high level?

Check out the [official Pamplejuce documentation](https://melatonin.dev/manuals/pamplejuce/how-does-this-all-work/).

[![Arc - 2024-10-01 51@2x](https://github.com/user-attachments/assets/01d19d2d-fbac-481f-8cec-e9325b2abe57)](https://melatonin.dev/manuals/pamplejuce/how-does-this-all-work/)

## Setting up for YOUR project

This is a template repo!

That means you can click "[Use this template](https://github.com/sudara/pamplejuce/generate)" here or at the top of the page to get your own copy (not fork) of the repo. Then you can make it private or keep it public, up to you.

Then check out the [documentation](https://melatonin.dev/manuals/pamplejuce/setting-your-project-up/) so you know what to tweak. 

> [!NOTE]
> Tests will immediately run and fail (go red) until you [set up code signing](https://melatonin.dev/manuals/pamplejuce/getting-started/code-signing/).

## Having Issues?

Thanks to everyone who has contributed to the repository. 

This repository covers a _lot_ of ground. JUCE itself has a lot of surface area. It's a group effort to maintain the garden and keep things nice!

If something isn't just working out of the box — *it's probably not just you* — others are running into the problem, too, I promise. Check out [the official docs](https://melatonin.dev/manuals/pamplejuce), then please do [open an issue](https://github.com/sudara/pamplejuce/issues/new)!
