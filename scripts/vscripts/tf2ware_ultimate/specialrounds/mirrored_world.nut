overlay <- "shaders/tf2ware_ultimate/mirror"

special_round <- Ware_SpecialRoundData
({
	name = "Mirrored World"
	author = "ficool2"
	description = "The world is mirrored!"
})

function OnPrecache()
{
	PrecacheOverlay(overlay)
}

function GetOverlay2()
{
	return overlay
}

function OnStart()
{
	Ware_ShowGlobalScreenOverlay2(overlay)
}

function OnMinigameStart()
{
	Ware_ShowGlobalScreenOverlay2(overlay)
}

function OnEnd()
{
	Ware_ShowGlobalScreenOverlay2(null)
}