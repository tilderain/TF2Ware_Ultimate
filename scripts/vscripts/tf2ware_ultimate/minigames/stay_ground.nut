minigame <- Ware_MinigameData
({
	name          = "Stay on the Ground"
	author        = "ficool2"
	description   = "Stay on the ground!"
	duration      = 4.0
	music         = "falling"
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
})

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Rocket Launcher")
	Ware_SetGlobalCondition(TF_COND_CRITBOOSTED)
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BLAST)
	{
		if (params.const_entity.IsPlayer())
		{
			Ware_SlapEntity(params.const_entity, 300.0)
			params.damage = 20
		}
	}
}

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return

	foreach (player in Ware_MinigamePlayers)
	{
		if (!player.IsAlive())
			continue
		if (Ware_GetPlayerHeight(player) > 250.0)
			Ware_SuicidePlayer(player)
	}
}