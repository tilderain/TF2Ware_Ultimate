special_round <- Ware_SpecialRoundData
({
	name        = "Math Only"
	author      = ["Gemidyne", "ficool2"]
	description = "Only math questions this round!"
	category    = ""
})

function GetMinigameName(is_boss)
{
	return is_boss ? "typing" : "math"
}