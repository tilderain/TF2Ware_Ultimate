special_round <- Ware_SpecialRoundData
({
	name             = "Math Only"
	author           = "ficool2"
	description      = "Only math questions this round!"
})

function GetMinigameName(is_boss)
{
	return is_boss ? null : "math"
}