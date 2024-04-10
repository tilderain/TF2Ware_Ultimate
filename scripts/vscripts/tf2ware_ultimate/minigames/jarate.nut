
minigame <- Ware_MinigameData();
minigame.name = "Jarate an Enemy";
minigame.duration = 4.0;
minigame.music = "rockingout";
minigame.description = "Jarate an Enemy!";

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Jarate");
}

function OnGameEvent_player_jarated(params)
{
	local player = EntIndexToHScript(params.thrower_entindex);
	Ware_PassPlayer(player, true);
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_URINE);
	}
}
