# 3.21 is bundled in VSCode 2022
# https://docs.microsoft.com/en-us/visualstudio/releases/2022/release-notes
# 3.21 is also bundled in CLion as of 2021.3
cmake_minimum_required(VERSION 3.21)

# Change this to the name of your plugin
# This cannot have spaces (but PRODUCT_NAME can)
set(PROJECT_NAME "Pamplejuce")

# Set the plugin formats you'll be building here.
# Valid formats: AAX Unity VST AU AUv3 Standalone
set(FORMATS AU VST3 AUv3)

# Reads in VERSION file and sticks in it CURRENT_VERSION variable
file(READ VERSION CURRENT_VERSION)

# For simplilicity, the name of the project is also the name of the target
project(${PROJECT_NAME} VERSION ${CURRENT_VERSION})

# By default we don't want Xcode schemes to be made for modules, etc
set(CMAKE_XCODE_GENERATE_SCHEME OFF)

# Building universals increases build times
# set(CMAKE_OSX_ARCHITECTURES arm64 x86_64)

# Adds all the module sources so they appear correctly in the IDE
# Must be set before JUCE is added as a sub-dir (or any targets are made)
# https://github.com/juce-framework/JUCE/commit/6b1b4cf7f6b1008db44411f2c8887d71a3348889
set_property(GLOBAL PROPERTY USE_FOLDERS YES)

# This is a failed attempt to bury ALL_BUILD in Targets/
# This should be called before any target is made
# Bug in Xcode? https://gitlab.kitware.com/cmake/cmake/-/issues/21383
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Targets")

# Create a /Modules directory in the IDE with the JUCE Module code
option(JUCE_ENABLE_MODULE_SOURCE_GROUPS "Show all module sources in IDE projects" ON)

# JUCE is setup as a submodule in the /JUCE folder
# Locally, you need to run `git submodule update --init --recursive` once
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
    PLUGIN_MANUFACTURER_CODE Pamp
    PLUGIN_CODE P001                            # A unique four-character plugin id with at least one upper-case character
    FORMATS "${FORMATS}"
    PRODUCT_NAME "${PROJECT_NAME}")        # The name of the final executable, which can differ from the target name

# C++20 please
target_compile_features("${PROJECT_NAME}" PRIVATE cxx_std_20)

# Manually list all .h and .cpp files for the plugin (avoiding globs):
set(SourceFiles
    Source/PluginEditor.h
    Source/PluginProcessor.h
    Source/PluginEditor.cpp
    Source/PluginProcessor.cpp)
target_sources("${PROJECT_NAME}" PRIVATE ${SourceFiles})

# No, we don't want our source buried in extra nested folders
set_target_properties("${PROJECT_NAME}" PROPERTIES FOLDER "")

# The Xcode source tree should uhhh, still look like the source tree, yo
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/Source PREFIX "" FILES ${SourceFiles})

# Setup our binary data as a target
juce_add_binary_data(Assets SOURCES pamplejuce.png)

# Required for Linux happiness:
# See https://forum.juce.com/t/loading-pytorch-model-using-binarydata/39997/2
set_target_properties(Assets PROPERTIES POSITION_INDEPENDENT_CODE TRUE)

# This cleans up the folder organization on Xcode.
# It tucks the Plugin varieties into a "Targets" folder and generate an Xcode Scheme manually
# Xcode scheme generation is turned off globally to limit noise from other targets
# The non-hacky way of doing this is via the global PREDEFINED_TARGETS_FOLDER property
# However that doesn't seem to be working in Xcode
# Not all plugin types (au, vst) available on each build type (win, macos, linux)
foreach(target ${FORMATS} "All")
    if(TARGET ${PROJECT_NAME}_${target})
        set_target_properties(${PROJECT_NAME}_${target} PROPERTIES
            # Tuck the actual plugin targets into a folder where they won't bother us
            FOLDER "Targets"

            # MacOS only: Sets the default executable that Xcode will open on build
            # For this exact path to to work, manually build the AudioPluginHost.xcodeproj in the JUCE subdir
            XCODE_SCHEME_EXECUTABLE "${CMAKE_CURRENT_SOURCE_DIR}/JUCE/extras/AudioPluginHost/Builds/MacOSX/build/Debug/AudioPluginHost.app"

            # Let us build the target in Xcode
            XCODE_GENERATE_SCHEME ON)
    endif()
endforeach()
set_target_properties(Assets PROPERTIES FOLDER "Targets")

# We'll need to link to these from our plugin as well as our tests
set(JUCE_DEPENDENCIES
    juce::juce_audio_utils)

target_compile_definitions("${PROJECT_NAME}"
    PUBLIC
    # JUCE_WEB_BROWSER and JUCE_USE_CURL would be on by default, but you might not need them.
    JUCE_WEB_BROWSER=0  # If you remove this, add `NEEDS_WEB_BROWSER TRUE` to the `juce_add_plugin` call
    JUCE_USE_CURL=0     # If you remove this, add `NEEDS_CURL TRUE` to the `juce_add_plugin` call
    JUCE_VST3_CAN_REPLACE_VST2=0)

target_link_libraries("${PROJECT_NAME}"
    PRIVATE
    Assets
    ${JUCE_DEPENDENCIES}
    PUBLIC
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags)


# Required for ctest (which is just easier for cross-platform CI)
# include(CTest) does this too, but adds tons of targets we don't want
# See: https://github.com/catchorg/Catch2/issues/2026
# You could forgo ctest and call ./Tests directly from the build dir
enable_testing()

# "GLOBS ARE BAD" is brittle and silly UX, sorry CMake!
# CONFIGURE_DEPENDS / Clion's CMake integration makes globbing absolutely fine
file(GLOB_RECURSE TestFiles CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/Tests/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/Tests/*.h")
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/Tests PREFIX "" FILES ${TestFiles})

# Use Catch2 v3 on the devel branch
Include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_PROGRESS TRUE
    GIT_SHALLOW TRUE
    GIT_TAG origin/devel)
FetchContent_MakeAvailable(Catch2) # find_package equivalent

# Setup the test executable, again C++ 20 please
add_executable(Tests ${TestFiles})
target_compile_features(Tests PRIVATE cxx_std_20)

# Our test executable also wants to know about our plugin code...
target_include_directories(Tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Source)
target_link_libraries(Tests PRIVATE Catch2::Catch2WithMain "${PROJECT_NAME}" ${JUCE_DEPENDENCIES})

# Make an Xcode Scheme for the test executable so we can run tests in the IDE
set_target_properties(Tests PROPERTIES XCODE_GENERATE_SCHEME ON)

# Organize the test source in the Tests/ folder in the IDE
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/Tests PREFIX "" FILES ${TestFiles})

# Load and use the .cmake file provided by Catch2
# https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md
# We have to manually provide the source directory here for now
include(${Catch2_SOURCE_DIR}/extras/Catch.cmake)
catch_discover_tests(Tests)