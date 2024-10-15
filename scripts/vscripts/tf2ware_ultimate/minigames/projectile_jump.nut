mode_infos <- 
[
	[ "Needle jump!",       "needle_jump"       ],
	[ "Rocket jump!",       "rocket_jump"       ],
	[ "Sticky jump!",       "sticky_jump"       ],
	[ "Sentry jump!",       "sentry_jump"       ],
	[ "Flare jump!",        "flare_jump"        ],
	[ "Short Circuit jump!", "shortcircuit_jump" ],
]

mode <- RandomInt(0, 5)

minigame <- Ware_MinigameData
({
	name           = "Projectile Jump"
	author         = "ficool2"
	description    = mode_infos[mode][0]
	duration       = mode == 3 ? 5.0 : 4.0
	end_delay      = mode == 3 ? 0.0 : 1.0
	music          = "goodtimes"
	custom_overlay = mode_infos[mode][1]
	convars        = 
	{
		tf_damageforcescale_self_soldier_badrj = 10
		tf_damageforcescale_self_soldier_rj    = 20
		tf_damageforcescale_pyro_jump          = 20
		tf_fastbuild                           = 1
	}
})

function OnPrecache()
{
	foreach (mode in mode_infos)
		PrecacheOverlay("hud/tf2ware_ultimate/minigames/" + mode[1])
}

function OnStart()
{
	local player_class, weapon
	if (mode == 0)
	{
		player_class = TF_CLASS_MEDIC
		weapon = "Syringe Gun"
	}
	else if (mode == 1)
	{
		player_class = TF_CLASS_SOLDIER
		weapon = "Rocket Launcher"
	}
	else if (mode == 2)
	{
		player_class = TF_CLASS_DEMOMAN
		weapon = "Stickybomb Launcher"
	}
	else if (mode == 3)
	{
		player_class = TF_CLASS_ENGINEER
		weapon = [ "Construction PDA", "Wrangler", "Toolbox"]
		Ware_SetGlobalAttribute("build rate bonus", 0, -1)
	}
	else if (mode == 4)
	{
		player_class = TF_CLASS_PYRO
		weapon = "Detonator"
	}
	else if (mode == 5)
	{
		player_class = TF_CLASS_ENGINEER
		weapon = "Short Circuit"
		orbs <- {}
	}
	
	Ware_SetGlobalLoadout(player_class, weapon)
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (!player.IsAlive())
			continue
		if (Ware_GetPlayerHeight(player) > 512.0)
			Ware_PassPlayer(player, true)
	}
	
	if (mode == 5)
	{
		local dead_orbs = {}
		foreach (orb, data in orbs)
		{
			if (orb.IsValid())
				data.origin = orb.GetOrigin()
			else
				dead_orbs[orb] <- data
		}
		
		for (local orb; orb = Entities.FindByClassname(orb, "tf_projectile_mechanicalarmorb");)
		{
			if (!(orb in orbs) && !orb.IsEFlagSet(EFL_KILLME))
			{
				orbs[orb] <- { origin = orb.GetOrigin(), owner = orb.GetOwner() }
			}
		}
		
		foreach (orb, data in dead_orbs)
		{
			delete orbs[orb]
			
			local player = data.owner
			local origin = data.origin
			
			local radius = 100.0
			
			// copied from Ware_RadiusDamagePlayers
			local dist = VectorDistance(player.GetOrigin(), origin)
			if (dist > radius)
				continue
			
			dist += DIST_EPSILON
			local falloff = 1.0 - dist / radius
			if (falloff <= 0.0)
				continue
			
			local dir = player.EyeAngles().Forward()
			dir.Norm()
			
			local dot = dir.Dot(Vector(0, 0, -1.0))
			if (dot > 0.707) // cos(45)
				player.SetAbsVelocity(player.GetAbsVelocity() - dir * 2000.0 * dot * falloff)
		}
	}
}

if (mode == 0)
{
	function OnPlayerAttack(player)
	{
		local dir = player.EyeAngles().Forward()
		dir.Norm()
		
		local dot = dir.Dot(Vector(0, 0, -1.0))
		if (dot > 0.707) // cos(45)
			player.SetAbsVelocity(player.GetAbsVelocity() - dir * 80.0 * dot)
	}
}
else if (mode == 3)
{
	function OnGameEvent_player_builtobject(params)
	{
		local building = EntIndexToHScript(params.index)
		if (!building)
			return
			
		SetPropInt(building, "m_nDefaultUpgradeLevel", 2)
	}	
}
else if (mode == 5)
{
	function OnTakeDamage(params)
	{
		local weapon = params.weapon
		if (weapon && weapon.GetName() == "tf_weapon_mechanical_arm")
			params.damage = 0.0
	}
}