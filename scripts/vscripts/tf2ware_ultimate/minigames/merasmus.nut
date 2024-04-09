minigame <- Ware_MinigameData();
minigame.name = "Stun Merasmus";
minigame.description = "Stun Merasmus!"
minigame.duration = 8.0;
minigame.music = "nearend";
minigame.convars =
{
	tf_flamethrower_burstammo = 0,
}

local merasmus;

// TODO: will need to precache merasmus sounds to prevent hitches

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_PYRO, "Flame Thrower");
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.AddCond(TF_COND_HALLOWEEN_SPEED_BOOST);
		player.AddCond(TF_COND_HALLOWEEN_BOMB_HEAD);
	}
	
	Ware_CreateTimer(@() SpawnMerasmus(), 0.1);
}

function SpawnMerasmus()
{
	merasmus = Ware_SpawnEntity("merasmus",
	{
		origin = Ware_MinigameLocation.center + Vector(0, 0, 32),
		modelscale = 0.5,
	});
}

function OnUpdate()
{
	local merasmus_origin;
	if (merasmus && merasmus.IsValid())
		merasmus_origin = merasmus.GetOrigin();
	
	foreach (data in Ware_MinigamePlayers)
		Ware_DisablePlayerPrimaryFire(data.player);
}

function OnTakeDamage(params)
{
	if (params.const_entity.GetClassname() == "merasmus")
	{
		local attacker = params.attacker;
		if (attacker
			&& attacker.IsPlayer()
			&& params.damage_stats == TF_DMG_CUSTOM_MERASMUS_PLAYER_BOMB)
		{
			Ware_PassPlayer(attacker, true);
		}
	}
}

function OnEnd()
{
	if (merasmus.IsValid())
	{
		SendGlobalGameEvent("merasmus_killed", {});
		merasmus.Kill();
	}
	
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player;
		player.RemoveCond(TF_COND_HALLOWEEN_SPEED_BOOST);
		player.RemoveCond(TF_COND_HALLOWEEN_BOMB_HEAD);
		player.RemoveCond(TF_COND_CRITBOOSTED_PUMPKIN);
		player.RemoveCond(TF_COND_SPEED_BOOST);
		player.RemoveCond(TF_COND_INVULNERABLE);		
	}
}