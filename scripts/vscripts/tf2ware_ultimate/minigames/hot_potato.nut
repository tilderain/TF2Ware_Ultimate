minigame <- Ware_MinigameData
({
	name          = "Hot Potato"
	author        = "ficool2"
	description   = "Pass the Hot Potato!"
	duration      = 6.0
	end_delay     = 0.5
	min_players   = 2
	music         = "dizzy"
	start_pass    = true
	allow_damage  = true
	fail_on_death = true
	thirdperson   = true
})

hot_potato <- null 
hot_potato_wearable <- null
hot_potato_timer <- 0.0

bomb_model <- "models/props_lakeside_event/bomb_temp.mdl"
explode_particle <- "eotl_pyro_pool_explosion"
explode_sound <- "vo/taunts/demo/taunt_demo_nuke_8_explosion.mp3"

bomb_modelindex <- PrecacheModel(bomb_model)
PrecacheSound(explode_sound)

function OnStart()
{
	SetHotPotato(RandomElement(Ware_MinigamePlayers).player)
}

function SetHotPotato(player)
{
	if (hot_potato && hot_potato.IsValid())
		hot_potato.RemoveCond(TF_COND_SPEED_BOOST)
	
	hot_potato = player
	hot_potato.AddCond(TF_COND_SPEED_BOOST)
	
	if (hot_potato_wearable && hot_potato_wearable.IsValid())
		hot_potato_wearable.Kill()
	
	hot_potato_wearable = Ware_SpawnWearable(player, bomb_model)
	SetPropInt(hot_potato_wearable, "m_fEffects", 0)
	SetEntityParent(hot_potato_wearable, hot_potato, "head")
	SetPropFloat(hot_potato_wearable, "m_flModelScale", 1.5)
	
	hot_potato_timer = Time() + 0.5
}

function OnPlayerTouch(player, other_player)
{
	if (hot_potato_timer > Time())
		return
	
	if (player == hot_potato)
		SetHotPotato(other_player)
	else if (other_player == hot_potato)
		SetHotPotato(player)
}

function OnTakeDamage(params)
{
	return (params.damage_type & DMG_BLAST) != 0
}

function OnEnd()
{
	if (hot_potato.IsValid())
	{			
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin = hot_potato.EyePosition(),
			effect_name = explode_particle,
			start_active = true
		})
		
		hot_potato.EmitSound(explode_sound)
		hot_potato.EmitSound(explode_sound)
		
		Ware_RadiusDamagePlayers(hot_potato.GetOrigin(), 250.0, 500.0, hot_potato)
		ScreenShake(hot_potato.GetOrigin(), 1024.0, 25.0, 2.5, 1024.0, 0, true)
	}
	
	if (hot_potato_wearable.IsValid())
		hot_potato_wearable.Kill()
}