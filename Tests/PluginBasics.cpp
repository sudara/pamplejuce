#include "catch2/catch.hpp"
#include <PluginProcessor.h>

TEST_CASE("one is equal to one", "[dummy]")
{
	REQUIRE(1 == 1);
}

// https://github.com/McMartin/FRUT/issues/490#issuecomment-663544272
AudioPluginAudioProcessor testPlugin;
TEST_CASE("Plugin instance name", "[name]") {
    CHECK_THAT( testPlugin.getName().toStdString(), Catch::Equals( "Pamplejuce" ) );
}
