minigame <- Ware_MinigameData
({
	name           = "Backstab a Player"
	author		   = "ficool2"
	description    = "Backstab a player!"
	duration       = 4.5
	end_delay      = 0.5
	music          = "heat"
	min_players    = 2
	allow_damage   = true
	custom_overlay = "backstab_player"
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SPY)
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (attacker && victim != attacker)
	{
		if (params.damage_stats == TF_DMG_CUSTOM_BACKSTAB)
			Ware_PassPlayer(attacker, true)
	}
}

function OnPlayerDeath(params)
{
	local attacker = GetPlayerFromUserID(params.attacker)
	if (attacker == null)
		return
	local victim = GetPlayerFromUserID(params.userid)
	if (victim == attacker)
		return
	Ware_PassPlayer(attacker, true)
}