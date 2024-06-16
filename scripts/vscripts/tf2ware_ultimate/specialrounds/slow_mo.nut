
special_round <- Ware_SpecialRoundData
({
	name = "Slow-Mo"
	author = "pokemonPasta"
	description = "Everything slows down!"
})

function OnSpeedup()
{
	CreateTimer(@() Ware_BeginIntermission(false), 0.0)
}

function OnMinigameEnd()
{
	Ware_SetTimeScale(Ware_GetTimeScale() - 0.05)
}

function GetBossThreshold()
{
	return 10
}
