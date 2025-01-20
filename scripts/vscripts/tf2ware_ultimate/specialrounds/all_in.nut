
special_round <- Ware_SpecialRoundData
({
	name = "All In"
	author = "pokemonPasta"
	description = "If you lose one microgame, you lose ALL your points."
	category = "scores"
})

function OnCalculateScore(data)
{
	if (data.passed)
		data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
	else
		data.score = 0
}