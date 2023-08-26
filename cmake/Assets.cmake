# Setup our binary data as a target called Assets
juce_add_binary_data(Assets SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/pamplejuce.png)

# Required for Linux happiness:
# See https://forum.juce.com/t/loading-pytorch-model-using-binarydata/39997/2
set_target_properties(Assets PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
