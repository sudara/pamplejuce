#include <PluginProcessor.h>
#include <catch2/benchmark/catch_benchmark.hpp>
#include <catch2/catch_test_macros.hpp>
#include <catch2/matchers/catch_matchers_string.hpp>

TEST_CASE ("one is equal to one", "[dummy]")
{
    REQUIRE (1 == 1);
}

// https://github.com/McMartin/FRUT/issues/490#issuecomment-663544272
AudioPluginAudioProcessor testPlugin;

TEST_CASE ("Plugin instance name", "[name]")
{
    CHECK_THAT (testPlugin.getName().toStdString(),
        Catch::Matchers::Equals ("Pamplejuce"));
}

TEST_CASE ("Benchmark editor opening")
{
    BENCHMARK_ADVANCED ("editor open")
    (Catch::Benchmark::Chronometer meter)
    {
        AudioPluginAudioProcessor plugin;
        auto gui = juce::ScopedJuceInitialiser_GUI {};
        meter.measure ([&] {
            auto editor = plugin.createEditorIfNeeded();
            plugin.editorBeingDeleted (editor);
            delete editor;
            return plugin.getActiveEditor();
        });
    };
}

#ifdef PAMPLEJUCE_IPP
    #include <ipps.h>

TEST_CASE ("IPP version", "[ipp]")
{
    CHECK_THAT (ippsGetLibVersion()->Version, Catch::Matchers::Equals ("2021.7 (r0xa954907f)"));
}
#endif
