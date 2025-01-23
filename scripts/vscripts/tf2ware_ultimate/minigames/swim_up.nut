minigame <- Ware_MinigameData
({
	name         = "Swim Up"
	author       = ["sasch", "ficool2"]
	description  = "Swim Up!"
	duration     = 4.0
	music        = "getmoving"
	allow_damage = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Neon Annihilator")
	foreach (player in Ware_MinigamePlayers)
		player.AddCond(TF_COND_SWIMMING_CURSE)
}

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return
	
	foreach (player in Ware_MinigamePlayers)
	{
		if (!player.IsAlive())
			continue
			
		if (Ware_GetPlayerHeight(player) > 384.0)
			Ware_PassPlayer(player, true)
	}
}

function OnTakeDamage(params)
{
	params.damage *= 3.0
}

function OnEnd()
{
	foreach (player in Ware_MinigamePlayers)
	{
		player.RemoveCond(TF_COND_SWIMMING_CURSE)
		player.RemoveCond(TF_COND_URINE)
	}
}