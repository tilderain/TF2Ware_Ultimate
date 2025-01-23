minigame <- Ware_MinigameData
({
	name           = "Saw Run"
	author         = ["Mecha the Slag", "Gemidyne", "ficool2"]
	description    = "Get to the end!"
	duration       = 4.0
	end_delay      = 0.5
	max_scale      = 1.5
	location       = RandomBool() ? "sawrun_micro" : "sawrun"
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
	local threshold = Ware_MinigameLocation.finish.y
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.IsAlive() && player.GetOrigin().y > threshold)
			Ware_PassPlayer(player, true)
	}
}