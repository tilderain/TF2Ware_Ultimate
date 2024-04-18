mode <- RandomInt(0, 1)
	
minigame <- Ware_MinigameData
({
	name           = "Stand Near"
	author         = "ficool2"
	description    = mode == 1 ? "Don't stand near anybody!" : "Stand near somebody!"
	duration       = 4.0
	end_delay      = 1.0
	music          = "spotlightsonyou"
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
	custom_overlay = mode == 1 ? "stand_away" : "stand_near"
})

function OnEnd()
{
	local threshold = 96.0
	
	local targets = []
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (!IsEntityAlive(player))
		{
			Ware_PassPlayer(player, false)
			continue
		}
		
		targets.append({player = data.player, origin = data.player.GetOrigin(), kill = true})
	}
	
	foreach (target1 in targets)
	{
		foreach (target2 in targets)
		{
			if (target1 == target2)
				continue
				
			local dist = (target1.origin - target2.origin).Length()
			if (dist < threshold)
			{
				if (mode == 1)
					Ware_SuicidePlayer(target1.player)
				else
					target1.kill = false
				break
			}
		}
	}
	
	if (mode == 0)
	{
		foreach (target in targets)
		{
			if (target.kill)
				Ware_SuicidePlayer(target.player)
		}
	}
}

function OnTakeDamage(params)
{
	if (params.damage_custom == TF_DMG_CUSTOM_SUICIDE)
		return
	
	params.damage = 10
	
	local victim = params.const_entity
	if (victim.IsPlayer() && params.attacker != null)
	{
		local dir = params.attacker.EyeAngles().Forward()
		dir.z = 128.0
		dir.Norm()
		
		victim.SetAbsVelocity(victim.GetAbsVelocity() + dir * 300.0)
	}
}