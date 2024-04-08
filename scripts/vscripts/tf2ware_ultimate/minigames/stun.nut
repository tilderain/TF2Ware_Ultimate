
minigame <- Ware_MinigameData();
minigame.name = "Stun an Enemy";
minigame.duration = 4.0;
minigame.music = "bigjazzfinish";
minigame.description = "Stun an Enemy!";
minigame.allow_damage = true;
minigame.friendly_fire = true;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SCOUT, "Sandman");
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		Ware_SetPlayerAmmo(player, TF_AMMO_GRENADES1, 5);
	}
}

function OnUpdate()
{
	local id = ITEM_MAP.Sandman.id;
	local classname = ITEM_PROJECTILE_MAP[id];
	for (local proj; proj = FindByClassname(proj, classname);)
	{
		proj.SetTeam(TEAM_SPECTATOR);	
	}
}

function OnTakeDamage(params)
{
	params.damage = 0.0;
	local victim = params.const_entity;
	local attacker = params.attacker;
	
	if (!victim)
		return;
	
	if (params.damage_stats == TF_DMG_CUSTOM_BASEBALL)
	{
		StunPlayer(victim, TF_TRIGGER_STUN_LOSER, false, Ware_GetMinigameRemainingTime(), 0.6);
		
		local particle = Ware_SpawnEntity("info_particle_system",
			{
				origin = victim.GetOrigin(),
				effect_name = "conc_stars",
				start_active = true
			});
		SetEntityParent(particle, victim, "head");
		
		if (!attacker)
			return;
		
		Ware_PassPlayer(attacker, true);
	}
}

function OnEnd()
{
	foreach(data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_STUNNED);
	}
}
