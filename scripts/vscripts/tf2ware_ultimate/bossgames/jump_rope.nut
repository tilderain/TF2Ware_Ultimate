minigame <- Ware_MinigameData();
minigame.name = "Jump Rope"
minigame.description = "Jump the rope!"
minigame.duration = 69.0; // :3
minigame.end_delay = 1.0;
minigame.music = "jumprope";
minigame.location = "jumprope";
minigame.start_pass = true;
minigame.fail_on_death = true;

local jumprope_door;
local jumprope_mins, jumprope_maxs;

function OnStart()
{
	jumprope_door = FindByName(null, "jumprope_door");
	MarkForPurge(jumprope_door);
	SetPropFloat(jumprope_door, "m_flSpeed", 100.0);
	EntFireByHandle(jumprope_door, "Open", "", -1, null, null);
	
	Ware_CreateTimer(@() IncreaseRopeSpeed(), 5.0);
	Ware_CreateTimer(@() CheckPlayerZones(), 5.0);
	
	jumprope_mins = Ware_MinigameLocation.center + Vector(-225, -113, 0);
	jumprope_maxs = Ware_MinigameLocation.center + Vector(225, 113, 128);
}

function IncreaseRopeSpeed()
{
	local speed = GetPropFloat(jumprope_door, "m_flSpeed");
	SetPropFloat(jumprope_door, "m_flSpeed", speed + 25.0);
	SetPropInt(jumprope_door, "m_toggle_state", 1);
	EntFireByHandle(jumprope_door, "Open", "", -1, null, null);
	return 5.0;
}

function CheckPlayerZones()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		local origin = player.GetOrigin();
		local mins = player.GetPlayerMins();
		local maxs = player.GetPlayerMaxs();
		
		local health = player.GetHealth();
		local max_health = player.GetMaxHealth();
		local ratio = max_health / 125.0;
		
		if (player.GetPlayerClass() == TF_CLASS_MEDIC)
			ratio *= 1.25;
		
		if (IntersectBoxBox(origin + mins, origin + maxs, jumprope_mins, jumprope_maxs))
			HealPlayer(player, 10.0 * ratio);
		else
			HealPlayer(player, -10.0 * ratio);
	}
	
	return 1.0;
}


function OnEnd()
{
	EntFireByHandle(jumprope_door, "Close", "", -1, null, null);
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0;
}