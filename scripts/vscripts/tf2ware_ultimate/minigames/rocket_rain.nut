minigame <- Ware_MinigameData();
minigame.name = "Rocket Rain";
minigame.description = "Airblast the rockets!"
minigame.duration = 4.0;
minigame.music = "goodtimes";
minigame.allow_damage = true;
minigame.end_delay = 1.0;
minigame.custom_overlay = "airblast_rockets";

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower");
	Ware_RunFunction("SpawnRockets", 0.8);
}

function OnUpdate()
{
	foreach (data in Ware_Players)
		Ware_DisablePlayerPrimaryFire(data.player);
}

function OnTakeDamage(params)
{
	if (params.const_entity.IsPlayer())
	{
		params.weapon = null;
		params.attacker = World;
		
		local inflictor = params.inflictor;
		if (inflictor != null && inflictor.GetClassname() == "ware_projectile")
		{
			// prevents server crash because of attacker not being a player
			SetPropEntity(inflictor, "m_hLauncher", null);
		}
	}
}

function OnGameEvent_object_deflected(params)
{
	local player = GetPlayerFromUserID(params.userid);
	if (player == null)
		return;
	
	local object = EntIndexToHScript(params.object_entindex);
	if (object != null && object.GetClassname() == "ware_projectile")
	{
		object.SetTeam(TEAM_SPECTATOR);
		Ware_PassPlayer(player, true);
	}
}

function OnFireRocketPre()
{
	if (activator == null)
		return false;
	
	local pos = activator.GetOrigin();
	self.SetOrigin(Vector
	(
		pos.x + RandomFloat(-50.0, 50.0),
		pos.y + RandomFloat(-50.0, 50.0),
		pos.z + RandomFloat(450.0, 900.0)
	));
	
	return true;
}

function OnFireRocketPost()
{
	if (activator != null)
	{
		local rocket = FindByClassname(null, "tf_projectile_rocket");
		if (rocket != null)
		{
			rocket.SetOwner(activator);		
			rocket.SetTeam(TEAM_SPECTATOR);
			rocket.KeyValueFromString("classname", "ware_projectile");
		}
	}
}

function SpawnRockets()
{
	local spawner = Ware_SpawnEntity("tf_point_weapon_mimic", 
	{
		origin = Ware_MinigameLocation.center,
		WeaponType = 0,
		SpeedMin = 500,
		SpeedMax = 500,
		Damage = 999,
		Crits = true,
		angles = QAngle(90, 0, 0)
	});
	spawner.SetTeam(TEAM_SPECTATOR);
	SetInputHook(spawner, "FireOnce", OnFireRocketPre, OnFireRocketPost);
	
	foreach (data in Ware_Players)
		EntFireByHandle(spawner, "FireOnce", "", -1.0, data.player, data.player);
}