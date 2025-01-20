
special_round <- Ware_SpecialRoundData
({
	name = "Opposite Day"
	author = "pokemonPasta"
	description = "Do the opposite of what the minigame tells you."
	category = "scores"
	opposite_win = true
})

function OnCalculateScore(data)
{
	if (!data.passed)
		data.score += Ware_Minigame.boss ? Ware_PointsBossgame : Ware_PointsMinigame
}