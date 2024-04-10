minigame <- Ware_MinigameData();
minigame.name = "Street Fighter";
minigame.description = "Taunt kill!";
minigame.duration = 21.5;
minigame.end_delay = 1.0;
minigame.allow_damage = true;
minigame.friendly_fire = false;
minigame.location = "boxarena";
minigame.music = "streetfighter";
minigame.min_players = 2;
minigame.custom_overlay = "taunt_kill";
local fire_sound = "TF2Ware_Ultimate.Hadoken";
PrecacheScriptSound(fire_sound);

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Panic Attack");
	Ware_SetGlobalAttribute("no_attack", 1, -1);
}

function OnTeleport(players)
{
	local red_players = [];
	local blue_players = [];
	foreach (player in players)
	{
		local team = player.GetTeam();
		if (team == TF_TEAM_RED)
			red_players.append(player);
		else if (team == TF_TEAM_BLUE)
			blue_players.append(player);
	}
	
	Ware_TeleportPlayersRow(red_players,
		Ware_MinigameLocation.center + Vector(0, 500.0, 0),
		QAngle(0, 270, 0),
		1300.0,
		65.0, 65.0);
	Ware_TeleportPlayersRow(blue_players,
		Ware_MinigameLocation.center + Vector(0, -500.0, 0),
		QAngle(0, 90, 0),
		1300.0,
		65.0, 65.0);
}

function SpawnFireball(player)
{
	local fireball = Ware_CreateEntity("tf_projectile_spellfireball");
	fireball.Teleport(
		true, player.EyePosition(), 
		true, player.EyeAngles(), 
		true, player.EyeAngles().Forward() * 650.0);
	fireball.SetTeam(player.GetTeam());
	fireball.SetOwner(player);
	fireball.SetModelScale(3.0, 0.0);
	SetPropBool(fireball, "m_bCritical", true);
	fireball.DispatchSpawn();
	
	player.EmitSound(fire_sound);
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		local attack_time = player.GetTauntAttackTime();
		if (attack_time > 0.0)
		{
			Ware_CreateTimer(@() SpawnFireball(player), attack_time - Time());
			player.ClearTauntAttack();
		}
	}
}

function OnTakeDamage(params)
{
	if (params.inflictor.GetClassname() == "tf_projectile_spellfireball")
	{
		local attacker = params.attacker;
		if (attacker && attacker.IsPlayer())
			Ware_PassPlayer(attacker, true);
		
		params.damage = 800.0;
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers(TF_TEAM_RED).len() == 0 || Ware_GetAlivePlayers(TF_TEAM_BLUE).len() == 0;
}