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

hot_potatos <- null 
hot_potatos_wearable <- null
hot_potatos_timer <- null

bomb_model <- "models/props_lakeside_event/bomb_temp.mdl"
explode_particle <- "eotl_pyro_pool_explosion"
explode_sound <- "vo/taunts/demo/taunt_demo_nuke_8_explosion.mp3"

bomb_modelindex <- PrecacheModel(bomb_model)

function OnPrecache()
{
	PrecacheModel(bomb_model)
	PrecacheParticle(explode_particle)
	PrecacheSound(explode_sound)
}

function OnStart()
{
	local count = Ware_MinigamePlayers.len() / 12 + 1
	hot_potatos = array(count)
	hot_potatos_wearable = array(count)
	hot_potatos_timer = array(count, 0.0)
	
	local candidates = clone(Ware_MinigamePlayers)
	
	for (local i = 0; i < count; i++)
		SetHotPotato(i, RemoveRandomElement(candidates).player)
}

function SetHotPotato(index, player)
{
	local hot_potato = hot_potatos[index]
	if (hot_potato && hot_potato.IsValid())
		hot_potato.RemoveCond(TF_COND_SPEED_BOOST)
	
	hot_potato = player
	hot_potato.AddCond(TF_COND_SPEED_BOOST)
	hot_potatos[index] = player
		
	local hot_potato_wearable = hot_potatos_wearable[index]
	if (hot_potato_wearable && hot_potato_wearable.IsValid())
		hot_potato_wearable.Kill()
	
	hot_potato_wearable = Ware_SpawnWearable(player, bomb_model)
	SetPropInt(hot_potato_wearable, "m_fEffects", 0)
	SetEntityParent(hot_potato_wearable, hot_potato, "head")
	hot_potato_wearable.SetModelScale(1.2, 0)
	hot_potatos_wearable[index] = hot_potato_wearable
	 
	hot_potatos_timer[index] = Time() + 0.5
}

function OnPlayerTouch(player, other_player)
{
	local index = hot_potatos.find(player)
	local other_index = hot_potatos.find(other_player)
	
	if (index == null && other_index == null)
		return
	if (index != null && other_index != null)
		return
		
	local time = Time()
	if (index != null && hot_potatos_timer[index] > time)
		return
	if (other_index != null && hot_potatos_timer[other_index] > time)
		return
	
	if (index != null)
		SetHotPotato(index, other_player)
	else if (other_index != null)
		SetHotPotato(other_index, player)
}

function OnTakeDamage(params)
{
	return (params.damage_type & DMG_BLAST) != 0
}

function OnEnd()
{
	foreach (hot_potato in hot_potatos)
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
			
			Ware_RadiusDamagePlayers(hot_potato.GetOrigin(), 250.0, 500.0, hot_potato)
			ScreenShake(hot_potato.GetOrigin(), 1024.0, 25.0, 2.5, 1024.0, 0, true)
		}
	}
	
	foreach (hot_potato_wearable in hot_potatos_wearable)
	{
		if (hot_potato_wearable.IsValid())
			hot_potato_wearable.Kill()
	}
}