special_round <- Ware_SpecialRoundData
({
	name = "Time Attack"
	author = "ficool2"
	description = "The round keeps speeding up after every minigame."
})
	
function OnPostEndMinigameInternal()
{
	Ware_SetTimeScale(Ware_TimeScale + 0.05)
}