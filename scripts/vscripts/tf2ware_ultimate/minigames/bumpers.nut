minigame <- Ware_MinigameData
({
	name          = "Bumpers"
	author        = ["LiLGuY", "ficool2"]
	description   = "Bump into others!"
	duration      = 4.5
	location      = "circlepit"
	music         = "actfast"
	min_players   = 2
	max_players   = 40
	start_freeze  = 0.5
	collisions    = true
	convars       = 
	{
		sv_gravity        = 2000
		tf_avoidteammates = 0
	}
})

bump_sound <- "BumperCar.BumpIntoAir"

function OnPrecache()
{
	PrecacheScriptSound(bump_sound)
}

function OnStart()
{
	Ware_SetGlobalLoadout(TF_CLASS_HEAVYWEAPONS)
	Ware_SetGlobalCondition(TF_COND_SPEED_BOOST)
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_FALL)
		params.damage *= 5.0
}

function OnPlayerTouch(player, other_player)
{
	other_player.EmitSound(bump_sound)
	other_player.SetAbsVelocity(other_player.GetAbsVelocity() + Vector(0, 0, 600))
	Ware_PushPlayerFromOther(other_player, player, 600.0)
	Ware_PassPlayer(player, true)
}