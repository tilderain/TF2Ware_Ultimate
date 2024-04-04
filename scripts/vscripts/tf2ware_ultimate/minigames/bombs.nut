minigame <- Ware_MinigameData();
minigame.name = "Bombs Away";
minigame.description = "Survive the bombs!"
minigame.duration = 4.0;
minigame.music = "ohno";
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower");
	Ware_RunFunction("SpawnBombs", 0.1);
	Ware_RunFunction("SpawnBombs", 0.2);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
		Ware_DisablePlayerPrimaryFire(data.player);
}

function SpawnBombs()
{
	local mins = Ware_MinigameLocation.mins;
	local maxs = Ware_MinigameLocation.maxs;
	
	foreach (data in Ware_MinigamePlayers)
	{
		local pipe = Ware_CreateEntity("tf_projectile_pipe");
		
		SetPropFloat(pipe, "m_flDamage", 250.0);
		SetPropInt(pipe, "m_iTeamNum", TEAM_SPECTATOR);
		SetPropFloat(pipe, "m_flModelScale", 1.1);
		
		local origin = data.player.GetOrigin();
		origin += Vector(RandomFloat(-150, 150), RandomFloat(-150, 150), RandomFloat(350, 450)); 
		if (origin.x < mins.x)
			origin.x = mins.x;
		if (origin.y < mins.y)
			origin.y = mins.y;
		if (origin.x > maxs.x)
			origin.x = maxs.x;
		if (origin.y > maxs.y)
			origin.y = maxs.y;		
		pipe.SetAbsOrigin(origin);
		
		Ware_SlapEntity(pipe, 160.0);
		
		pipe.DispatchSpawn();
	}
}