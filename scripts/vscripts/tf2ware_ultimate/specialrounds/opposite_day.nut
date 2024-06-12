
special_round <- Ware_SpecialRoundData
({
	name = "Opposite Day"
	author = "pokemonPasta"
	description = "Lowest score at the end wins."
})

function OnCalculateScores(data, player, highest_score, highest_players)
{
	local lowest_score = Ware_GetBossThreshold() + 5
	
	if (data.passed)
		data.score += Ware_Minigame.boss ? 5 : 1
	
	if (data.score < lowest_score)
	{
		lowest_score = data.score
		highest_players.clear()
		highest_players.append(player)
	}
	else if (data.score == lowest_score)
	{
		highest_players.append(player)
	}
	
	return highest_players
}