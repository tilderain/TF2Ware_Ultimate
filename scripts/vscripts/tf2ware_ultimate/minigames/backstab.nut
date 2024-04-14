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