minigame <- Ware_MinigameData
({
	name          = "Spycrab Limbo"
	author        = ["TonyBaretta", "pokemonPasta"]
	description   = "Limbo under the laser!"
	duration      = 11.0
	location      = "boxarena"
	music         = "limbo"
	thirdperson   = true
})

goal_vectors <- null

beam_model <- "sprites/laser.vmt"

function OnPrecache()
{
	PrecacheSprite(beam_model)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players, 
		Ware_MinigameLocation.center + Vector(0, -700, 0), 
		QAngle(0, 90, 0), 
		1600.0, 
		60.0, 120.0)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY)
	Ware_CreateTimer(@() Ware_SetGlobalLoadout(TF_CLASS_SPY, "Disguise Kit"), 0.1)
	
	Ware_ChatPrint(null, "{color}HINT:{color} Look up and crouch to limbo!", COLOR_GREEN, TF_COLOR_DEFAULT)
	
	local highest_scale = 1.0
	foreach(player in Ware_MinigamePlayers)
		if (player.GetModelScale() > highest_scale)
			highest_scale = player.GetModelScale()
	
	local beam_height = 100.0 * highest_scale
	local beam = Ware_CreateEntity("env_beam")
	beam.SetOrigin(Ware_MinigameLocation.center + Vector(-1000, 0, beam_height))
	SetPropVector(beam, "m_vecEndPos", Ware_MinigameLocation.center + Vector(1000, 0, beam_height))
	beam.SetModel(beam_model)
	beam.KeyValueFromString("rendercolor", "255 255 0")
	beam.KeyValueFromInt("renderamt", 100)
	beam.DispatchSpawn()
	SetPropFloat(beam, "m_fWidth", 7.0)
	SetPropFloat(beam, "m_fEndWidth", 7.0)
	EntityAcceptInput(beam, "TurnOn")
	
	local trigger = Ware_SpawnEntity("trigger_multiple",
	{
		classname = "cow_mangler", // kill icon
		origin = Ware_MinigameLocation.center + Vector(0, 0, beam_height),
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	trigger.SetSolid(SOLID_BBOX)
	trigger.SetSize(Vector(-1000, -8, -4), Vector(1000, 8, 4))
	trigger.ValidateScriptScope()
	trigger.GetScriptScope().OnStartTouch <- OnBeamTouch
	trigger.ConnectOutput("OnStartTouch", "OnStartTouch")
	
	goal_vectors = beam.GetOrigin()
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{		
		if (player.GetOrigin().y > goal_vectors.y + 30.0)
			Ware_PassPlayer(player, true)
		
		if ((player.GetFlags() & FL_DUCKING) && (player.EyeAngles().x < -70.0))
		{
			player.RemoveFlag(FL_ATCONTROLS)
			continue
		}
		
		player.AddFlag(FL_ATCONTROLS)
	}
}

function OnBeamTouch()
{
	if (activator)
		activator.TakeDamageCustom(self, self, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_PLASMA)
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
		player.RemoveFlag(FL_ATCONTROLS)
}
