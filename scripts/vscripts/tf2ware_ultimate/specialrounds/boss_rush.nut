
special_round <- Ware_SpecialRoundData
({
	name = "Boss Rush"
	author = "pokemonPasta"
	description = "Five bosses will be played back to back!"
	
	boss_threshold = 0
	boss_count = 5
})

started <- false

function OnBeginIntermission(is_boss)
{
	if (!started)
	{
		Ware_BeginBoss()
		started = true
		return true
	}
}