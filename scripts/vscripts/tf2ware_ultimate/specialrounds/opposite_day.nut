
special_round <- Ware_SpecialRoundData
({
	name = "Opposite Day"
	author = "pokemonPasta"
	description = "Lowest score at the end wins."
})

function OnMinigameEnd()
{
	local lowest_score = Ware_GetBossThreshold() + 5
	local lowest_players = Ware_MinigameHighScorers
	lowest_players.clear()
	
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player
		
		if (data.score < lowest_score)
		{
			lowest_score = data.score
			lowest_players.clear()
			lowest_players.append(player)
		}
		else if (data.score == lowest_score)
		{
			lowest_players.append(player)
		}
	}
}