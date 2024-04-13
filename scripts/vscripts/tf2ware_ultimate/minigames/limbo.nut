
minigame <- Ware_MinigameData();
minigame.name = "Spycrab Limbo";
minigame.description = "Limbo under the laser!"
minigame.duration = 11.0;
minigame.location = "boxarena";
minigame.music = "limbo";
minigame.no_collisions = true;

local beam_model = "sprites/laser.vmt";
PrecacheModel(beam_model);
local goal_vectors;


function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players, 
		Ware_MinigameLocation.center + Vector(0, -600, 0), 
		QAngle(0, 90, 0), 
		1600.0, 
		128.0, 128.0);
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null);
	Ware_CreateTimer(@() Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit"), 0.1);
	
	local beam = Ware_CreateEntity("env_beam");
	beam.SetOrigin(Ware_MinigameLocation.center + Vector(-1000, 0, 96));
	SetPropVector(beam, "m_vecEndPos", Ware_MinigameLocation.center + Vector(1000, 0, 96));
	beam.SetModel(beam_model);
	beam.KeyValueFromString("rendercolor", "255 255 0");
	beam.KeyValueFromInt("renderamt", 100);
	beam.DispatchSpawn();
	SetPropFloat(beam, "m_fWidth", 7.0);
	SetPropFloat(beam, "m_fEndWidth", 7.0);
	EntFireByHandle(beam, "TurnOn", "", -1, null, null);
	
	goal_vectors = beam.GetOrigin();
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		
		if (player.GetOrigin().y > goal_vectors.y)
			Ware_PassPlayer(player, true);
		
		if ((player.GetFlags() & FL_DUCKING) && (player.EyeAngles().x < -70.0))
		{
			player.RemoveFlag(FL_ATCONTROLS);
			continue;
		}
		
		player.AddFlag(FL_ATCONTROLS);
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveFlag(FL_ATCONTROLS);
	}
}
