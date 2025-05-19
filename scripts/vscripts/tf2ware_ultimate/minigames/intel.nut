minigame <- Ware_MinigameData
({
	name           = "Intel"
	author         = "tilderain"
	description    = "Steal their stupid crap!"
	duration       = 15.0
	location       = "boxarena"
	music          = "purple"
	custom_overlay = "get_end"
})

hoops <- []

show_anno <- false

barrier <- null

beam_model <- "sprites/laser.vmt"
intel_pos <- null

function SpawnIntel()
{
	local hoop = Ware_SpawnEntity("item_teamflag",
	{
		origin         = Ware_MinigameScope.intel_pos
		TeamNum = 0
	})

	hoop.ValidateScriptScope()
	hoop.GetScriptScope().OnCapture1 <- Ware_MinigameScope.OnCapture1
	hoop.ConnectOutput("OnCapture1", "OnCapture1")
	hoop.GetScriptScope().OnPickup1 <- Ware_MinigameScope.OnPickup1
	hoop.ConnectOutput("OnPickup1", "OnPickup1")
}

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

function OnUpdate()
{
	foreach (mgr in TeamMgrs)
		SetPropInt(mgr, "m_nFlagCaptures", 0)
}

function OnCapture1()
{
	if (activator && activator.IsPlayer())
		Ware_PassPlayer(activator, true)
}

function OnPickup1()
{
	if(!Ware_MinigameScope.show_anno)
		Ware_ShowAnnotation(Ware_MinigameScope.goal_pos, "Goal!")
	Ware_MinigameScope.show_anno = true
	if (activator && activator.IsPlayer())
	{
		local minidata = Ware_GetPlayerMiniData(activator)
		if(!("picked" in minidata))
		{
			Ware_MinigameScope.SpawnIntel()
			//minidata.picked <- true
		}
	}
}

function OnStart()
{
	goal_pos <- Ware_MinigameLocation.center + Vector(0,-850,50)
	intel_pos = Ware_MinigameLocation.center + Vector(0,800,50)
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT)
	SetPropInt(GameRules, "m_nHudType", 1)

	SpawnIntel()

	barrier = Ware_CreateEntity("func_capturezone")
	barrier.SetOrigin(goal_pos)
	barrier.SetSolid(SOLID_BBOX)
	barrier.SetSize(Vector(-1000, -16, 0), Vector(1000, 16, 1000))
	barrier.KeyValueFromInt("TeamNum", 3)
	barrier.SetCollisionGroup(TFCOLLISION_GROUP_RESPAWNROOMS)
	local beam_height = 100.0 

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

}

function OnBeamTouch()
{
	//if (activator)
	//	activator.TakeDamageCustom(self, self, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_PLASMA)
}

function OnCleanup()
{
	SetPropInt(GameRules, "m_nHudType", 0)
}