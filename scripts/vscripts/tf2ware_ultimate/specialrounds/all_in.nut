
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
			local idx = Ware_MinigameHighScorers.find(player)
			if (idx != null)
				Ware_MinigameHighScorers.remove(idx)
		}
	}
}