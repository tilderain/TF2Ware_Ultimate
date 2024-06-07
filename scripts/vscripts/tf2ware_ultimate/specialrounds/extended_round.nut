
special_round <- Ware_SpecialRoundData
({
	name = "Extended Round"
	author = "pokemonPasta"
	description = "30 minigames will be played before the boss."
})

local normal_rounds

function OnStart()
{
	normal_rounds = Ware_BossThreshold
	Ware_BossThreshold <- 30
}

function OnEnd()
{
	Ware_BossThreshold <- normal_rounds
}
