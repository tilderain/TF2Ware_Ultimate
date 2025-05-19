minigame <- Ware_MinigameData
({
	name           = "Intel"
	author         = "tilderain"
	description    = "Capture the Intel!"
	duration       = 15.0
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

laser_count <- 0

lasers <- []

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
xRange <- [-750, 750]
zRange <- [0, 200]

function OnUpdate() 
{
    local minigameLocation = Ware_MinigameLocation.center_bottom
    local margin = 0.1

    foreach (prop in lasers) 
	{
        local vel = prop.GetAbsVelocity()
        local pos = prop.GetOrigin()

        if (pos.x - minigameLocation.x > xRange[1]) 
		{
            vel.x = -abs(vel.x)
        }
		else if (pos.x - minigameLocation.x < xRange[0]) 
		{
            vel.x = abs(vel.x)
        }

        if (pos.z - minigameLocation.z > zRange[1]) 
		{
            vel.z = -abs(vel.z)
        }
		else if (pos.z - minigameLocation.z < zRange[0]) 
		{
            vel.z = abs(vel.z)
        }

        prop.SetAbsVelocity(vel)
    }
}

function OnCapture1()
{
	if (activator && activator.IsPlayer())
		Ware_PassPlayer(activator, true)
	foreach (mgr in TeamMgrs)
		SetPropInt(mgr, "m_nFlagCaptures", 0)
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

	//spinner = 0
	local order = [0,1,1]
	local poses = [400, 0, -400]
	Shuffle(order)
	Shuffle(poses)

	for (local i = 0; i < order.len(); i++)
	{
		if(i == 0)
		{
			SpawnSpinner(Ware_MinigameLocation.center_bottom + Vector(poses[i], 300, 100))
			SpawnSpinner(Ware_MinigameLocation.center_bottom + Vector(poses[i], -100, 100))
		}
		else
		{
			SpawnLaser(Ware_MinigameLocation.center_bottom + Vector(poses[i], -265, RandomBool() ? 40 : 80))
		}
	}


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

function SpawnLaser(pos)
{
	local beam_height = 100.0
	

	local beam = Ware_SpawnEntity("func_tracktrain",
	{
		targetname = "test" + laser_count
		origin = pos + Vector(0, 3000, 0)
	})
	beam.SetMoveType(MOVETYPE_NOCLIP, 0)

	local speed = RandomFloat(-50, 50)
	Ware_SlapEntity(beam, speed)

	local vel = beam.GetAbsVelocity()
	vel = Vector(vel.x * 1, vel.y * 0, vel.z * 1)
	beam.SetAbsVelocity(vel)

	lasers.append(beam)

	local beam = Ware_SpawnEntity("env_laser",
	{
		origin = pos
		texture = "sprites/laserbeam.spr"
		TextureScroll = 35
		width = 4
		spawnflags = 48
		rendercolor = "255 0 25"
		damage = 3000
		dissolvetype = 1
		LaserTarget = "test" + laser_count
	})
	laser_count += 1
	speed = RandomFloat(-100, 50)
	beam.SetMoveType(MOVETYPE_NOCLIP, 0)
	Ware_SlapEntity(beam, speed)
	
	vel = beam.GetAbsVelocity()
	vel = Vector(vel.x * 1, vel.y * 0, vel.z * 1)
	beam.SetAbsVelocity(vel)

	lasers.append(beam)

}
function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		local inflictor = params.inflictor
		if (inflictor && inflictor.GetClassname() == "env_laser")
		{
			victim.TakeDamageCustom(victim, victim, null, Vector(), Vector(), 1000.0, DMG_GENERIC, TF_DMG_CUSTOM_PLASMA)
			// fix weapons being dissolved after respawn
			params.damage_type = params.damage_type & ~(DMG_DISSOLVE)	
			params.damage_stats = TF_DMG_CUSTOM_PLASMA
			params.damage *= 2.0
		}
	}
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