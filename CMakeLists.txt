# 3.24.1 is bundled in Visual Studio 2022 v17.4
# 3.24.1 is also bundled in CLion as of 2023
cmake_minimum_required(VERSION 3.24.1)

# This tells cmake we have goodies in the /cmake folder
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# This is the name of your plugin
# Change me! Note: It cannot have spaces (but PRODUCT_NAME can)
set(PROJECT_NAME "Pamplejuce")

include (PamplejuceVersion)

# By default, we add the major version on the end of the plugin name like  _v1
# Different major versions then show up in DAWs as separate plugins
# This lets you change parameters and behavior without breaking user projects
# Comment the following line to disable this behavior
set(PROJECT_NAME "Pamplejuce_v${MAJOR_VERSION}")

# Set the plugin formats you'll be building here.
# Valid choices here: AAX Unity VST VST3 AU AUv3 Standalone
set(FORMATS Standalone AU VST3 AUv3)

# For simplicity, the name of the CMake project is also the name of the target
project(${PROJECT_NAME} VERSION ${CURRENT_VERSION})

# Couple tweaks that IMO should be JUCE defaults
include(JUCEDefaults)

# JUCE is setup as a submodule in the /JUCE folder
# Locally, you must run `git submodule update --init --recursive` once
# and later `git submodule update --remote --merge` to keep it up to date
# On Github Actions, this is done as a part of actions/checkout
add_subdirectory(JUCE)

# See `JUCE/docs/CMake API.md` in the JUCE repo for all config options
juce_add_plugin("${PROJECT_NAME}"
    # ICON_BIG ... # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
    # ICON_SMALL ...

    # Change me!
    COMPANY_NAME Pamplejuce
    BUNDLE_ID com.pamplejuce.pamplejuce

    # On MacOS, plugin will be copied to /Users/you/Library/Audio/Plug-Ins/
    COPY_PLUGIN_AFTER_BUILD TRUE

    # Change me!
    # A four-character plugin id
    # First character MUST be uppercase  AU formats
    PLUGIN_MANUFACTURER_CODE Pamp

    # Change me!
    # A unique four-character plugin id
    # Note: this must have at least one upper-case character to please DAWs
    PLUGIN_CODE P001
    FORMATS "${FORMATS}"

    # Change me!
    # The name of your final executable
    # This is how it's listed in the DAW
    # This can be different from PROJECT_NAME and can have spaces!
    PRODUCT_NAME "Pamplejuce v1")

# This lets us use our code in both the JUCE targets and our Test target
# Without running into ODR violations
add_library(SharedCode INTERFACE)

# C++20, please
# Use cxx_std_23 for C++23 (as of CMake v 3.20)
target_compile_features(SharedCode INTERFACE cxx_std_20)

# Manually list all .h and .cpp files for the plugin
# If you are like me, you'll use globs for your sanity.
# Just ensure you employ CONFIGURE_DEPENDS so the build system picks up changes
# If you want to appease the CMake gods and avoid globs, manually add files like so:
# set(SourceFiles Source/PluginEditor.h Source/PluginProcessor.h Source/PluginEditor.cpp Source/PluginProcessor.cpp)
file(GLOB_RECURSE SourceFiles CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/Source/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/Source/*.h")
target_sources(SharedCode INTERFACE ${SourceFiles})

# Adds a BinaryData target for embedding assets into the binary
include(Assets)

# MacOS only: Clean up folder organization on Xcode.
include(Xcode)

target_compile_definitions(SharedCode
    INTERFACE
    # JUCE_WEB_BROWSER and JUCE_USE_CURL are default on, but you might not need them.
    JUCE_WEB_BROWSER=0  # If you set this to 1, add `NEEDS_WEB_BROWSER TRUE` to the `juce_add_plugin` call
    JUCE_USE_CURL=0     # If you set this to 1, add `NEEDS_CURL TRUE` to the `juce_add_plugin` call
    JUCE_VST3_CAN_REPLACE_VST2=0)

# Usually JUCE modules should have PRIVATE visibility
# See https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md#juce_add_module
# However, with Pamplejuce, you will link your modules to SharedCode with INTERFACE visibility
# This allows JUCE targets and the Tests target to link against it
target_link_libraries(SharedCode
    INTERFACE
    Assets
    juce::juce_audio_utils
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags)

# Link the JUCE plugin targets our SharedCode target
target_link_libraries("${PROJECT_NAME}" PRIVATE SharedCode)

# IPP support, comment out to disable
include(PamplejuceIPP)

# Tests target, comment out to disable
include(Tests)
