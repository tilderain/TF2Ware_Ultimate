
special_round <- Ware_SpecialRoundData
({
	name = "Opposite Day"
	author = "pokemonPasta"
	description = "Lowest score at the end wins."
	opposite_win = true
})

function OnCalculateTopScorers(top_players)
{
	local top_score = INT_MAX
	foreach (data in Ware_MinigamePlayersData)
	{
		if (data.score < top_score)
		{
			top_score = data.score
			top_players.clear()
			top_players.append(data.player)
		}
		else if (data.score == top_score)
		{
			top_players.append(data.player)
		}	
	}	
}