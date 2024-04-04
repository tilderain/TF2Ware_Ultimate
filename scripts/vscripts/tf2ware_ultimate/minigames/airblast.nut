minigame <- Ware_MinigameData();
minigame.name = "Airblast";
minigame.description = "Airblast!";
minigame.duration = 4.0;
minigame.location = "circlepit";
minigame.music = "clumsy";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.allow_damage = true;
minigame.fail_on_death = true;
minigame.end_delay = 1.0;
minigame.convars = 
{
	tf_airblast_cray_power = 1000
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower");
}

function OnUpdate()
{
	foreach (data in Ware_Players)
		Ware_DisablePlayerPrimaryFire(data.player);
}