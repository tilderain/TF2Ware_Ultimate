minigame <- Ware_MinigameData
({
	name           = "Goomba"
	author         = "ficool2"
	description    = 
	[
		"Don't get jumped on!"
		"Jump on a Heavy's head!"
	]
	duration       = 5.0
	music          = "clumsy"
	custom_overlay =
	[
		"dont_jumped"
		"jump_heavy"
	]
	min_players    = 2
	start_pass     = true
	allow_damage   = true
	fail_on_death  = true
	collisions     = true
})

jump_team <- 0

function OnPick()
{
	return Ware_ArePlayersOnBothTeams() && Ware_Players.len() <= 12
}

function OnStart()
{
	jump_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
	
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.GetTeam() == jump_team)
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT)
			Ware_PassPlayer(player, false)
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_HEAVYWEAPONS)
			Ware_AddPlayerAttribute(player, "no_jump", 1.0, minigame.duration)
		}
	}	
}

function OnUpdate()
{
	foreach (player in Ware_MinigamePlayers)
	{
		if (player.GetTeam() == jump_team)
		{
			if (player.IsAlive())
			{
				local ground = GetPropEntity(player, "m_hGroundEntity")
				if (ground != null && ground.IsPlayer() && ground.GetTeam() != jump_team)
				{
					Ware_PassPlayer(player, true)

					ground.TakeDamageCustom(
						player, player, null, Vector(), Vector(), 
						1000.0, DMG_FALL, TF_DMG_CUSTOM_BOOTS_STOMP)
					ScreenShake(ground.GetCenter(), 15.0, 150.0, 1.0, 500, 0, true)
				}
			}
		}
	}
}

function OnTakeDamage(params)
{
	return params.damage_stats == TF_DMG_CUSTOM_BOOTS_STOMP
}