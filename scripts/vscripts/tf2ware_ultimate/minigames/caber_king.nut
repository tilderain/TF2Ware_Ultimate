minigame <- Ware_MinigameData
({
	name           = "Caber King"
	author         = ["LiLGuY", "ficool2"]
	description    = "Survive!"
	duration       = 4.5
	end_delay      = 0.5
	music          = "falling"
	custom_overlay = "survive"
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
})

function OnStart()
{
	// can't give shields directly unfortunately
	// TODO: Prevent charge spam after initial charge
	foreach (player in Ware_MinigamePlayers)
	{
		Ware_SetPlayerLoadout(player, TF_CLASS_DEMOMAN, "Ullapool Caber")
		Ware_GetPlayerMiniData(player).attack2 <- false
		SetPropBool(player, "m_Shared.m_bShieldEquipped", true)
	}
}

function OnTakeDamage(params)
{
	if (params.damage_type & DMG_BLAST)
	{
		if (params.const_entity != params.attacker)
			params.damage *= 2.5
		else
			params.damage = 100.0
		
		params.damage_type = params.damage_type & (~DMG_SLOWBURN) // no falloff
	}
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		local minidata = Ware_GetPlayerMiniData(player)
		local attack2 = GetPropInt(player, "m_nButtons") & IN_ATTACK2
		if (attack2 && !minidata.attack2)
		{
			player.AddCond(TF_COND_SHIELD_CHARGE)
		}
		minidata.attack2 = attack2
	}
}

function OnCleanup()
{
	foreach (player in Ware_MinigamePlayers)
	{
		SetPropBool(player, "m_Shared.m_bShieldEquipped", false)
		player.RemoveCond(TF_COND_SHIELD_CHARGE)
	}	
}