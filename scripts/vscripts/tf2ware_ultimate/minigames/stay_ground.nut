minigame <- Ware_MinigameData();
minigame.name = "Stay on the Ground";
minigame.description = "Stay on the ground!"
minigame.duration = 4.0;
minigame.music = "falling";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.convars = 
{
	sv_gravity = 50
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_SOLDIER, "Rocket Launcher");
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BLAST)
	{
		if (params.const_entity.IsPlayer())
		{
			Ware_SlapEntity(params.const_entity, 240.0);
			return false;
		}
	}
}

function OnPlayerAttack(player)
{
	Ware_PushPlayer(player, -400.0);
}

function OnUpdate()
{
	if (Ware_GetMinigameTime() < 2.0)
		return;

	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;			
		if (Ware_GetPlayerHeight(player) > 250.0)
			Ware_SuicidePlayer(player);
	}
}