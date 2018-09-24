// Dyl/an Tucker
// cs411
// A2 24/9/2018

#include "build.hpp"
#include <vector>


using Bridge = std::vector<int>;

int build(int west_cities, int east_cities, const std::vector<Bridge> & bridges)
{
	int toll = 0;
	int temp_toll = 0;
	int num_combinations = pow(2, bridges.size());
	std::vector<std::vector<Bridge>> bridge_combinations(num_combinations);
	bool valid = 1;

	// If 0 bridges return toll = 0
	if (bridges.size() == 0)
	{
		return toll;
	}

	// If 1 bridge return toll of that bridge
	if (bridges.size() == 1)
	{
		return bridges[0][2];
	}

	// Generate all combinations of n <= 32 bridges
	for (int i = 0; i < num_combinations; ++i)
	{
		for (int j = 0; j < 31; j++)
		{
			if (((i >> j) & 1) == 1)
			{
				bridge_combinations[i].push_back(bridges[j]);
			}
		}
	}

	for (int i = 0; i < num_combinations; ++i)
	{
		for (int j = 0; j < bridge_combinations[i].size(); ++j)
		{
			if (bridge_combinations[i].size() > 1)
			{
				for (int k = j + 1; k < bridge_combinations[i].size(); k++)
				{
					if (bridge_combinations[i][j][0] == bridge_combinations[i][k][0] ||
						bridge_combinations[i][j][1] == bridge_combinations[i][k][1] ||
						bridge_combinations[i][j][0] < bridge_combinations[i][k][0] && bridge_combinations[i][j][1] > bridge_combinations[i][k][1] ||
						bridge_combinations[i][j][0] > bridge_combinations[i][k][0] && bridge_combinations[i][j][1] < bridge_combinations[i][k][1])
					{
						valid = 0;
						break;
					}
					else
					{
						valid = 1;
					}
				}
			}

			if (valid)
			{
				temp_toll += bridge_combinations[i][j][2];
			}
			else
			{
				temp_toll = 0;
				break;
			}
		}
		if (temp_toll > toll)
		{
			toll = temp_toll;
		}
		temp_toll = 0;
		valid = 1;
	}
	
	return toll;
}