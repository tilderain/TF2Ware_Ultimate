overlay <- "shaders/tf2ware_ultimate/cocanium"
sky_name <- ""

special_round <- Ware_SpecialRoundData
({
	name = "Cocanium"
	author = "ficool2"
	description = "Woah.. I feel different..."
})

function GetOverlay2()
{
	return overlay
}

function OnStart()
{
	Ware_ShowGlobalScreenOverlay2(overlay)
	Ware_RunClientCommand(null, "dsp_player 47")
	sky_name = Convars.GetStr("sv_skyname")
	SetSkyboxTexture("sky_trainyard_01")
}

function OnMinigameStart()
{
	Ware_RunClientCommand(null, "dsp_player 47")
	Ware_ShowGlobalScreenOverlay2(overlay)
}

function OnEnd()
{
	Ware_RunClientCommand(null, "dsp_player 0")
	Ware_ShowGlobalScreenOverlay2(null)
	SetSkyboxTexture(sky_name)
}