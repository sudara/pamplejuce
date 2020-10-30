#define CATCH_CONFIG_MAIN
#include "Catch2/catch.hpp"

TEST_CASE("one is equal to zero", "[dummy]")
{
	REQUIRE(1 == 0);
}