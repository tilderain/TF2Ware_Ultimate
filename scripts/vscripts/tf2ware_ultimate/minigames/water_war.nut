minigame <- Ware_MinigameData
({
	name           = "Water War"
	author         = "ficool2"
	description    = "Survive!"
	duration       = 11.5
	end_delay      = 0.5
	music          = "adventuretime"
	min_players    = 2
	allow_damage   = true
	collisions     = true
	custom_overlay = "kill_player"
	convars =
	{
		tf_avoidteammates = 0
	}
	
	max_scale = 1.5
})

function OnTeleport(players)
{
	local radius = ((Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x) * 0.5) - 76.0
	Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, 1024), radius)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Neon Annihilator")
	foreach (player in Ware_MinigamePlayers)
		player.AddCond(TF_COND_SWIMMING_CURSE)
}

function OnTakeDamage(params)
{
	params.damage = 950.0
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

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveCond(TF_COND_SWIMMING_CURSE)
		player.RemoveCond(TF_COND_URINE)
	}
}

function OnCheckEnd()
{
	return Ware_GetAlivePlayers().len() <= 1
}