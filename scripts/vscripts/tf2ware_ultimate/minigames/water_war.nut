minigame <- Ware_MinigameData();
minigame.name = "Water War";
minigame.description = "Survive!"
minigame.duration = 4.0;
minigame.music = "adventuretime";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.custom_overlay = "survive";
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

function OnTeleport()
{
	local radius = ((Ware_MinigameLocation.maxs.x - Ware_MinigameLocation.mins.x) * 0.5) - 76.0;
	Ware_TeleportPlayersCircle(Ware_MinigameLocation.center + Vector(0, 0, 1024), radius);
}

function OnTakeDamage(params)
{
	params.damage = 950.0;
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		data.player.RemoveCond(TF_COND_SWIMMING_CURSE);
		data.player.RemoveCond(TF_COND_URINE);
	}
}