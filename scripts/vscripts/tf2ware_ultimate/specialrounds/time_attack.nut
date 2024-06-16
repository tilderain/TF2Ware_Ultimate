special_round <- Ware_SpecialRoundData
({
	name = "Time Attack"
	author = "ficool2"
	description = "The round keeps speeding up after every minigame."
})
	
function OnMinigameEnd()
{
	Ware_SetTimeScale(Ware_GetTimeScale() + 0.05)
}