local mode_stand_away = RandomInt(0, 1) == 0;
	
minigame <- Ware_MinigameData();
minigame.name = "Stand Near";
minigame.description = mode_stand_away ? "Don't stand near anybody!" : "Stand near somebody!";
minigame.duration = 4.0;
minigame.music = "spotlightsonyou";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 1.0;
minigame.custom_overlay = mode_stand_away ? "stand_away" : "stand_near"; 

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, null);
}

function OnEnd()
{
	local threshold = 75.0;
	
	local targets = [];
	foreach (data in Ware_Players)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
		{
			Ware_PassPlayer(player, false);
			continue;
		}
		
		targets.append({player = data.player, origin = data.player.GetOrigin(), kill = true});
	}
	
	foreach (target1 in targets)
	{
		foreach (target2 in targets)
		{
			if (target1 == target2)
				continue;
				
			local dist = (target1.origin - target2.origin).Length();
			if (dist < threshold)
			{
				if (mode_stand_away)
					Ware_SuicidePlayer(target1.player);
				else
					target1.kill = false;
				break;
			}
		}
	}
	
	if (!mode_stand_away)
	{
		foreach (target in targets)
		{
			if (target.kill)
				Ware_SuicidePlayer(target.player);
		}
	}
}

function OnTakeDamage(params)
{
	if (params.damage_custom == TF_DMG_CUSTOM_SUICIDE)
		return;
	
	params.damage = 10;
	
	local victim = params.const_entity;
	if (victim.IsPlayer() && params.attacker != null)
	{
		local dir = params.attacker.EyeAngles().Forward();
		dir.z = 128.0;
		dir.Norm();
		
		victim.SetAbsVelocity(victim.GetAbsVelocity() + dir * 300.0);
	}
}