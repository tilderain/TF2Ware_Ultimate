
minigame <- Ware_MinigameData();
minigame.name = "Jarate an Enemy";
minigame.duration = 4.0;
minigame.music = "rockingout";
minigame.description = "Jarate an Enemy!";
minigame.allow_damage = true;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SNIPER, "Jarate");
	Ware_SetGlobalAttribute("applies snare effect", 0.0000001, Ware_GetMinigameTime());
}

function OnGameEvent_player_stunned(params)
{
	local player = GetPlayerFromUserID(params.stunner);
	Ware_PassPlayer(player, true);
}

function OnUpdate()
{
	local id = ITEM_MAP.Jarate.id;
	local classname = ITEM_PROJECTILE_MAP[id];
	for (local proj; proj = FindByClassname(proj, classname);)
	{
		proj.SetTeam(TEAM_SPECTATOR);	
	}
}

function OnTakeDamage(params)
{
	params.damage = 0.0;
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_URINE);
		player.RemoveCond(TF_COND_STUNNED);
	}
}
