minigame <- Ware_MinigameData
({
	name           = "Water War"
	author         = ["TonyBaretta", "ficool2"]
	description    = "Survive!"
	duration       = 11.5
	end_delay      = 0.5
	music          = "adventuretime"
	min_players    = 2
	max_scale      = 1.5
	allow_damage   = true
	collisions     = true
	custom_overlay = "kill_player"
	convars =
	{
		tf_avoidteammates = 0
	}
})

function OnTeleport(players)
{
	local radius = ((Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x) * 0.5) - 76.0
	local height = 1024.0
	if (players.len() >= 24)
	{
		// split into 2 circles
		local half1 = players.filter(@(i, player) i % 2 == 0)
		local half2 = players.filter(@(i, player) i % 2 != 0)
		Ware_TeleportPlayersCircle(half1, Ware_MinigameLocation.center + Vector(0, 0, height), radius)
		Ware_TeleportPlayersCircle(half2, Ware_MinigameLocation.center + Vector(0, 0, height + 256.0), radius)
	}
	else
	{
		Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, height), radius)
	}
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

function OnPlayerDeath(player, attacker, params)
{
	if (attacker && player != attacker)
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