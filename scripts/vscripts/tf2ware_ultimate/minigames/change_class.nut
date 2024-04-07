
local mode = RandomInt(0, 8);
local desired_class;

minigame <- Ware_MinigameData();
minigame.name = "Change Class";
minigame.duration = 4.0;
minigame.music = "settingthescene";
minigame.suicide_on_end = true;
minigame.end_delay = 0.5;

switch (mode)
{
	case 0:
		minigame.description = "Change Class to Scout!";
		minigame.custom_overlay = "class_scout";
		desired_class = TF_CLASS_SCOUT;
		break;
	
	case 1:
		minigame.description = "Change Class to Soldier!";
		minigame.custom_overlay = "class_soldier";
		desired_class = TF_CLASS_SOLDIER;
		break;
	
	case 2:
		minigame.description = "Change Class to Pyro!";
		minigame.custom_overlay = "class_pyro";
		desired_class = TF_CLASS_PYRO;
		break;
	
	case 3:
		minigame.description = "Change Class to Demoman!";
		minigame.custom_overlay = "class_demoman";
		desired_class = TF_CLASS_DEMOMAN;
		break;
	
	case 4:
		minigame.description = "Change Class to Heavy!";
		minigame.custom_overlay = "class_heavy";
		desired_class = TF_CLASS_HEAVYWEAPONS;
		break;
	
	case 5:
		minigame.description = "Change Class to Engineer!";
		minigame.custom_overlay = "class_engineer";
		desired_class = TF_CLASS_ENGINEER;
		break;
	
	case 6:
		minigame.description = "Change Class to Medic!";
		minigame.custom_overlay = "class_medic";
		desired_class = TF_CLASS_MEDIC;
		break;
	
	case 7:
		minigame.description = "Change Class to Sniper!";
		minigame.custom_overlay = "class_sniper";
		desired_class = TF_CLASS_SNIPER;
		break;
	
	case 8:
		minigame.description = "Change Class to Spy!";
		minigame.custom_overlay = "class_spy";
		desired_class = TF_CLASS_SPY;
		break;
}

function OnStart()
{
	// set everyone to non-desired class
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (player.GetPlayerClass() != desired_class)
			continue;
		
		local start_class = RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST);
		// roll til we get a non-desired class
		while (start_class == desired_class)
			start_class = RandomInt(TF_CLASS_FIRST, TF_CLASS_LAST);
		
		Ware_SetPlayerClass(player, start_class);
	}
}

function OnGameEvent_player_changeclass(params)
{
	local player = GetPlayerFromUserID(params.userid);
	Ware_CreateTimer(@() player.ForceRespawn(), 1.0);
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.ForceRespawn()
		if (player.GetPlayerClass() == desired_class)
			Ware_PassPlayer(player, true);
	}
}
