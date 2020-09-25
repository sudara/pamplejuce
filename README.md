CMake, Catch2, 

## About This Repository

It's meant as an example of 2020 best practices.

1. JUCE as a submodule, tracking the devlop branch

## How to manually setup cmake for JUCE

1. [Download CMAKE](https://cmake.org/download/)

2. Take a look at [JUCE's default CMakeLists.txt](https://github.com/juce-framework/JUCE/tree/master/examples/CMake/AudioPlugin) and copy it over to your new project.

3. Replace `AudioPluginExample` with the name of your project.

4. Set JUCE path. Uncomment the `add_subdirectory` example. Let's add JUCE as a submodule. I'm assuming we want the develop branch.

```
git submodule add --branch develop --force -- https://github.com/juce-framework/JUCE/ JUCE
```

Let's commit those changes.

```
git commit .gitmodules JUCE -m 'Adding JUCE as a submodule'
```

5. Set the correct flags for your plugin under `juce_add_plugin`. Check out the API https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md

