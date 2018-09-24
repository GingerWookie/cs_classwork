#ifndef BUILD_HPP
#define BUILD_HPP

#include <vector>

using Bridge = std::vector<int>;

int build(int west_cities, int east_cities, const std::vector<Bridge> & bridges);

#endif