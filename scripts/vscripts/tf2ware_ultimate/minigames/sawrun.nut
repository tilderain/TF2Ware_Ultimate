minigame <- Ware_MinigameData
({
	name           = "Saw Run"
	author         = "ficool2"
	description    = "Get to the end!"
	duration       = 4.0
	location       = "sawrun"
	music          = "getmoving"
	custom_overlay = "get_end"
	start_pass     = false
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT)
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.center.y + 844.0
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.IsAlive() && player.GetOrigin().y > threshold)
			Ware_PassPlayer(player, true)
	}
}