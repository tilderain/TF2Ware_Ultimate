minigame <- Ware_MinigameData
({
	name           = "Intel"
	author         = "tilderain"
	description    = "Capture the Intel!"
	duration       = 13.0
	end_delay	   = 0.5
	location       = "pinball"
	music          = "purple"
})

show_anno <- false

spinner_model <- "models/empty.mdl"
beam_model <- "sprites/laser.vmt"
fence_model <- "models/props_gameplay/security_fence_section01.mdl"
screen_model <- "models/props_spytech/computer_screen_01.mdl"

intel_pos <- null
goal_pos <- null

beam <- null
beam_hurt <- null

function OnPrecache()
{
	PrecacheModel(spinner_model)
	PrecacheSprite(beam_model)
	PrecacheModel(fence_model)
	PrecacheModel(screen_model)
}

function OnTeleport(players)
{
	Ware_TeleportPlayersRow(players, 
		Ware_MinigameLocation.center_bottom + Vector(-1100, 110, 0), 
		QAngle(0, 0, 0), 
		700.0, 
		30.0, 45.0)
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
	if (!Ware_MinigameScope.show_anno)
	{
		Ware_MinigameScope.show_anno = true	
		Ware_ShowAnnotation(Ware_MinigameScope.goal_pos, "Goal!")
	}
	
	if (activator && activator.IsPlayer())
	{
		local minidata = Ware_GetPlayerMiniData(activator)
		if (!("picked" in minidata))
		{
			Ware_MinigameScope.SpawnIntel()
			minidata.picked <- true
		}
	}
}

function OnStart()
{
	goal_pos = Ware_MinigameLocation.center_bottom + Vector(-1210, 100, 0)
	intel_pos = Ware_MinigameLocation.center_bottom + Vector(900, 100, 45)
	
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT)
	SetPropInt(GameRules, "m_nHudType", 1)

	SpawnIntel()
	
	SpawnSpinner(Ware_MinigameLocation.center_bottom + Vector(0, 300, 100))
	SpawnSpinner(Ware_MinigameLocation.center_bottom + Vector(0, -100, 100))

	local zone = Ware_SpawnEntity("func_capturezone",
	{
		origin = goal_pos
	})
	zone.SetSolid(SOLID_BBOX)
	zone.SetSize(Vector(-16, -400, 0), Vector(16, 400, 64))
	
	local screen = Ware_SpawnEntity("prop_dynamic",
	{
		origin = goal_pos + Vector(-100, 0, 32)
		angles = QAngle(0, -90, 0)
		model  = screen_model
	})
	screen.SetModelScale(3, 0)

	for (local i = -2; i <= 2; i++)
	{
		Ware_SpawnEntity("prop_dynamic",
		{
			origin = Ware_MinigameLocation.center_bottom + Vector(i * 256.0, -290.0, 0)
			model  = fence_model
			solid  = SOLID_VPHYSICS
		})	
	}
}

function SpawnIntel()
{
	local flag = Ware_SpawnEntity("item_teamflag",
	{
		origin  = Ware_MinigameScope.intel_pos
		TeamNum = TEAM_UNASSIGNED
	})

	flag.ValidateScriptScope()
	flag.GetScriptScope().OnCapture1 <- Ware_MinigameScope.OnCapture1
	flag.ConnectOutput("OnCapture1", "OnCapture1")
	flag.GetScriptScope().OnPickup1 <- Ware_MinigameScope.OnPickup1
	flag.ConnectOutput("OnPickup1", "OnPickup1")
}

function SpawnSpinner(pos)
{
	local spin = RandomBool() ? -70.0 : 70.0
	local spinner = Ware_SpawnEntity("prop_dynamic",
	{
		origin = pos
		model  = spinner_model
	})
	spinner.SetMoveType(MOVETYPE_NOCLIP, 0)
	spinner.SetAngularVelocity(0, 0, spin)
	
	local hurt_size = 2.0
	local hurt_width = 300.0
	
	local hurt = Ware_SpawnEntity("trigger_multiple",
	{
		origin     = pos
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	hurt.SetSolid(SOLID_OBB)
	hurt.SetSize(Vector(-hurt_size, -hurt_width, -hurt_size), Vector(hurt_size, hurt_width, hurt_size))
	EntityOutputs.AddOutput(hurt, "OnStartTouch", "!activator", "CallScriptFunction", "TriggerHurtDisintegrate", 0.0, -1)
	SetEntityParent(hurt, spinner)
	
	hurt = Ware_SpawnEntity("trigger_multiple",
	{
		origin     = pos
		spawnflags = SF_TRIGGER_ALLOW_CLIENTS
	})
	hurt.SetSolid(SOLID_OBB)
	hurt.SetSize(Vector(-hurt_size, -hurt_size, -hurt_width), Vector(hurt_size, hurt_size, hurt_width))
	EntityOutputs.AddOutput(hurt, "OnStartTouch", "!activator", "CallScriptFunction", "TriggerHurtDisintegrate", 0.0, -1)
	SetEntityParent(hurt, spinner)
	
	for (local i = -5; i <= 5; i++)
	{
		local offset = i * 45.0
		
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin       = pos + Vector(0, offset)
			effect_name  = "buildingdamage_dispenser_fire1"
			start_active = true
		})
		SetEntityParent(particle, spinner)
		
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin       = pos + Vector(0, 0. offset)
			effect_name  = "buildingdamage_dispenser_fire1"
			start_active = true
		})
		SetEntityParent(particle, spinner)		
	}
}

function OnCleanup()
{
	SetPropInt(GameRules, "m_nHudType", 0)
	
	foreach (player in Ware_Players)
	{
		player.RemoveCond(TF_COND_CRITBOOSTED)
		SetPropBool(player, "m_bGlowEnabled", false)
	}
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}