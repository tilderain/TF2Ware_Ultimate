threshold <- Ware_BossThreshold + 10

special_round <- Ware_SpecialRoundData
({
	name = "Extended Round"
	author = "pokemonPasta"
	description = format("%d minigames will be played before the boss.", threshold)
})

function GetBossThreshold()
{
	return threshold
}
