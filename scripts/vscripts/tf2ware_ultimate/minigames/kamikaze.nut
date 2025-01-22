minigame <- Ware_MinigameData
({
	name           = "Kamikaze"
	author         = "ficool2"
	description    = 
	[
		"Avoid the Kamikaze!"
		"Explode 2 players!"
	]
	duration       = 4.0
	end_delay      = 0.5
	music          = "falling"
	custom_overlay = 
	[
		"avoid_kamikaze"
		"explode_players"
	]
	min_players    = 3
	start_pass     = true
	allow_damage   = true
})

kamikaze <- null
bomb <- null
annotation_id <- null
players_killed <- 0
player_threshold <- 2

bomb_model <- "models/custom/dirty_bomb_cart.mdl"
bomb_sound <- "pl_hoodoo/alarm_clock_ticking_3.wav"
bomb_particle <- "rocketpack_exhaust_smoke"
warning_sound <- "items/cart_explode_trigger.wav"
explode_particle <- "hightower_explosion"
explode_sound <- "items/cart_explode.wav"

function OnPrecache()
{
	PrecacheModel(bomb_model)
	PrecacheSound(bomb_sound)
	PrecacheParticle(bomb_particle)
	PrecacheSound(warning_sound)
	PrecacheParticle(explode_particle)
	PrecacheSound(explode_sound)
}

function OnStart()
{
	kamikaze = RandomElement(Ware_MinigamePlayers)
	
	foreach (player in Ware_MinigamePlayers)
	{	
		if (player == kamikaze)
		{
			Ware_PassPlayer(player, false)
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS)
			EmitSoundOn(bomb_sound, player)
			
			local particle = Ware_SpawnEntity("info_particle_system",
			{
				origin = player.EyePosition(),
				effect_name = bomb_particle,
				start_active = true
			})
			SetEntityParent(particle, player)
			
			bomb = Ware_SpawnWearable(player, bomb_model)
			SetPropInt(bomb, "m_fEffects", 0)
			SetEntityParent(bomb, player, "flag")
			
			player.SetForcedTauntCam(1)
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT)
		}
	}
	
	annotation_id = Ware_ShowAnnotation(kamikaze, "Avoid me!")
}

function OnEnd()
{
	if (kamikaze.IsValid())
	{		
		kamikaze.SetForcedTauntCam(0)
		
		local kamikaze_pos = kamikaze.GetOrigin()
		local particle = Ware_SpawnEntity("info_particle_system",
		{
			origin = kamikaze_pos
			effect_name = explode_particle,
			start_active = true
		})
		
		kamikaze.EmitSound(explode_sound)
		local radius = Ware_MinigameLocation.name.find("big") != null ? 1000.0 : 500.0
		Ware_RadiusDamagePlayers(kamikaze_pos, radius, 350.0, kamikaze)
		ScreenShake(kamikaze_pos, 1024.0, 25.0, 2.5, 4096.0, 0, true)
	}
	
	if (bomb.IsValid())
		bomb.Destroy()
}

function OnTakeDamage(params)
{
	return (params.damage_type & DMG_BLAST) != 0
}

function OnPlayerDeath(player, attacker, params)
{
	// get rid of annotation a bit more cleanly
	if (player == kamikaze)
		Ware_HideAnnotation(annotation_id)
	
	if (params.damagebits & DMG_BLAST)
	{
		players_killed++
		if (players_killed > player_threshold && kamikaze.IsValid())
			Ware_PassPlayer(kamikaze, true)
	}
	
	if (player != kamikaze)
		Ware_PassPlayer(player, false)
}