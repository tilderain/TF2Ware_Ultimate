minigame <- Ware_MinigameData();
minigame.name = "Obstacle Course";
minigame.description = "Get to the end!";
minigame.duration = 49.0;
minigame.end_delay = 1.0;
minigame.location = "obstaclecourse";
minigame.music = "steadynow";
minigame.start_pass = false;
minigame.custom_overlay = "get_end";
minigame.convars = 
{
	tf_avoidteammates = 0
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null);
	
	EntFire("obstaclecourse_door", "SetSpeed", "100", 2.0);
	EntFire("obstaclecourse_door", "Open", "", 2.0);
	
	EntFire("obstaclecourse_rotate", "Unlock");
	EntFire("obstaclecourse_rotate", "Open");
}

function OnUpdate()
{
	local threshold = Ware_MinigameLocation.center.y + 3950.0;
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (IsEntityAlive(player) && player.GetOrigin().y > threshold)
			Ware_PassPlayer(player, true);
	}
}

function OnEnd()
{
	EntFire("obstaclecourse_door", "SetSpeed", "2000");
	EntFire("obstaclecourse_door", "Close");
	
	EntFire("obstaclecourse_rotate", "Close");
	EntFire("obstaclecourse_rotate", "Lock");
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0;
}