minigame <- Ware_MinigameData();
minigame.name = "Sap a Building";
minigame.duration = 4.0;
minigame.music = "funkymoves";
minigame.min_players = 2;

minigame.description = "Sap a Building!";
minigame.description2 = "Get a Building Sapped!";

minigame.custom_overlay = "sap_spy";
minigame.custom_overlay2 = "sap_engi";

// allow damage so sappers work, but prevent player damage
minigame.allow_damage = true;
minigame.friendly_fire = false;

function OnStart()
{
	local engi_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
					
		if (player.GetTeam() == engi_team)
		{
			Ware_SetPlayerMission(player, 2);
			Ware_SetPlayerClass(player, TF_CLASS_ENGINEER);
			Ware_GivePlayerWeapon(player, "Toolbox");
			Ware_GivePlayerWeapon(player, "Construction PDA");
		}
		else
		{
			Ware_SetPlayerMission(player, 1);
			Ware_SetPlayerClass(player, TF_CLASS_SPY);
			Ware_GivePlayerWeapon(player, "Sapper");
		}
	}
}

function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
		return false;
}

function OnGameEvent_player_sapped_object(params)
{
	local spy = GetPlayerFromUserID(params.userid);
	local engi = GetPlayerFromUserID(params.ownerid);
	
	if (spy)
		Ware_PassPlayer(spy, true);
	
	if (engi)
		Ware_PassPlayer(engi, true);
}
