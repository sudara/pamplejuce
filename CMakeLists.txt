# 3.24.1 is bundled in Visual Studio 2022 v17.4
# 3.24.1 is also bundled in CLion as of 2023
cmake_minimum_required(VERSION 3.24.1)

# This is the name of your plugin
# This cannot have spaces (but PRODUCT_NAME can)
set(PROJECT_NAME "Pamplejuce")

# Set the plugin formats you'll be building here.
# Valid formats: AAX Unity VST AU AUv3 Standalone
set(FORMATS AU VST3 AUv3)

# Reads in our VERSION file and sticks in it CURRENT_VERSION variable
# Be sure the file has no newlines!
file(STRINGS VERSION CURRENT_VERSION)

# For simplicity, the name of the project is also the name of the target
project(${PROJECT_NAME} VERSION ${CURRENT_VERSION})

# Keep this file tidy by allowing us to keep details in the cmake folder
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Couple tweaks that IMO should be JUCE defaults
include (JUCEDefaults)

# JUCE is setup as a submodule in the /JUCE folder
# Locally, you'll need to run `git submodule update --init --recursive` once
# and `git submodule update --remote --merge` to keep it up to date
# On Github Actions, it's managed by actions/checkout
add_subdirectory(JUCE)

# Check the readme at `docs/CMake API.md` in the JUCE repo for full config
juce_add_plugin("${PROJECT_NAME}"
    # VERSION ...                               # Set this if the plugin version is different to the project version
    # ICON_BIG ...                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
    # ICON_SMALL ...
    COMPANY_NAME Pamplejuce
    BUNDLE_ID com.pamplejuce.pamplejuce
    # IS_SYNTH TRUE/FALSE                       # Is this a synth or an effect?
    # NEEDS_MIDI_INPUT TRUE/FALSE               # Does the plugin need midi input?
    # NEEDS_MIDI_OUTPUT TRUE/FALSE              # Does the plugin need midi output?
    # IS_MIDI_EFFECT TRUE/FALSE                 # Is this plugin a MIDI effect?
    # EDITOR_WANTS_KEYBOARD_FOCUS TRUE/FALSE    # Does the editor need keyboard focus?
    COPY_PLUGIN_AFTER_BUILD TRUE # On MacOS, plugin will be copied to /Users/you/Library/Audio/Plug-Ins/
    PLUGIN_MANUFACTURER_CODE Pamp               # This has to be one uppercase, rest lower for AU formats
    PLUGIN_CODE P001                            # A unique four-character plugin id with at least one upper-case character
    FORMATS "${FORMATS}"
    PRODUCT_NAME "${PROJECT_NAME}")        # The name of the final executable, which can differ from the target name

# This lets us use our code in both the JUCE targets and our Test target
# Without running into ODR violations
add_library(SharedCode INTERFACE)

# C++20, please
target_compile_features(SharedCode INTERFACE cxx_std_20)

# Manually list all .h and .cpp files for the plugin
set(SourceFiles
    Source/PluginEditor.h
    Source/PluginProcessor.h
    Source/PluginEditor.cpp
    Source/PluginProcessor.cpp)
target_sources(SharedCode INTERFACE ${SourceFiles})


# Adds an example BinaryData target for embedding assets into the binary
include (Assets)

# MacOS only: Clean up folder organization on Xcode.
include (Xcode)

target_compile_definitions(SharedCode
    INTERFACE
    # JUCE_WEB_BROWSER and JUCE_USE_CURL would be on by default, but you might not need them.
    JUCE_WEB_BROWSER=0  # If you remove this, add `NEEDS_WEB_BROWSER TRUE` to the `juce_add_plugin` call
    JUCE_USE_CURL=0     # If you remove this, add `NEEDS_CURL TRUE` to the `juce_add_plugin` call
    JUCE_VST3_CAN_REPLACE_VST2=0)

# Any dependency you want to add should be linked to SharedCode as INTERFACE
# So both the JUCE targets and the Tests target can use it
target_link_libraries(SharedCode
    INTERFACE
    Assets
    juce::juce_audio_utils
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags)

# Link the JUCE plugin targets our SharedCode target
target_link_libraries("${PROJECT_NAME}" PRIVATE SharedCode)

# Comment to disable IPP
include (PamplejuceIPP)

# Comment to disable tests
include (Tests)
