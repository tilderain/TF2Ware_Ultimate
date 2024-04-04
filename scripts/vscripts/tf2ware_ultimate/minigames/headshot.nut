local player_class = RandomInt(0, 1) ? TF_CLASS_SNIPER : TF_CLASS_SPY;
	
minigame <- Ware_MinigameData();
minigame.name = "Headshot a Player";
minigame.description = "Headshot a player!";
minigame.duration = 4.5;
minigame.music = "heat";
minigame.min_players = 2;
minigame.allow_damage = true;
minigame.end_delay = 0.5;
minigame.custom_overlay = "headshot_player"; 

function OnStart()
{
	if (player_class == TF_CLASS_SNIPER)
		Ware_SetGlobalLoadout(player_class, "Machina");
	else if (player_class == TF_CLASS_SPY)
		Ware_SetGlobalLoadout(player_class, "Ambassador");
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		return;

	if (params.attacker != null && params.const_entity != params.attacker)
	{
		if (GetPropInt(params.const_entity, "m_LastHitGroup") == HITGROUP_HEAD)
		{
			params.damage = 1000.0;
			params.damage_type = params.damage_type | DMG_CRIT;
			params.damage_stats = TF_DMG_CUSTOM_HEADSHOT;
		}
		else
		{
			return false;
		}
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