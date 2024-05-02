minigame <- Ware_MinigameData
({
	name           = "Extinguish"
	author         = "ficool2"
	description    =
	[
		"Get Extinguished!"
		"Extinguish a Scout!"
	]
	duration       = 4.5
	end_delay      = 0.5
	music          = "fencing"
	custom_overlay = 
	[
		"extinguish_scout"
		"extinguish_pyro"
	]
	min_players    = 2
	allow_damage   = true
	friendly_fire  = false
	start_pass     = true
	fail_on_death  = true
	convars        =
	{
		mp_teams_unbalance_limit = 0
	}
})

function OnStart()
{
	local pyro_team = RandomInt(TF_TEAM_RED, TF_TEAM_BLUE)
	foreach (data in Ware_MinigamePlayers)
	{
		local player = data.player
					
		if (player.GetTeam() == pyro_team)
		{
			Ware_SetPlayerMission(player, 1)
			Ware_SetPlayerClass(player, TF_CLASS_PYRO)
			Ware_SetPlayerTeam(player, pyro_team)			
			Ware_GivePlayerWeapon(player, "Backburner")
			Ware_SetPlayerAmmo(player, TF_AMMO_PRIMARY, 100)
			Ware_PassPlayer(player, false)
		}
		else
		{
			Ware_SetPlayerMission(player, 0)
			Ware_SetPlayerClass(player, TF_CLASS_SCOUT)
			player.SetHealth(25)
			Ware_CreateTimer(@() BurnPlayer(player, 10, Ware_GetMinigameRemainingTime()), RandomFloat(0.0, 0.2))
			Ware_SetPlayerTeam(player, pyro_team)
		}
	}
}

function OnUpdate()
{
	foreach (data in Ware_MinigamePlayers)
	{
		if (data.player.GetPlayerClass() == TF_CLASS_PYRO)
			Ware_DisablePlayerPrimaryFire(data.player)
	}
}

function OnGameEvent_player_healonhit(params)
{
	local player = PlayerInstanceFromIndex(params.entindex)
	if (player)
		Ware_PassPlayer(player, true)
}
