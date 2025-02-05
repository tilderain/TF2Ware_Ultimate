minigame <- Ware_MinigameData
({
	name          = "Explosive Barrels"
	author		  = ["sasch", "ficool2", "tilderain"]
	description   = "Don't get exploded!"
	duration      = 6
	music         = "actfast"
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
	min_players    = 2
})


function OnPrecache()
{
	PrecacheModelGibs("models/tf2ware_ultimate/explosive_barrel.mdl")
}

function SpawnBarrel(playerOrigin)
{
	local barrelOrigin = playerOrigin + Vector(RandomFloat(-25.0, 25.0), 
											   RandomFloat(-25.0, 25.0),
											   250)
	local prop = Ware_SpawnEntity("prop_physics_multiplayer",
	{
		origin	 = barrelOrigin
		model	  = "models/tf2ware_ultimate/explosive_barrel.mdl"
		targetname = "explosive_barrel"
	})
	Ware_SlapEntity(prop, 40.0)
}

function OnStart()
{
	foreach (player in Ware_MinigamePlayers)
	{
		local origin = player.GetOrigin()
		SpawnBarrel(origin)
		SpawnBarrel(origin)
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	if (victim.IsPlayer())
	{
		if (params.damage_type & DMG_CLUB)
		{
			local attacker = params.attacker
			if (victim.IsPlayer() && attacker && attacker.IsPlayer())
			{
				victim.SetAbsVelocity(victim.GetAbsVelocity() + Vector(0, 0, 300))
				Ware_PushPlayerFromOther(victim, attacker, 250.0)
				return false
			}
		}
	}
	else if (victim.GetName() == "explosive_barrel")
	{
	//Barrels won't do non-self inflicted damage otherwise
		params.attacker = victim
	}
}