mode <- RandomInt(0, 1)
fov <- mode == 0 ? 120 : 50

special_round <- Ware_SpecialRoundData
({
	name             = mode == 0 ? "Quake Pro" : "Tunnel Vision"
	author           = "ficool2"
	description      = mode == 0 ? "FOV increased to 120!" : "FOV decreased to 50!"
})

function OnStart()
{
	foreach (player in Ware_Players)
		SetPropInt(player, "m_iFOV", fov)
}

function OnMinigameEnd()
{
	foreach (player in Ware_Players)
		SetPropInt(player, "m_iFOV", fov)	
}

function OnEnd()
{
	foreach (player in Ware_Players)
		SetPropInt(player, "m_iFOV", 0)
}