local bump_sound = "BumperCar.BumpIntoAir";
PrecacheScriptSound(bump_sound);

minigame <- Ware_MinigameData();
minigame.name = "Bumpers"
minigame.description = "Bump into others!"
minigame.duration = 4.5;
minigame.location = "circlepit";
minigame.music = "actfast";
minigame.min_players = 2;
minigame.start_pass = true;
minigame.fail_on_death = true;
minigame.convars = 
{
	sv_gravity = 2000,
	tf_avoidteammates = 0
};

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS, null);
	Ware_SetGlobalCondition(TF_COND_SPEED_BOOST);
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		params.damage *= 5.0;
}

function OnPlayerTouch(player, other_player)
{
	other_player.EmitSound(bump_sound);
	other_player.SetAbsVelocity(other_player.GetAbsVelocity() + Vector(0, 0, 600));
	Ware_PushPlayerFromOther(other_player, player, 600.0);
}