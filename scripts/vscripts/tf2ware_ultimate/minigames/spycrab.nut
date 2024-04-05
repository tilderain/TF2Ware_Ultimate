minigame <- Ware_MinigameData();
minigame.name = "Spycrab";
minigame.description = "Do the spycrab!"
minigame.duration = 3.5;
minigame.music = "sillytime";
minigame.end_delay = 0.5;

local sprite_model = "sprites/tf2ware_ultimate/spycrab.vmt"

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null);
	Ware_CreateTimer(@() Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit"), 1.0);
	
	Ware_SpawnEntity("env_sprite_oriented",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 2000),
		angles = QAngle(90, 0, 0),
		model = sprite_model,
		scale = 5,
		rendermode = kRenderTransColor,
		spawnflags = 1,		
	});
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if ((player.GetFlags() & FL_DUCKING) && (player.EyeAngles().x < -70.0))
		{
			Ware_PassPlayer(player, true);
		}
		else
		{
			Ware_ChatPrint(player, "{color}Spycrabs must look up and crouch!", TF_COLOR_DEFAULT);
			Ware_SuicidePlayer(player);
		}
		
		player.RemoveCond(TF_COND_DISGUISING);
		player.RemoveCond(TF_COND_DISGUISED);
	}
}