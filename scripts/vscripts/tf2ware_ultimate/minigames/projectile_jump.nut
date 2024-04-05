local mode = RandomInt(0, 3);

minigame <- Ware_MinigameData();
minigame.name = "Projectile Jump";
minigame.duration = mode == 3 ? 5.0 : 4.0;
minigame.music = "goodtimes";
minigame.end_delay = mode == 3 ? 0.0 : 1.0;
minigame.convars = 
{
	tf_damageforcescale_self_soldier_badrj = 10,
	tf_damageforcescale_self_soldier_rj = 20
	tf_fastbuild = 1
};

if (mode == 0)
{
	minigame.description = "Needle jump!"
	minigame.custom_overlay = "needle_jump";
}
else if (mode == 1)
{
	minigame.description = "Rocket jump!"
	minigame.custom_overlay = "rocket_jump";
}
else if (mode == 2)
{
	minigame.description = "Sticky jump!"
	minigame.custom_overlay = "sticky_jump";
}
else if (mode == 3)
{
	minigame.description = "Sentry jump!"
	minigame.custom_overlay = "sentry_jump";
}

function OnStart()
{
	local player_class, weapon;
	if (mode == 0)
	{
		player_class = TF_CLASS_MEDIC;
		weapon = "Syringe Gun"
	}
	else if (mode == 1)
	{
		player_class = TF_CLASS_SOLDIER;
		weapon = "Rocket Launcher";
	}
	else if (mode == 2)
	{
		player_class = TF_CLASS_DEMOMAN;
		weapon = "Stickybomb Launcher";
	}
	else if (mode == 3)
	{
		player_class = TF_CLASS_ENGINEER;
		weapon = ["Wrangler", "Toolbox", "Construction PDA"];
		Ware_SetGlobalAttribute("build rate bonus", 0, -1);
	}
	
	Ware_SetGlobalLoadout(player_class, weapon);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		if (!IsEntityAlive(player))
			continue;		
		if (Ware_GetPlayerHeight(player) > 512.0)
			Ware_PassPlayer(player, true);
	}
}

if (mode == 0)
{
	function OnPlayerAttack(player)
	{
		local dir = player.EyeAngles().Forward();
		dir.Norm();
		
		local dot = dir.Dot(Vector(0, 0, -1.0));
		if (dot > 0.707) // cos(45)
			player.SetAbsVelocity(player.GetAbsVelocity() - dir * 80.0 * dot);
	}
}
else if (mode == 3)
{
	function OnGameEvent_player_builtobject(params)
	{
		local building = EntIndexToHScript(params.index);
		if (!building)
			return;
			
		SetPropInt(building, "m_nDefaultUpgradeLevel", 2);
	}	
}