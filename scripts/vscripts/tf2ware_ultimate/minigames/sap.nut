
minigame <- Ware_MinigameData();
minigame.name = "Sap a Building";
minigame.duration = 4.0;
minigame.music = "funkymoves";
minigame.min_players = 2;
minigame.convars = 
{
	tf_cheapobjects = 1
};

minigame.description = "Sap a Building!";
minigame.description2 = "Get a Building Sapped!";

minigame.custom_overlay = "sap_spy";
minigame.custom_overlay2 = "sap_engi";

// allow damage so sappers work, but prevent player damage
minigame.allow_damage = true
function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
		return false;
}

local engi_team;

function OnStart()
{
	engi_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE);
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
					
		if (data.team == engi_team)
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

function OnGameEvent_player_builtobject(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (!player || player.GetPlayerClass() == TF_CLASS_SPY)
		return;
	
	Ware_StripPlayerWeapons(player, ["tf_weapon_builder", "tf_weapon_pda_engineer_build"]);
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
