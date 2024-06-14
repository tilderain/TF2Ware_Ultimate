minigame <- Ware_MinigameData
({
	name           = "Halloween Fight"
	author         = "ficool2"
	description    = "Fight and Stay Alive!"
	location       = "circlepit"
	duration       = 14.5
	end_delay      = 0.5
	music          = "survivor"
	custom_overlay = "fight"
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
	thirdperson    = true
	collisions     = true
	convars =
	{
		tf_avoidteammates = 0
	}
})

boss_models <-
[
	"models/bots/skeleton_sniper/skeleton_sniper.mdl",
	"models/bots/merasmus/merasmus.mdl",
	"models/bots/headless_hatman.mdl",
]
boss_idx <- RandomIndex(boss_models)
PrecacheModel(boss_models[boss_idx])

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (boss_idx == 0)
		{
			Ware_SetPlayerLoadout(player, TF_CLASS_SNIPER, "Bat Outta Hell")
			Ware_AddPlayerAttribute(player, "max health additive bonus", 1000 - 125.0, -1)
		}
		else if (boss_idx == 1)
		{
			Ware_TogglePlayerWearables(player, false)		
			Ware_SetPlayerLoadout(player, TF_CLASS_SNIPER, "Kukri")
			Ware_AddPlayerAttribute(player, "max health additive bonus", 1000 - 125.0, -1)
			player.SetModelScale(0.6, 0.0)
		}
		else if (boss_idx == 2)
		{
			Ware_TogglePlayerWearables(player, false)		
			Ware_SetPlayerLoadout(player, TF_CLASS_DEMOMAN, "Horseless Headless Horseman's Headtaker")
			Ware_AddPlayerAttribute(player, "max health additive bonus", 1000 - 150.0, -1)
			player.SetModelScale(0.7, 0.0)
			
			local minidata = Ware_GetPlayerMiniData(player)
			local particle_kv = 
			{
				origin = player.GetOrigin(),
				effect_name = "halloween_boss_eye_glow"
				start_active = true,
			}
			
			minidata.left_glow <- Ware_SpawnEntity("info_particle_system", particle_kv)
			minidata.right_glow <- Ware_SpawnEntity("info_particle_system", particle_kv)
			SetEntityParent(minidata.left_glow, player, "lefteye")
			SetEntityParent(minidata.right_glow, player, "righteye")
		}

		player.SetHealth(1000)
		player.SetCustomModelWithClassAnimations(boss_models[boss_idx])
	}
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
		SetPropFloat(data.player, "m_flMaxspeed", 520.0)
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (victim.IsPlayer()
		&& attacker && attacker != victim && attacker.IsPlayer())
	{
		params.damage = 500.0
	}
}

function OnPlayerDeath(params)
{
	local victim = GetPlayerFromUserID(params.userid)
	if (!victim)
		return
		
	if (boss_idx == 1)
	{
		victim.SetCustomModel("")
		CreateTimer(@() KillPlayerRagdoll(victim), 0.0)
	}
	else if (boss_idx == 2)
	{
		local minidata = Ware_GetPlayerMiniData(victim)
		if (minidata.left_glow.IsValid())
			minidata.left_glow.Kill()
		if (minidata.right_glow.IsValid())
			minidata.right_glow.Kill()
	}
}

function OnCleanup()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.SetCustomModel("")
		player.SetModelScale(1.0, 0.0)
		Ware_TogglePlayerWearables(player, true)
	}
}

function CheckEnd()
{
	return Ware_GetAlivePlayers().len() <= 1
}