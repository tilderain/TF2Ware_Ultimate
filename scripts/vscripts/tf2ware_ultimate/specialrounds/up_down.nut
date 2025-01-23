
special_round <- Ware_SpecialRoundData
({
	name = "Up and Down"
	author =  ["Gemidyne", "pokemonPasta"]
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
	Ware_SetTimeScale(RandomFloat(0.5, 2.5))
}
