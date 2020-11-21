#include "catch2/catch.hpp"
#include <PluginProcessor.h>

TEST_CASE("one is equal to one", "[dummy]")
{
	REQUIRE(1 == 1);
}

AudioPluginAudioProcessor testPlugin;
TEST_CASE("Plugin instance name", "[name]") {
    CHECK_THAT( testPlugin.getName().toStdString(), Catch::Equals( "Pamplejuce" ) );
}
