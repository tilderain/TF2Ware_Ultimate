overlay <- "debug/yuv"

special_round <- Ware_SpecialRoundData
({
	name = "Nostalgia"
	author = "ficool2"
	description = "Taking you back to the past!"
})

function GetOverlay2()
{
	return overlay
}

function OnStart()
{
	Ware_ShowGlobalScreenOverlay2(overlay)
	Ware_RunClientCommand(null, "dsp_player 59")
}

function OnMinigameStart()
{
	Ware_ShowGlobalScreenOverlay2(overlay)
}

function OnMinigameEnd()
{
	Ware_RunClientCommand(null, "dsp_player 59")
}

function OnEnd()
{
	Ware_RunClientCommand(null, "dsp_player 0")
}