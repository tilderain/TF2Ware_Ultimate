minigame <- Ware_MinigameData();
minigame.name = "Extinguish"
minigame.description = "Get Extinguished!";
minigame.description2 = "Extinguish a Scout!";
minigame.duration = 4.5;
minigame.end_delay = 0.5;
minigame.music = "fencing";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.start_pass = true;
minigame.fail_on_death = true;
minigame.custom_overlay = "extinguish_scout";
minigame.custom_overlay2 = "extinguish_pyro";
minigame.convars =
{
	mp_teams_unbalance_limit = 0,
}
function OnStart()
{
	local pyro_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
					
		if (player.GetTeam() == pyro_team)
		{
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_PYRO);
			Ware_GivePlayerWeapon(player, "Flame Thrower");
			Ware_SetPlayerTeam(player, pyro_team);
			Ware_PassPlayer(player, false);
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT);
			player.SetHealth(25);
			BurnPlayer(player, 10, minigame.duration);
			Ware_SetPlayerTeam(player, pyro_team);
		}
	}
}

function OnGameEvent_player_healonhit(params)
{
	local player = PlayerInstanceFromIndex(params.entindex);
	if (player)
		Ware_PassPlayer(player, true);
}
