heavy_team <- RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)

minigame <- Ware_MinigameData
({
	name          = "Don't Laugh"
	author        = "pokemonPasta"
	description   =
	[
		"Don't Laugh!"
		"Make the Scouts Laugh!"
	]
	duration      = 4.0
	music         = "brassy"
	custom_overlay = 
	[
		"laugh_scout"
		"laugh_heavy"
	]
	min_players   = 2
	allow_damage  = true
	friendly_fire = false
	start_pass    = true
})

// Mission 0: Scout Team
// Mission 1: Heavy Team

function OnStart()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		
		// prevent taunting
		player.AddCond(TF_COND_GRAPPLED_TO_PLAYER)
		
		if (player.GetTeam() == heavy_team)
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS)
			Ware_GivePlayerWeapon(player, "Holiday Punch")
			// give crits so holiday punch always makes laugh
			player.AddCond(TF_COND_CRITBOOSTED)
			// default to fail unless they make a scout laugh
			Ware_PassPlayer(player, false)
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT)
		}
	}
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		if (player.InCond(TF_COND_TAUNTING))
		{
			// allows midair taunting
			if (GetPropEntity(player, "m_hGroundEntity") == null)
				SetPropEntity(player, "m_hGroundEntity", World)
		}
	}
}

function OnTakeDamage(params)
{
	local victim = params.const_entity
	local attacker = params.attacker
	if (victim.IsPlayer() && attacker.IsPlayer())
	{
		params.damage = 0.0
		
		// allows midair taunting
		if (GetPropEntity(victim, "m_hGroundEntity") == null)
			SetPropEntity(victim, "m_hGroundEntity", World)
	
		victim.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER)
		Ware_CreateTimer(@() CheckTaunt(victim, attacker), 0.0)
	}
}

function CheckTaunt(victim, attacker)
{
	victim.AddCond(TF_COND_GRAPPLED_TO_PLAYER)
	if (victim.GetTeam() != heavy_team &&
		attacker.GetTeam() == heavy_team &&
		victim.IsTaunting())
	{
		Ware_PassPlayer(victim, false)
		Ware_PassPlayer(attacker, true)
	}
}

function OnEnd()
{
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
		player.RemoveCond(TF_COND_CRITBOOSTED)
		player.RemoveCond(TF_COND_GRAPPLED_TO_PLAYER)
	}
}
