minigame <- Ware_MinigameData();
minigame.name = "Water War";
minigame.description = "Survive!"
minigame.duration = 12.0;
minigame.music = "adventuretime";
minigame.allow_damage = true;
minigame.custom_overlay = "kill_player";
minigame.convars =
{
	tf_avoidteammates = 0
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Neon Annihilator");
	foreach (data in Ware_MinigamePlayers)
		data.player.AddCond(TF_COND_SWIMMING_CURSE);
}

function OnTeleport(players)
{
	local radius = ((Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x) * 0.5) - 76.0;
	Ware_TeleportPlayersCircle(players, Ware_MinigameLocation.center + Vector(0, 0, 1024), radius);
}

function OnTakeDamage(params)
{
	params.damage = 950.0;
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

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		data.player.RemoveCond(TF_COND_SWIMMING_CURSE);
		data.player.RemoveCond(TF_COND_URINE);
	}
}