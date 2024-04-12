minigame <- Ware_MinigameData();
minigame.name = "Saw Run";
minigame.description = "Get to the end!";
minigame.duration = 4.0;
minigame.location = "sawrun";
minigame.music = "getmoving";
minigame.start_pass = false;
minigame.no_collisions = true;
minigame.custom_overlay = "get_end";

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, null);
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.center.y + 844.0;
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (IsEntityAlive(player) && player.GetOrigin().y > threshold)
			Ware_PassPlayer(player, true);
	}
}