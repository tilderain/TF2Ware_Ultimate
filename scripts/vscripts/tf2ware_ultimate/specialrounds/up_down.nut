
special_round <- Ware_SpecialRoundData
({
	name = "Up and Down"
	author = "pokemonPasta"
	description = "The speed will change randomly throughout the round."
	category = "timescale"
})

function OnSpeedup()
{
	CreateTimer(@() Ware_BeginIntermission(false), 0.0)
	return true
}

function OnBeginIntermission(is_boss)
{
	Ware_SetTimeScale(RandomFloat(0.6, 2.0))
}
