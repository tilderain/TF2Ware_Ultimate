minigame <- Ware_MinigameData
({
	name           = "Survive MONOCULUS"
	author         = "ficool2"
	description    = "Survive!"
	duration       = 40.0
	end_delay      = 1.0
	music          = "monoculus"
	custom_overlay = "survive"
	start_pass     = true
	fail_on_death  = true
	convars        =
	{
		tf_flamethrower_burstammo = 0,
	}
})

monoculuses <- []
offset <- Vector(0, 0, 256)

function OnPrecache()
{
	PrecacheEntityFromTable({classname = "eyeball_boss"})
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower")
	
	foreach (player in Ware_MinigamePlayers)
		player.SetHealth(500)
	
	Ware_CreateTimer(@() SpawnMonoculus(), 0.1)
	Ware_CreateTimer(@() SpawnMonoculus(), 3.0)
}

function SpawnMonoculus()
{
	local monoculus = Ware_SpawnEntity("eyeball_boss",
	{
		origin = Ware_MinigameLocation.center + offset
		teamnum = 5,
	})
	offset.x += 128.0
	offset.z += 256.0
	monoculuses.append(monoculus)
}

function OnUpdate()
{
	monoculuses = monoculuses.filter(@(i, monoculus) monoculus.IsValid())
	
	// fix them getting stuck inside of each other
	foreach (monoculus in monoculuses)
	{
		foreach (other_monoculus in monoculuses)
		{
			if (monoculus == other_monoculus)
				continue
				
			if (VectorDistance(monoculus.GetOrigin(), other_monoculus.GetOrigin()) < 80.0)
			{
				monoculus.Teleport(
					true, Ware_MinigameLocation.center + Vector(0, 0, 256),
					false, QAngle(),
					true, Vector())
				break
			}
		}
	}
}

function OnEnd()
{
	foreach (monoculus in monoculuses)
	{
		if (monoculus.IsValid())
		{
			SendGlobalGameEvent("eyeball_boss_killed", {})
			monoculus.Kill()
		}
	}
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() == 0
}