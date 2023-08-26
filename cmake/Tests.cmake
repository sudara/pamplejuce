# Required for ctest (which is just easier for cross-platform CI)
# include(CTest) does this too, but adds tons of targets we don't want
# See: https://github.com/catchorg/Catch2/issues/2026
# You also could forgo ctest and call ./Tests directly from the build dir
enable_testing()

# "GLOBS ARE BAD" is brittle and silly dev UX, sorry CMake!
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
    GIT_TAG v3.3.2)
FetchContent_MakeAvailable(Catch2) # find_package equivalent

# Setup the test executable, again C++ 20 please
add_executable(Tests ${TestFiles})
target_compile_features(Tests PRIVATE cxx_std_20)

# Our test executable also wants to know about our plugin code...
target_include_directories(Tests PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Source)

# We also want to copy over compile definitions from our plugin target
target_compile_definitions(Tests PRIVATE $<TARGET_PROPERTY:${PROJECT_NAME},COMPILE_DEFINITIONS>)

# And give tests access to our shared code
target_link_libraries(Tests PRIVATE SharedCode Catch2::Catch2WithMain)

# Make an Xcode Scheme for the test executable so we can run tests in the IDE
set_target_properties(Tests PROPERTIES XCODE_GENERATE_SCHEME ON)

# When running Tests we have specific needs
target_compile_definitions(Tests PUBLIC
    JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
    RUN_PAMPLEJUCE_TESTS=1 # lets us run tests in module .cpp files
)

# Organize the test source in the Tests/ folder in the IDE
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/Tests PREFIX "" FILES ${TestFiles})

# Load and use the .cmake file provided by Catch2
# https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md
# We have to manually provide the source directory here for now
include(${Catch2_SOURCE_DIR}/extras/Catch.cmake)
catch_discover_tests(Tests)
