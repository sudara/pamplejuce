# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## First-Time Setup

If the values below still say "Pamplejuce" or "Pamplejuce Demo", this project was freshly created from the template and hasn't been personalized yet. Ask the user:

1. **What's your plugin called?** (display name for DAWs, e.g. "Super Synth")
2. **What's your company name?** (e.g. "My Audio Co")
3. **What type of plugin is this?** (synth, effect, utility, etc.)
4. **What IDE do you use?** (CLion, VS Code, Xcode, other)
5. **Do you want CI/CD via GitHub Actions?** Note: public repos get unlimited CI minutes, but private repos have a limited monthly allowance. If they're on a private repo and want to avoid burning minutes during active development, suggest commenting out matrix entries in the workflow to build on just one platform (e.g. only their dev OS) and running tests only — they can re-enable the full matrix when preparing a release.
6. **If using CI, do you need Intel IPP?** (provides SIMD-optimized DSP functions — if not, comment out the IPP install steps in the workflow to avoid CI failures)
7. **Are you code signing?** Code signing is essentially required to distribute to anyone (beta testers, friends, customers) — without it, macOS Gatekeeper and Windows SmartScreen will block or warn on the plugin. But it can be set up later; it's fine to skip during early development. Ask separately for macOS and Windows:
   - **macOS**: codesigning + notarization requires an Apple Developer account ($99/year). If not signing yet, comment out the codesign/notarize steps in the CI workflow. Guide: [How to code sign and notarize macOS audio plugins in CI](https://melatonin.dev/blog/how-to-code-sign-and-notarize-macos-audio-plugins-in-ci/)
   - **Windows**: Azure Trusted Signing is the recommended approach (free tier available). If not signing yet, comment out the Azure signing step. Guide: [Code signing on Windows with Azure Trusted Signing](https://melatonin.dev/blog/code-signing-on-windows-with-azure-trusted-signing/)

Then:
- Update `CMakeLists.txt`: set `PROJECT_NAME` (no spaces), `PRODUCT_NAME` (display name), `COMPANY_NAME`, `BUNDLE_ID`, `PLUGIN_MANUFACTURER_CODE` (4 chars), and `PLUGIN_CODE` (4 chars)
- Let the user know: builds default to **Debug** mode for development (faster builds, better debugging). If they're making music with the plugin and experiencing performance issues (audio dropouts, high CPU), they should ask to build in **Release** mode instead.
- Rewrite the **Build Commands** section below to match their IDE:
  - **CLion**: use `cmake-build-debug` / `cmake-build-release` as build directories (CLion's defaults — sharing them avoids duplicate builds). Use `-G Ninja` with CLion's bundled ninja so the `.ninja_log` format stays compatible between CLI and IDE builds.
  - **VS Code**: use `build` or `Builds` as the build directory. Recommend Ninja + the CMake Tools extension.
  - **Xcode**: use `-G Xcode` and open the generated `.xcodeproj`. CLI builds can use `Builds` with Ninja.
- If they don't want CI right now, comment out the platforms in the matrix they don't need
- If they don't need IPP, comment out the IPP install steps in the workflow
- If they're not code signing on a platform, comment out the relevant signing/notarization steps in the workflow
- Remove this setup section from CLAUDE.md once complete

## About This Project

This project is derived from the [Pamplejuce](https://github.com/sudara/pamplejuce) template — a JUCE audio plugin template using CMake, C++23, and modern CI/CD. It builds cross-platform (macOS, Windows, Linux) with support for multiple plugin formats (VST3, AU, AUv3, CLAP, Standalone).

The template provides the build system, CI/CD, and project structure. The plugin-specific logic lives in `source/`.

## Build Commands

```bash
# Configure (run once, or after CMakeLists.txt changes)
cmake -B Builds -DCMAKE_BUILD_TYPE=Debug

# Build
cmake --build Builds --config Debug

# Run tests (from project root)
ctest --test-dir Builds --verbose --output-on-failure

# Or run tests directly
./Builds/Tests

# Run a single test by name
./Builds/Tests "[test name]"

# Run benchmarks
./Builds/Benchmarks
```

For faster builds, add Ninja: `cmake -B Builds -G Ninja -DCMAKE_BUILD_TYPE=Debug`

On macOS for universal binary: `-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"`

## Project Structure

- `source/` - Plugin source code (PluginProcessor, PluginEditor)
- `tests/` - Catch2 test files
- `benchmarks/` - Catch2 benchmark files
- `cmake/` - CMake modules (Tests.cmake, Benchmarks.cmake, Assets.cmake, etc.)
- `modules/` - Git submodules: clap-juce-extensions, melatonin_inspector
- `JUCE/` - JUCE framework (git submodule)
- `assets/` - Binary resources (auto-included via juce_add_binary_data)
- `packaging/` - Installer resources and scripts

## Architecture

**SharedCode Library**: The `SharedCode` INTERFACE library links plugin source code to both the main plugin target and the Tests target, avoiding ODR violations.

**CMake Modules**:
- `PamplejuceVersion.cmake` - Reads VERSION file, optional auto-bump patch level
- `Assets.cmake` - Auto-includes all files in assets/ as binary data
- `Tests.cmake` - Configures Catch2 test target
- `Benchmarks.cmake` - Configures Catch2 benchmark target
- `PamplejuceIPP.cmake` - Intel IPP integration (optional)

**Test Discovery**: Uses `catch_discover_tests()` with `PRE_TEST` discovery mode for Xcode compatibility.

## Key Configuration

Edit `CMakeLists.txt` to customize:
- `PROJECT_NAME` - Internal name (no spaces)
- `PRODUCT_NAME` - Display name in DAWs (can have spaces)
- `COMPANY_NAME` - Used for bundle name
- `BUNDLE_ID` - macOS bundle identifier
- `FORMATS` - Plugin formats to build (Standalone AU VST3 AUv3)
- `PLUGIN_MANUFACTURER_CODE` / `PLUGIN_CODE` - 4-character plugin IDs

Version is read from the `VERSION` file in project root.

## Code Quality

Always resolve any compile warnings encountered during builds. Warnings should be treated as errors and fixed before considering a task complete.

Note: LSP/clangd often reports false positive diagnostic errors (like "undeclared identifier", "file not found") because it doesn't have full context of the JUCE module system. Ignore these unless the actual build fails.

## Includes

JUCE modules include common standard library headers (`<vector>`, `<algorithm>`, `<string>`, `<memory>`, etc.) so you don't need to add those explicitly in JUCE code. Adding them is harmless but redundant.

## Threading Model

JUCE plugins have two main threads:

- **Audio thread**: Runs `processBlock` — must be realtime-safe (see below). Never block, allocate, or lock.
- **Message thread**: Runs UI callbacks, parameter listeners, and timer callbacks. Owns the `MessageManager`.

To communicate between them:
- **Simple values**: Use `std::atomic` or JUCE's `AudioParameterFloat`/`AudioParameterBool` (which are atomic under the hood)
- **Larger data**: Use a lock-free queue (e.g. `moodycamel::ReaderWriterQueue`) to pass data from message → audio thread
- **Audio → UI updates**: Use `juce::AsyncUpdater` or `juce::Timer` on the message thread to poll state — never call UI code from the audio thread

## Realtime Safety

For anything in the audio thread / hot DSP path (e.g. `processBlock`):
- Allocate in constructors or `prepareToPlay`, not while rendering audio
- Avoid dynamic allocations and container growth (`std::vector::push_back`, map insertion, string building)
- Prefer fixed-size storage (`std::array`, preallocated buffers, fixed-capacity queues)
- Keep operations deterministic and lock-free where possible

## Adding Dependencies

**JUCE Modules** live in `modules/` as git submodules. Add with `git submodule add`, then `add_subdirectory` and link to `SharedCode` in `CMakeLists.txt`. Some useful ones:

- [melatonin_inspector](https://github.com/sudara/melatonin_inspector) — runtime component debugger (already included)
- [melatonin_blur](https://github.com/sudara/melatonin_blur) — fast cross-platform blurs for C++ UI (shadows, glows, frosted glass)
- [melatonin_perfetto](https://github.com/sudara/melatonin_perfetto) — performance tracing with Perfetto, great for profiling `processBlock` and paint calls
- [gin](https://github.com/FigBug/gin) — large collection of utilities (DSP, UI components, LookAndFeel, etc.)

**Non-JUCE C++ libraries** should be added via [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) which is already configured. CPM downloads and caches dependencies at configure time — no submodule needed:

```cmake
CPMAddPackage("gh:nlohmann/json@3.11.3")
target_link_libraries(SharedCode INTERFACE nlohmann_json::nlohmann_json)
```

Some useful CPM libraries:
- [nlohmann/json](https://github.com/nlohmann/json) — JSON parsing/serialization
- [cameron314/readerwriterqueue](https://github.com/cameron314/readerwriterqueue) — lock-free single-producer/single-consumer queue, ideal for audio↔message thread communication

## Code Style

Uses `.clang-format` with Allman-style braces, 4-space indentation, no column limit.
