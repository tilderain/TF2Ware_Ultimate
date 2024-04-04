minigame <- Ware_MinigameData();
minigame.name = "Swim Up";
minigame.description = "Swim Up!"
minigame.duration = 4.0;
minigame.music = "getmoving";
minigame.allow_damage = true;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Neon Annihilator");
	foreach (data in Ware_Players)
		data.player.AddCond(TF_COND_SWIMMING_CURSE);
}

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return;
	
	foreach (data in Ware_Players)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;
			
		if (Ware_GetPlayerHeight(player) > 250.0)
			Ware_PassPlayer(player, true);
	}
}

function OnTakeDamage(params)
{
	params.damage *= 3.0;
}

function OnEnd()
{
	foreach (data in Ware_Players)
	{
		data.player.RemoveCond(TF_COND_SWIMMING_CURSE);
		data.player.RemoveCond(TF_COND_URINE);
	}
}