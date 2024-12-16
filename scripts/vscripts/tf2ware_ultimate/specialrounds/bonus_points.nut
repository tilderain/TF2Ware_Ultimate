
special_round <- Ware_SpecialRoundData
({
	name = "Bonus Points"
	author = "pokemonPasta"
	description = "Extra points will be awarded in some minigames!"
	
	bonus_points = true
})

function OnPick()
{
	return !Ware_BonusPoints
}

