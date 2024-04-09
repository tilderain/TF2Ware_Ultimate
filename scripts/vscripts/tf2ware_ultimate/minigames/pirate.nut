minigame <- Ware_MinigameData();
minigame.name = "Pirate Attack";
minigame.description = "Jump over the RED ship!"
minigame.description2 = "Jump over the BLUE ship!"
minigame.duration = 12.0;
minigame.music = "piper";
minigame.location = "beach";
minigame.no_collisions  = true;
minigame.custom_overlay = "pirate_red";
minigame.custom_overlay2 = "pirate_blue";
 
local ship_model = "models/marioragdoll/super mario galaxy/bj ship/bjship.mdl";
PrecacheModel(ship_model);

local red_ship;
local blue_ship;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_DEMOMAN, "Stickybomb Jumper");
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local team = player.GetTeam();
		if (team == TF_TEAM_RED)
			Ware_SetPlayerMission(player, 1);
		else if (team == TF_TEAM_BLUE)
			Ware_SetPlayerMission(player, 2);	
	}
	
	red_ship = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin = Ware_MinigameLocation.center + Vector(2200, 300, -136),
		model = ship_model
		rendercolor = "255 0 0",
	});
	blue_ship = Ware_SpawnEntity("prop_dynamic_override",
	{
		origin = Ware_MinigameLocation.center + Vector(2200, -500, -136),
		model = ship_model
		rendercolor = "0 255 255",
	});
}

function OnUpdate()
{
	local offset = Vector(0, 0, 0);
	local red_point = red_ship.GetOrigin() + offset;
	local blue_point = blue_ship.GetOrigin() + offset;
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;
		
		if (player.GetFlags() & FL_INWATER)
		{
			player.Teleport(true, Ware_MinigameLocation.center, true, QAngle(), true, Vector());
			continue;
		}
		
		local origin = player.GetOrigin();
		local team = player.GetTeam();
		if (team == TF_TEAM_RED)
		{
			if ((origin - red_point).Length2D() < 150.0)
			{
				Ware_ShowScreenOverlay(player, null);
				Ware_CreateTimer(@() Ware_PassPlayer(player, true), 0.1);
				player.Teleport(true, Ware_MinigameLocation.center, true, QAngle(), true, Vector());
			}
		}
		else if (team == TF_TEAM_BLUE)
		{
			if ((origin - blue_point).Length2D() < 150.0)
			{
				Ware_ShowScreenOverlay(player, null);	
				Ware_CreateTimer(@() Ware_PassPlayer(player, true), 0.1);
				player.Teleport(true, Ware_MinigameLocation.center, true, QAngle(), true, Vector());
			}			
		}
	}
}