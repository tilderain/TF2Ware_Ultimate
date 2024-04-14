minigame <- Ware_MinigameData();
minigame.name = "Mandrill Escape";
minigame.description = "Escape the Mandrill Maze!";
minigame.duration = 82.0;
minigame.end_delay = 1.0;
minigame.location = "mandrill";
minigame.music = "mandrill";
minigame.start_pass = false;
minigame.no_collisions = true;
minigame.fail_on_death = true;

local banana_model = "models/tf2ware_ultimate/banana.mdl";
PrecacheModel(banana_model);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null);
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.SetCustomModel(banana_model);
		TogglePlayerWearables(player, false);
		player.AddCondEx(TF_COND_SPEED_BOOST, 6.2, null);
	}
	
	EntFire("mandrill_train", "SetSpeed", "150");
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.start.x - 13300.0;
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (IsEntityAlive(player) && player.GetOrigin().x < threshold)
			Ware_PassPlayer(player, true);
	}
}

function OnEnd()
{
	EntFire("mandrill_train", "TeleportToPathTrack", "camp_move1");
	EntFire("mandrill_train", "Stop", "150");
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;	
		player.SetCustomModel("");
		TogglePlayerWearables(player, true);	
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0;
}