
special_round <- Ware_SpecialRoundData
({
	name = "All In"
	author = "pokemonPasta"
	description = "If you lose one microgame, you lose ALL your points."
})

function OnMinigameEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (!data.passed)
		{
			data.score = 0
			if (Ware_MinigameHighScorers.find(player))
				Ware_MinigameHighScorers.remove(Ware_MinigameHighScorers.find(player))
		}
	}
}