
special_round <- Ware_SpecialRoundData
({
	name = "Adrenaline Shot"
	author = "pokemonPasta"
	description = "The round starts fast, then slows down."
})

function OnStart()
{
	local high_scale = (Ware_BossThreshold / Ware_SpeedUpThreshold) * Ware_SpeedUpInterval
	Ware_SetTimeScale(1.0 + high_scale)
}

function OnWare_Speedup()
{
	Ware_SetTimescale(Ware_Timescale - Ware_SpeedUpInterval)
}
