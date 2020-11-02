cmake_minimum_required(VERSION 3.18)
include(CMakePrintHelpers)
project(Pamplejuce VERSION 0.0.1)

# By default we don't want schemes to be made for modules, etc
set(CMAKE_XCODE_GENERATE_SCHEME OFF)

# No ZERO_CHECK target (it helps bust cache for cmake)
set(CMAKE_SUPPRESS_REGENERATION true) 

# Make sure catch2 CMake scripts can be found
# https://github.com/catchorg/Catch2/issues/2026
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake.modules/")

# Adds all the module sources so they appear correctly in the IDE
# This needs to be set before JUCE is added as a sub-dir
# https://github.com/juce-framework/JUCE/commit/6b1b4cf7f6b1008db44411f2c8887d71a3348889
set_property(GLOBAL PROPERTY USE_FOLDERS YES)

# This is a failed attempt to bury ALL_BUILD in Targets/
set(PREDEFINED_TARGETS_FOLDER "Targets")

# Create a /Modules directory with all the JUCE Module code
option(JUCE_ENABLE_MODULE_SOURCE_GROUPS "Show all module sources in IDE projects" ON)

# JUCE is a submodule
# Locally, you need to run `git submodule update --init --recursive` once
# On Github Actions, it's managed by actions/checkout
add_subdirectory(JUCE)

# Check the readme at `docs/CMake API.md` in the JUCE repo for full config
juce_add_plugin(Pamplejuce
    # VERSION ...                               # Set this if the plugin version is different to the project version
    # ICON_BIG ...                              # ICON_* arguments specify a path to an image file to use as an icon for the Standalone
    # ICON_SMALL ...
    # COMPANY_NAME ...                          # Specify the name of the plugin's author
    # IS_SYNTH TRUE/FALSE                       # Is this a synth or an effect?
    # NEEDS_MIDI_INPUT TRUE/FALSE               # Does the plugin need midi input?
    # NEEDS_MIDI_OUTPUT TRUE/FALSE              # Does the plugin need midi output?
    # IS_MIDI_EFFECT TRUE/FALSE                 # Is this plugin a MIDI effect?
    # EDITOR_WANTS_KEYBOARD_FOCUS TRUE/FALSE    # Does the editor need keyboard focus?
    # COPY_PLUGIN_AFTER_BUILD TRUE/FALSE        # Should the plugin be installed to a default location after building?
    PLUGIN_MANUFACTURER_CODE Pamp               # A four-character manufacturer id with at least one upper-case character
    PLUGIN_CODE P001                            # A unique four-character plugin id with at least one upper-case character
    FORMATS AU VST3 AUv3                      # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
    PRODUCT_NAME "Pamplejuce")        # The name of the final executable, which can differ from the target name


target_compile_features(Pamplejuce PRIVATE cxx_std_20)

# `juce_generate_juce_header` will create a JuceHeader.h for a given target, which will be generated
# into your build tree. This should be included with `#include <JuceHeader.h>`. The include path for
# this header will be automatically added to the target. The main function of the JuceHeader is to
# include all your JUCE module headers; if you're happy to include module headers directly, you
# probably don't need to call this.

# juce_generate_juce_header(Pamplejuce)

# `target_sources` adds source files to a target. We pass the target that needs the sources as the
# first argument, then a visibility parameter for the sources (PRIVATE is normally best practice,
# although it doesn't really affect executable targets). Finally, we supply a list of source files
# that will be built into the target. This is a standard CMake command.

# All .h and .cpp files should be listed here
set(SourceFiles
    Source/PluginEditor.h
    Source/PluginProcessor.h
    Source/PluginEditor.cpp
    Source/PluginProcessor.cpp)

target_sources(Pamplejuce PRIVATE ${SourceFiles})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/Source PREFIX "" FILES ${SourceFiles})

# Move the INTERFACE auto-created JUCE library stuff into its own folder
source_group("JUCE Library Code" REGULAR_EXPRESSION "juce_")

# TODO: XCODE_SCHEME_EXECUTABLE
# https://cliutils.gitlab.io/modern-cmake/chapters/features/ides.html

# This cleans up the folder organization, especially on Xcode.
# It tucks the Plugin varieties into a "Targets" folder and generate an Xcode Scheme manually
# since Xcode scheme generation is turned off to limit noise
# Not all plugin types (au, vst) available on each build type (win, macos, linux)
foreach(target Pamplejuce_AU Pamplejuce_AUv3 Pamplejuce_VST3 Pamplejuce_All)
    cmake_print_variables(target)
    if(TARGET ${target})
        message(STATUS "ITS A TARGET!")
        set_target_properties(${target} PROPERTIES 
            FOLDER "Targets"
            XCODE_GENERATE_SCHEME ON)
    endif()
endforeach()

# `target_compile_definitions` adds some preprocessor definitions to our target. In a Projucer
# project, these might be passed in the 'Preprocessor Definitions' field. JUCE modules also make use
# of compile definitions to switch certain features on/off, so if there's a particular feature you
# need that's not on by default, check the module header for the correct flag to set here. These
# definitions will be visible both to your code, and also the JUCE module code, so for new
# definitions, pick unique names that are unlikely to collide! This is a standard CMake command.

target_compile_definitions(Pamplejuce
    PUBLIC
    # JUCE_WEB_BROWSER and JUCE_USE_CURL would be on by default, but you might not need them.
    JUCE_WEB_BROWSER=0  # If you remove this, add `NEEDS_WEB_BROWSER TRUE` to the `juce_add_plugin` call
    JUCE_USE_CURL=0     # If you remove this, add `NEEDS_CURL TRUE` to the `juce_add_plugin` call
    JUCE_VST3_CAN_REPLACE_VST2=0)

juce_add_binary_data(Assets SOURCES pamplejuce.png)

# This runs enable_testing() unless BUILD_TESTING is OFF (it's ON by default)
include(CTest) 

# BUILD_TESTING is ON by default
if(BUILD_TESTING)
    Include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG        v2.13.2)
    FetchContent_MakeAvailable(Catch2) # find_package equivelant 

    add_executable(tests tests/catch_main.cpp)
    target_link_libraries(tests PRIVATE Catch2::Catch2)

    # Load and use the .cmake file provided by Catch2
    # https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md#parseandaddcatchtestscmake
    # 
    # We have to manually provide the source directory here for now
    # https://github.com/catchorg/Catch2/issues/2026
    include(${Catch2_SOURCE_DIR}/contrib/ParseAndAddCatchTests.cmake)
    ParseAndAddCatchTests(tests)
endif()

target_link_libraries(Pamplejuce
  PRIVATE
    Assets
    juce::juce_audio_utils
  PUBLIC
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags)
