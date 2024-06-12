
special_round <- Ware_SpecialRoundData
({
	name = "All In"
	author = "pokemonPasta"
	description = "If you lose one microgame, you lose ALL your points."
})

function OnCalculateScores(data, player, highest_score, highest_players)
{

	if (data.passed)
	{
		data.score += Ware_Minigame.boss ? 5 : 1
		if (data.score > highest_score)
		{
			highest_score = data.score
			highest_players.clear()
			highest_players.append(player)
		}
		else if (data.score == highest_score)
		{
			highest_players.append(player)
		}
	}
	else
	{
		data.score = 0
		local idx = highest_players.find(player)
		if (idx != null)
			highest_players.remove(idx)
	}
	
	return highest_players
}