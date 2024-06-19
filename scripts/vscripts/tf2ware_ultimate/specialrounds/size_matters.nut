
max_scale <- 2.0

topscore_scale <- 1.1
scale_increase <- max_scale / Ware_BossThreshold

special_round <- Ware_SpecialRoundData
({
	name = "Size Matters"
	author = "pokemonPasta"
	description = "Your size will change to reflect your score!"
})

function OnCalculateTopScorers(top_players)
{
	topscore_scale += scale_increase
	
	// do everything as normal
	local top_score = 1
	foreach (data in Ware_MinigamePlayersData)
	{
		if (data.score > top_score)
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
	
	// also resize everyone
	foreach(data in Ware_PlayersData)
	{
		local player = data.player
		Ware_SetPlayerScale(player, RemapValClamped(data.score, 0.0, top_score, 0.5, topscore_scale), 0.5)
	}
}