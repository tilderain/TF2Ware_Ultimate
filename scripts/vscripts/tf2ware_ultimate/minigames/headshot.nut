minigame <- Ware_MinigameData
({
	name           = "Headshot a Player"
	author         = "ficool2"
	description    = "Headshot a player!"
	duration       = 4.5
	end_delay      = 0.5
	music          = "heat"
	custom_overlay = "headshot_player"
	min_players    = 2
	allow_damage   = true
})

player_class <- RandomBool() ? TF_CLASS_SNIPER : TF_CLASS_SPY

function OnStart()
{
	if (player_class == TF_CLASS_SNIPER)
		Ware_SetGlobalLoadout(player_class, "Machina")
	else if (player_class == TF_CLASS_SPY)
		Ware_SetGlobalLoadout(player_class, "Ambassador")
}

function OnTakeDamage(params)
{
	if (params.attacker != null && params.const_entity != params.attacker)
	{
		if (GetPropInt(params.const_entity, "m_LastHitGroup") == HITGROUP_HEAD)
		{
			params.damage = 1000.0
			params.damage_type = params.damage_type | DMG_CRIT
			params.damage_stats = TF_DMG_CUSTOM_HEADSHOT
		}
		else
		{
			return false
		}
	}
}

function OnPlayerDeath(player, attacker, params)
{
	if (attacker && player != attacker)
		Ware_PassPlayer(attacker, true)
}