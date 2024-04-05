local mode = RandomInt(0, 3);
local correct_building;

minigame <- Ware_MinigameData();
minigame.name = "Build This";
minigame.duration = 4.0;
minigame.music = "sillytime";
minigame.convars = 
{
	tf_cheapobjects = 1
};

if (mode == 0)
{
	minigame.description = "Build a Sentry"
	minigame.custom_overlay = "build_sentry";
	correct_building = OBJ_SENTRYGUN;
}

else if (mode == 1)
{
	minigame.description = "Build a Dispenser"
	minigame.custom_overlay = "build_dispenser";
	correct_building = OBJ_DISPENSER;
}
else if (mode == 2)
{
	minigame.description = "Build a Teleporter Entrance"
	minigame.custom_overlay = "build_tele_entrance";
	correct_building = OBJ_TELEPORTER;
}
else if (mode == 3)
{
	minigame.description = "Build a Teleporter Exit"
	minigame.custom_overlay = "build_tele_exit";
	correct_building = OBJ_TELEPORTER;
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_ENGINEER, ["Wrench", "Toolbox", "Construction PDA"]);
}

function OnGameEvent_player_builtobject(params)
{
	local building = EntIndexToHScript(params.index);
	if (!building)
		return;
		
	local building_enum = params.object;
	if(building_enum == correct_building)
	{
		if (
			(mode < 2) ||
			(mode == 2 && GetPropInt(building, "m_iObjectMode") != 1) || // tele entrance
			(mode == 3 && GetPropInt(building, "m_iObjectMode") == 1) // tele exit
		)
		{
		local player = GetPlayerFromUserID(params.userid);
		Ware_PassPlayer(player, true);
		}
	}
}
