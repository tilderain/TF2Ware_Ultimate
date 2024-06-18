
special_round <- Ware_SpecialRoundData
({
	name = "Slow-Mo"
	author = "pokemonPasta"
	description = "Everything slows down!"
	
	boss_threshold = 10
})

function OnSpeedup()
{
	CreateTimer(@() Ware_BeginIntermission(false), 0.0)
}

function OnMinigameEnd()
{
	Ware_SetTimeScale(Ware_GetTimeScale() - 0.05)
}

