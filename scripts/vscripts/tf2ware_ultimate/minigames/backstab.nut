local player_class = RandomInt(0, 1) ? TF_CLASS_SNIPER : TF_CLASS_SPY;
	
minigame <- Ware_MinigameData();
minigame.name = "Backstab a Player";
minigame.description = "Backstab a player!";
minigame.duration = 4.5;
minigame.music = "heat";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.end_delay = 0.5;
minigame.custom_overlay = "backstab_player"; 

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY, null);
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		return;

	local victim = params.const_entity;
	local attacker = params.attacker;
	if (attacker && victim != attacker)
	{
		// replicate backstabs for teammates
		if (attacker.GetTeam() == victim.GetTeam())
		{
			local to_target = victim.GetCenter() - attacker.GetCenter();
			to_target.z = 0.0;
			to_target.Norm();

			local attacker_fwd = attacker.EyeAngles().Forward();
			attacker_fwd.z = 0.0;
			attacker_fwd.Norm();

			local victim_fwd = victim.EyeAngles().Forward();
			victim_fwd.z = 0.0;
			victim_fwd.Norm();

			if (to_target.Dot(victim_fwd) > 0.0 
				&& to_target.Dot(attacker_fwd) > 0.5 
				&& victim_fwd.Dot(attacker_fwd) > -0.3)
			{
				local viewmodel = GetPropEntity(attacker, "m_hViewModel");
				if (viewmodel)
					viewmodel.ResetSequence(viewmodel.LookupSequence("ACT_MELEE_VM_SWINGHARD"));
					
				params.damage       = victim.GetHealth() * 2.0;
				params.damage_stats = TF_DMG_CUSTOM_BACKSTAB;
				params.damage_type  = params.damage_type | DMG_CRIT;
			}
		}
		
		if (params.damage_stats == TF_DMG_CUSTOM_BACKSTAB)
			Ware_PassPlayer(attacker, true);
	}
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker);
	if (attacker == null)
		return;
	local victim = GetPlayerFromUserID(params.userid);
	if (victim == attacker)
		return;
	Ware_PassPlayer(attacker, true);
}